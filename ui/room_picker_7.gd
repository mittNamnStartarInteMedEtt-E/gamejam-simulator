extends Control

@onready var room_previews_node = get_node("/root/MainGame/RoomPreviews")
@onready var rooms_node = get_node("/root/MainGame/Rooms")
signal room_bought

func _ready() -> void:
	for button in [get_parent().get_child(1), $Room7Button, $Room8Button, $Room9Button]:
		button.mouse_entered.connect(_on_button_hover.bind(button.name))
		button.mouse_exited.connect(_on_button_exit.bind(button.name))
		button.pressed.connect(_on_button_pressed.bind(button.name))

func _on_button_hover(button_name: String) -> void:
	var instance
	match button_name:
		"Room7Button":
			instance = Globals.room7_scene.instantiate()
		"Room8Button":
			instance = Globals.room8_scene.instantiate()
		"Room9Button":
			instance = Globals.room9_scene.instantiate()
			
	if "Room" in button_name:
		room_previews_node.add_child(instance)
		instance.position = Globals.room_location_to_build_7 + Vector2(-208, -272)
		instance.modulate = Color(0.5, 1, 0.5, 0.5)

func _on_button_exit(button_name: String) -> void:
	if "Room" in button_name:
		room_previews_node.get_child(-1).queue_free()

func _on_button_pressed(button_name: String) -> void:
	var instance
	match button_name:
		"CloseButton":
			get_parent().queue_free()
		"Room7Button":
			instance = Globals.room7_scene.instantiate()
		"Room8Button":
			instance = Globals.room8_scene.instantiate()
		"Room9Button":
			instance = Globals.room9_scene.instantiate()
	
	if "Room" in button_name:
		rooms_node.add_child(instance)
		instance.position = Globals.room_location_to_build_7 + Vector2(-208, -272)
		room_bought.emit()
		get_parent().queue_free()
