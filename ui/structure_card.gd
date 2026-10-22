extends Button

signal picked(structure_scene: PackedScene, cost: int)

const PREVIEW_SIZE := Vector2i(96, 64)

@export var structure_scene: PackedScene
@export var cost := 50

@onready var viewport: SubViewport = %Viewport
@onready var price_label: Label = %Price

func _ready() -> void:
	price_label.text = "$%d" % cost
	_build_preview()

	var t := Timer.new()
	t.wait_time = 0.1
	t.autostart = true
	t.timeout.connect(_refresh)
	add_child(t)
	_refresh()

func _refresh() -> void:
	var affordable: bool = Globals.money >= cost
	price_label.add_theme_color_override("font_color", Color.GREEN if affordable else Color.RED)

func _pressed() -> void:
	picked.emit(structure_scene, cost)

func _build_preview() -> void:
	if structure_scene == null:
		return
	viewport.size = PREVIEW_SIZE
	var inst := structure_scene.instantiate() as Node2D
	inst.process_mode = Node.PROCESS_MODE_DISABLED  # previews must not earn money

	var layer := _find_layer(inst)
	if layer == null or layer.tile_set == null:
		inst.free()
		return
	var used := layer.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		inst.free()
		return

	# painted area in the structure's own coordinates (layer position included)
	var tile := Vector2(layer.tile_set.tile_size)
	var origin := layer.position + Vector2(used.position) * tile
	var size := Vector2(used.size) * tile

	var s := minf(PREVIEW_SIZE.x / size.x, PREVIEW_SIZE.y / size.y)
	inst.scale = Vector2(s, s)
	inst.position = (Vector2(PREVIEW_SIZE) - size * s) / 2.0 - origin * s
	viewport.add_child(inst)

func _find_layer(n: Node) -> TileMapLayer:
	for c in n.get_children():
		if c is TileMapLayer:
			return c
	return null
