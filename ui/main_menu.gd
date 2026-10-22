extends CanvasLayer

func _ready() -> void:
	layer = 100  # draw above everything, including the build UI

	# Screen-space root that fills the window
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Background (black)
	var bakgrund := ColorRect.new()
	bakgrund.name = "Bakgrund"
	bakgrund.color = Color.BLACK
	bakgrund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bakgrund.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(bakgrund)

	# Menu layout in the middle
	var layout := VBoxContainer.new()
	layout.name = "MenyLayout"
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-175, -80)
	layout.custom_minimum_size = Vector2(350, 160)
	layout.add_theme_constant_override("separation", 15)
	root.add_child(layout)

	# Title
	var rubrik := Label.new()
	rubrik.text = "CASINO SIMULATOR"
	rubrik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rubrik.add_theme_font_size_override("font_size", 36)
	rubrik.add_theme_color_override("font_color", Color.GOLD)
	layout.add_child(rubrik)

	# Play
	var spela := Button.new()
	spela.text = "Spela"
	spela.custom_minimum_size = Vector2(350, 45)
	layout.add_child(spela)
	spela.pressed.connect(_on_spela_pressed)

	# Quit
	var avsluta := Button.new()
	avsluta.text = "Avsluta"
	avsluta.custom_minimum_size = Vector2(350, 45)
	layout.add_child(avsluta)
	avsluta.pressed.connect(_on_avsluta_pressed)

func _on_spela_pressed() -> void:
	queue_free()

func _on_avsluta_pressed() -> void:
	get_tree().quit()
