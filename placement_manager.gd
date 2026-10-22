class_name PlacementManager
extends Node2D

# grid configuration
@export var tile_size: int = 16
@export var wall_margin: int = 1
@export var anchor_bottom := false  # true = hovered cell is the structure's bottom row

@onready var ground_layers := get_tree().get_nodes_in_group("floors")
@onready var structures_folder := get_node_or_null("Structures")
@onready var build_ui = get_node_or_null("BuildUI")

# runtime state
var placed := {}
var local_cells: Array[Vector2i] = []
var ghost: Node2D
var ghost_layer := 0
var ghost_offset := Vector2.ZERO
var is_placing := false
var _next_order := 0

# current selection (set by the build UI cards)
var selected_scene: PackedScene
var selected_cost := 0

# cache per scene file path: {"cells": Array[Vector2i], "offset": Vector2}
var footprints := {}

func _ready() -> void:
	# floors are refreshed whenever build mode opens, so they aren't required here
	if structures_folder == null or build_ui == null:
		push_error("PlacementManager: missing Structures node or BuildUI node")
		set_process(false)
		set_process_unhandled_input(false)
		return

	build_ui.visible = false
	build_ui.structure_chosen.connect(_select)

	# register structures that already exist
	for child in structures_folder.get_children():
		if child is Node2D:
			_register(child)

# called when a card is clicked in the build UI
func _select(scene: PackedScene, cost: int) -> void:
	selected_scene = scene
	selected_cost = cost

	var info := _info_for(scene.resource_path)
	local_cells.assign(info["cells"])
	ghost_offset = info["offset"]
	ghost_layer = int(info.get("layer", 0))

	if ghost:
		ghost.queue_free()
	ghost = _make_ghost(scene)
	add_child(ghost)

# ghosts are visual only: they must never run scripts, timers or earn money
func _make_ghost(scene: PackedScene) -> Node2D:
	var g := scene.instantiate() as Node2D
	# set before add_child so nothing ever runs, children inherit this mode
	g.process_mode = Node.PROCESS_MODE_DISABLED
	g.z_index = 100
	return g

# footprint info with lazy caching, works for any structure scene
func _info_for(path: String) -> Dictionary:
	if not footprints.has(path):
		var probe := (load(path) as PackedScene).instantiate() as Node2D
		var info: Dictionary = _compute_info(probe)
		info["layer"] = int(probe.get_meta("layer", 0))
		footprints[path] = info
		probe.free()  # never entered the tree, so free() is safe
	return footprints[path]
	
func _compute_info(node: Node2D) -> Dictionary:
	var fp := node.get_node_or_null("Footprint")
	var shape_node := fp.get_node_or_null("CollisionShape2D") as CollisionShape2D if fp else null
	var rect := shape_node.shape as RectangleShape2D if shape_node else null
	if rect == null:
		return _compute_from_tiles(node)  # no footprint set: old behavior

	var size := rect.size
	# top-left of the box in the structure's own coordinates
	var top_left := (fp as Node2D).position + shape_node.position - size / 2.0

	var offset := top_left
	if anchor_bottom:
		offset.y = top_left.y + size.y - tile_size

	var cols := maxi(1, roundi(size.x / tile_size))
	var rows := maxi(1, roundi(size.y / tile_size))
	var cells: Array[Vector2i] = []
	for x in cols:
		for y in rows:
			cells.append(Vector2i(x, y))
	return {"cells": cells, "offset": offset}

# measures where a structure's painted tiles really are, so placement can compensate
func _compute_from_tiles(node: Node2D) -> Dictionary:
	var layer: TileMapLayer = null
	for child in node.get_children():
		if child is TileMapLayer:
			layer = child
			break

	var empty: Array[Vector2i] = [Vector2i.ZERO]
	if layer == null or layer.tile_set == null or layer.get_used_cells().is_empty():
		push_warning("no painted tiles in %s, using 1x1 footprint" % node.name)
		return {"cells": empty, "offset": Vector2.ZERO}

	var ts := Vector2(layer.tile_set.tile_size)
	var used := layer.get_used_cells()
	var min_c: Vector2i = used[0]
	var max_c: Vector2i = used[0]
	for c in used:
		min_c = Vector2i(mini(min_c.x, c.x), mini(min_c.y, c.y))
		max_c = Vector2i(maxi(max_c.x, c.x), maxi(max_c.y, c.y))

	# pixel position (relative to the structure root) that should land on the grid
	var offset := layer.position + Vector2(min_c) * ts
	if anchor_bottom:
		offset.y = layer.position.y + float(max_c.y + 1) * ts.y - tile_size

	# convert painted tiles to cells of THIS grid (handles tile sizes != tile_size)
	var seen := {}
	for c in used:
		var p := layer.position + Vector2(c) * ts - offset
		for x in range(floori(p.x / tile_size), ceili((p.x + ts.x) / tile_size)):
			for y in range(floori(p.y / tile_size), ceili((p.y + ts.y) / tile_size)):
				seen[Vector2i(x, y)] = true

	var cells: Array[Vector2i] = []
	cells.assign(seen.keys())
	return {"cells": cells, "offset": offset}

func _unhandled_input(event: InputEvent) -> void:
	# toggle placement mode
	if event.is_action_pressed("toggle_placement_mode"):
		_set_placing(not is_placing)
		if is_placing:
			ground_layers = get_tree().get_nodes_in_group("floors")
		get_viewport().set_input_as_handled()
		return

	# place structure on left click
	if is_placing and event.is_action_pressed("left_click"):
		_try_place()
		get_viewport().set_input_as_handled()
		return

	# destroy structure on right click
	if is_placing and event.is_action_pressed("right_click"):
		_try_destroy()
		get_viewport().set_input_as_handled()
		return
		
func _process(_delta: float) -> void:
	if not is_placing or ghost == null:
		return

	# update ghost snap position and tint green/red based on validity and cost
	var cell := _world_to_cell(get_global_mouse_position())
	ghost.global_position = Vector2(cell * tile_size) - ghost_offset
	var ok: bool = _can_place(cell) and Globals.money >= selected_cost
	ghost.modulate = Color(0.5, 1, 0.5, 0.5) if ok else Color(1, 0.4, 0.4, 0.5)

# update placement state, the build UI and the ghost together
func _set_placing(value: bool) -> void:
	is_placing = value
	build_ui.visible = value
	if not value:
		selected_scene = null
		if ghost:
			ghost.queue_free()
			ghost = null

# convert world space coordinates to grid cell coordinates
func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i((pos / tile_size).floor())

# check if cell and surrounding wall margin have valid placeable tile data
func _is_cell_placeable(cell: Vector2i) -> bool:
	for x in range(-wall_margin, wall_margin + 1):
		# only wall_margin here to allow placing on bottom of rooms
		if not _is_floor(cell + Vector2i(x, 0)):
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
		var cell := origin + c
		if placed.has(cell):
			return false
		if placed.has(Vector3i(cell.x, cell.y, ghost_layer)):
			return false
		if not _is_cell_placeable(cell):
			return false
	return true

# attempt to destroy a structure at the mouse position
func _try_destroy() -> void:
	var cell := _world_to_cell(get_global_mouse_position())
	
	# Check the current ghost layer first
	var key := Vector3i(cell.x, cell.y, ghost_layer)
	if placed.has(key):
		placed[key].queue_free()
		return
		
	# Fallback: check if there's a structure on any other layer at this cell
	for k in placed.keys():
		if k.x == cell.x and k.y == cell.y:
			placed[k].queue_free()
			return

# attempt structure placement at mouse position
func _try_place() -> void:
	if Globals.money < selected_cost:
		Money._too_expensive()
		return
	
	if selected_scene == null:
		return
	var origin := _world_to_cell(get_global_mouse_position())
	if not _can_place(origin):
		return

	Globals.money -= selected_cost
	var info := _info_for(selected_scene.resource_path)
	var structure := selected_scene.instantiate() as Node2D
	structures_folder.add_child(structure)
	structure.global_position = Vector2(origin * tile_size) - (info["offset"] as Vector2)
	_register(structure)

# register cells into the occupied dictionary and handle cleanup on removal
func _register(node: Node2D) -> void:
	var info := _info_for(node.scene_file_path)
	var offset: Vector2 = info["offset"]
	var layer: int = int(info.get("layer", 0))
	var origin := Vector2i(((node.global_position + offset) / tile_size).round())

	var keys: Array[Vector3i] = []
	var max_cell_y := origin.y
	for c in info["cells"]:
		var cell: Vector2i = origin + c
		var key := Vector3i(cell.x, cell.y, layer)
		keys.append(key)
		placed[key] = node
		max_cell_y = maxi(max_cell_y, cell.y)

	node.z_index = -layer # layers still decide front/back groups
	
	var bottom_y := float((max_cell_y + 1) * tile_size)
	node.set_meta("sort_y", bottom_y)
	node.set_meta("layer", layer)

	node.tree_exited.connect(func():
		for k in keys:
			placed.erase(k))

	_resort()

# reorder children so structures with a lower bottom edge are drawn last (on top)
func _resort() -> void:
	var kids := structures_folder.get_children()
	kids.sort_custom(func(a, b):
		var la := int(a.get_meta("layer", 0))
		var lb := int(b.get_meta("layer", 0))
		if la != lb:
			return la < lb # Different layers sort by layer first
		
		var ya := float(a.get_meta("sort_y", 0.0))
		var yb := float(b.get_meta("sort_y", 0.0))
		return ya < yb)
		
	for i in kids.size():
		if kids[i].get_index() != i:   # only move what actually changed
			structures_folder.move_child(kids[i], i)
