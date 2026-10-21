
extends Control

func _ready():
	var bakgrund = ColorRect.new()
	bakgrund.color = Color(0.08, 0.03, 0.05, 1.0)
	bakgrund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bakgrund)

	var layout = VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-150, -100)
	layout.custom_minimum_size = Vector2(300, 200)
	layout.add_theme_constant_override("separation", 15)
	add_child(layout)

	var rubrik = Label.new()
	rubrik.text = "CASINO SIMULATOR"
	rubrik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rubrik.add_theme_font_size_override("font_size", 36)
	rubrik.add_theme_color_override("font_color", Color.GOLD)
	layout.add_child(rubrik)

	var spela = Button.new()
	spela.text = "Spela"
	layout.add_child(spela)
	spela.pressed.connect(_on_spela_pressed)

	var installningar = Button.new()
	installningar.text = "Inställningar"
	layout.add_child(installningar)

	var avsluta = Button.new()
	avsluta.text = "Avsluta"
	layout.add_child(avsluta)
	avsluta.pressed.connect(_on_avsluta_pressed)

func _on_spela_pressed():
	print("Spelet startar!")

func _on_avsluta_pressed():
	get_tree().quit()
