class_name PlacementManager
extends Node2D

# grid configuration
@export var tile_size: int = 16
@export var wall_margin: int = 1

@onready var ground_layers := get_tree().get_nodes_in_group("floors")
@onready var structures_folder := get_node_or_null("Structures")

# runtime state
var placed := {}
var local_cells: Array[Vector2i] = []
var ghost: Node2D
var is_placing := false

# template state
const SELECTED := 0
var templates: Array[Node2D] = []
var footprints := {}

func _ready() -> void:
	_load_templates()

	# disable processing if required references are missing
	if templates.is_empty() or structures_folder == null or ground_layers.is_empty():
		push_error("PlacementManager: missing templates, Structures node, or floors group")
		set_process(false)
		set_process_unhandled_input(false)
		return

	# build preview ghost from the selected template
	var template := templates[SELECTED]
	ghost = _spawn(template)
	ghost.visible = false
	ghost.z_index = 100
	add_child(ghost)
	local_cells.assign(footprints[template.scene_file_path])

	# register structures that already exist
	for child in structures_folder.get_children():
		if child is Node2D:
			_register(child)

# collect templates from the group and cache each one's footprint
func _load_templates() -> void:
	for n in get_tree().get_nodes_in_group("structure_templates"):
		var node := n as Node2D
		if node == null:
			continue
		if node.scene_file_path == "":
			push_warning("%s isn't an instance of a saved scene, skipping" % node.name)
			continue
		templates.append(node)
		footprints[node.scene_file_path] = _get_footprint(node)
	# group order isn't guaranteed, so sort for a stable order
	templates.sort_custom(func(a, b): return a.name < b.name)

# read a structure's footprint from its TileMapLayer
func _get_footprint(node: Node2D) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for child in node.get_children():
		if child is TileMapLayer:
			cells.assign(child.get_used_cells())
			break
	if cells.is_empty():
		push_warning("no painted tiles found in %s's TileMapLayer, using 1x1 footprint" % node.name)
		cells = [Vector2i.ZERO]
	return cells

# make a fresh copy from the template's scene file
func _spawn(template: Node2D) -> Node2D:
	return load(template.scene_file_path).instantiate() as Node2D

func _unhandled_input(event: InputEvent) -> void:
	# toggle placement mode
	if event.is_action_pressed("toggle_placement_mode"):
		_set_placing(not is_placing)
		if is_placing == true:
			ground_layers = get_tree().get_nodes_in_group("floors")
		get_viewport().set_input_as_handled()
		return

	# place structure on click
	if is_placing and event.is_action_pressed("left_click"):
		_try_place()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not is_placing:
		return
	
	# update ghost snap position and tint green/red based on validity
	var cell := _world_to_cell(get_global_mouse_position())
	ghost.global_position = Vector2(cell * tile_size)
	ghost.modulate = Color(0.5, 1, 0.5, 0.5) if _can_place(cell) else Color(1, 0.4, 0.4, 0.5)

# update placement state and toggle ghost visibility
func _set_placing(value: bool) -> void:
	is_placing = value
	ghost.visible = value

# convert world space coordinates to grid cell coordinates
func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i((pos / tile_size).floor())

# check if cell and surrounding wall margin have valid placeable tile data
func _is_cell_placeable(cell: Vector2i) -> bool:
	for x in range(-wall_margin, wall_margin + 1):
		# only wall_margin here to allow placing on bottom of rooms
		if not _is_floor(cell + Vector2i(x, -1)):
			return false
	return true
	
# a cell counts as floor if ANY floor layer has a placeable tile there
func _is_floor(cell: Vector2i) -> bool:
	var world_pos := Vector2(cell * tile_size) + Vector2(tile_size, tile_size) * 0.5

	for layer in ground_layers:
		var tl := layer as TileMapLayer
		if tl == null:
			continue
		# check grid coordinates relative to map instead of globally to avoid offsets
		var layer_cell := tl.local_to_map(tl.to_local(world_pos))
		var data := tl.get_cell_tile_data(layer_cell)
		if data != null and data.get_custom_data("placeable"):
			return true
	return false

# check if all footprint cells are empty and on valid ground
func _can_place(origin: Vector2i) -> bool:
	for c in local_cells:
		var cell = origin + c
		if placed.has(cell):
			return false
		if not _is_cell_placeable(cell):
			return false
	return true

# attempt structure placement at mouse position
func _try_place() -> void:
	var origin := _world_to_cell(get_global_mouse_position())
	if not _can_place(origin):
		return
	var table := _spawn(templates[SELECTED])
	structures_folder.add_child(table)
	table.global_position = Vector2(origin * tile_size)
	_register(table)

# register cells into the occupied dictionary and handle cleanup on removal
func _register(node: Node2D) -> void:
	# look up the footprint by scene file so each structure type uses its own
	var cells_local: Array = footprints.get(node.scene_file_path, [Vector2i.ZERO])
	var origin := _world_to_cell(node.global_position)
	var cells: Array[Vector2i] = []
	for c in cells_local:
		cells.append(origin + c)
		placed[origin + c] = node
	
	# erase occupied grid entries when the structure node is deleted
	node.tree_exited.connect(func():
		for c in cells:
			placed.erase(c))
