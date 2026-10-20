class_name PlacementManager
extends Node2D

@export var tile_size := 16
@export var table_scene: PackedScene

@onready var structures_folder := get_node_or_null("Structures")

var placed := {} 
var local_cells: Array[Vector2i] = []
var ghost: Node2D
var is_placing := false

func _ready() -> void:
	if table_scene == null or structures_folder == null:
		set_process(false)
		set_process_unhandled_input(false)
		return

	ghost = table_scene.instantiate() as Node2D
	ghost.visible = false
	ghost.z_index = 100
	add_child(ghost)

	# read the footprint from the TileMapLayer
	for child in ghost.get_children():
		if child is TileMapLayer:
			local_cells.assign(child.get_used_cells())
			break
	if local_cells.is_empty():
		push_warning("No painted tiles found in the table's TileMapLayer, using a 1x1 footprint")
		local_cells = [Vector2i.ZERO]

	# register structures that already exist
	for child in structures_folder.get_children():
		if child is Node2D:
			_register(child)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_placement_mode"):
		_set_placing(not is_placing)
		get_viewport().set_input_as_handled()
		return

	if is_placing and event is InputEventMouseButton \
			and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_place()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not is_placing:
		return
	var cell := _world_to_cell(get_global_mouse_position())
	ghost.global_position = Vector2(cell * tile_size)
	ghost.modulate = Color(0.5, 1, 0.5, 0.5) if _can_place(cell) else Color(1, 0.4, 0.4, 0.5)

func _set_placing(value: bool) -> void:
	is_placing = value
	ghost.visible = value

func _world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i((pos / tile_size).floor())

# ---- Placement rules live here ----
func _can_place(origin: Vector2i) -> bool:
	for c in local_cells:
		if placed.has(origin + c):
			return false
	return true

func _try_place() -> void:
	var origin := _world_to_cell(get_global_mouse_position())
	if not _can_place(origin):
		return
	var table := table_scene.instantiate() as Node2D
	structures_folder.add_child(table)
	table.global_position = Vector2(origin * tile_size)
	_register(table)

func _register(node: Node2D) -> void:
	var origin := _world_to_cell(node.global_position)
	var cells: Array[Vector2i] = []
	for c in local_cells:
		cells.append(origin + c)
		placed[origin + c] = node
	node.tree_exited.connect(func():
		for c in cells:
			placed.erase(c))
