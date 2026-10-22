extends Button

signal picked(structure_scene: PackedScene, cost: int)

const PREVIEW_SIZE := Vector2i(96, 64)

@export var structure_scene: PackedScene
@export var cost := 50

const CANVAS := 1024   # structure must fit within 512 pixels of its origin

@onready var preview_slot: Control = %Preview
@onready var price_label: Label = %Price

func _ready() -> void:
	price_label.text = "$%d" % cost
	_build_preview()
	_set_tooltip()

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

	# render the real structure once into a large transparent viewport
	var vp := SubViewport.new()
	vp.size = Vector2i(CANVAS, CANVAS)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vp)

	var inst := structure_scene.instantiate() as Node2D
	inst.process_mode = Node.PROCESS_MODE_DISABLED  # previews must not earn money
	inst.position = Vector2(CANVAS, CANVAS) / 2.0
	vp.add_child(inst)

	# wait for it to actually draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	var img := vp.get_texture().get_image()
	vp.queue_free()

	# crop to the visible pixels, so offsets and stray empty space vanish
	var r := img.get_used_rect()
	if r.size == Vector2i.ZERO:
		return

	var rect := TextureRect.new()
	rect.texture = ImageTexture.create_from_image(img.get_region(r))
	rect.custom_minimum_size = Vector2(PREVIEW_SIZE)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# swap it in where the old SubViewportContainer was
	var parent := preview_slot.get_parent()
	parent.add_child(rect)
	parent.move_child(rect, preview_slot.get_index())
	preview_slot.queue_free()

func _find_layer(n: Node) -> TileMapLayer:
	for c in n.get_children():
		if c is TileMapLayer:
			return c
	return null

func _set_tooltip() -> void:
	if structure_scene == null:
		return
	var probe := structure_scene.instantiate()
	var inc = probe.get_node_or_null("Income")
	if inc != null:
		var inc_amount = inc.income if "income" in inc else 0.0
		var inc_time = inc.interval if "interval" in inc else (inc.sec if "sec" in inc else 1)
		
		tooltip_text = "Generates $%.1f every %s seconds" % [inc_amount, inc_time]
	else:
		tooltip_text = "Generates no money"
	probe.free()
