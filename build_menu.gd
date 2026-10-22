
extends Control

const TILE_SIZE := Vector2(155, 88)
const TILE_GAP := 10
const MENU_HEIGHT := 230

var items := [
	["Blackjack Table", "BJ"],
	["Casino Cage", "CAGE"],
	["Chips", "CHIPS"],
	["Dice Table", "DICE"],
	["Plant", "PLANT"],
	["Roulette Table", "ROULETTE"],
	["Security Camera", "CAMERA"],
	["Slot Machine 2", "SLOT 2"],
	["Slot Machine", "SLOT"],
	["Empty Slot Machine", "EMPTY"],
	["Trash Can 2", "TRASH 2"],
	["Trash Can", "TRASH"]
]

var scroll: ScrollContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background panel
	var panel := Panel.new()
	panel.name = "BuildMenuPanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_top = -MENU_HEIGHT
	panel.offset_bottom = 0

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#171b22")
	panel_style.border_color = Color("#c9a45c")
	panel_style.border_width_top = 2
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	# Menu title
	var title := Label.new()
	title.text = "BUILD MENU"
	title.position = Vector2(18, -MENU_HEIGHT + 8)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override(
		"font_color", Color("#e9c477")
	)
	add_child(title)

	# Horizontal scrolling area
	scroll = ScrollContainer.new()
	scroll.name = "ItemScroll"
	scroll.anchor_left = 0.0
	scroll.anchor_top = 1.0
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 12
	scroll.offset_top = -MENU_HEIGHT + 42
	scroll.offset_right = -12
	scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scroll)

	# Two rows of six items
	var grid := GridContainer.new()
	grid.name = "Items"
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", TILE_GAP)
	grid.add_theme_constant_override("v_separation", TILE_GAP)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	scroll.add_child(grid)

	for item in items:
		grid.add_child(create_item(item[0], item[1]))


func create_item(item_name: String, code: String) -> Control:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = TILE_SIZE
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#303744")
	normal_style.border_color = Color("#596579")
	normal_style.set_border_width_all(1)
	normal_style.set_corner_radius_all(7)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color("#414b5b")
	hover_style.border_color = Color("#e9c477")
	hover_style.set_border_width_all(2)
	hover_style.set_corner_radius_all(7)

	tile.add_theme_stylebox_override("panel", normal_style)

	# Hover effects
	tile.mouse_entered.connect(
		func():
			tile.add_theme_stylebox_override("panel", hover_style)
	)

	tile.mouse_exited.connect(
		func():
			tile.add_theme_stylebox_override("panel", normal_style)
	)

	# Item content
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 7)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(content)

	# Temporary text icon
	var icon := Label.new()
	icon.text = "[ " + code + " ]"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 19)
	icon.add_theme_color_override(
		"font_color", Color("#e9c477")
	)
	content.add_child(icon)

	# Item name
	var label := Label.new()
	label.text = item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override(
		"font_color", Color("#e4e8ef")
	)
	content.add_child(label)

	return tile


func _input(event: InputEvent) -> void:
	if scroll == null:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll.scroll_horizontal -= 120
			get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll.scroll_horizontal += 120
			get_viewport().set_input_as_handled()
<<<<<<< Updated upstream
=======
	
>>>>>>> Stashed changes
