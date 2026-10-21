
extends Control

func _ready():
	# Menyn ska täcka hela skärmen.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO

	# Bakgrund
	var bakgrund = ColorRect.new()
	bakgrund.name = "Bakgrund"
	bakgrund.color = Color(0.08, 0.03, 0.05, 1.0)
	bakgrund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bakgrund.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bakgrund)
	move_child(bakgrund, 0)

	# Menylayout i mitten
	var layout = VBoxContainer.new()
	layout.name = "MenyLayout"
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-175, -80)
	layout.custom_minimum_size = Vector2(350, 160)
	layout.add_theme_constant_override("separation", 15)
	add_child(layout)

	# Rubrik
	var rubrik = Label.new()
	rubrik.text = "CASINO SIMULATOR"
	rubrik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rubrik.add_theme_font_size_override("font_size", 36)
	rubrik.add_theme_color_override("font_color", Color.GOLD)
	layout.add_child(rubrik)

	# Spela
	var spela = Button.new()
	spela.text = "Spela"
	spela.custom_minimum_size = Vector2(350, 45)
	layout.add_child(spela)
	spela.pressed.connect(_on_spela_pressed)

	# Avsluta
	var avsluta = Button.new()
	avsluta.text = "Avsluta"
	avsluta.custom_minimum_size = Vector2(350, 45)
	layout.add_child(avsluta)
	avsluta.pressed.connect(_on_avsluta_pressed)


func _on_spela_pressed():
	# Dölj menyn och visa spelrummet.
	queue_free()


func _on_avsluta_pressed():
	get_tree().quit()
