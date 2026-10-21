extends Control

signal room_bought

func _ready() -> void:
	for button in [get_parent().get_child(1), $Room2Button, $Room3Button, $Room4Button]:
		button.mouse_entered.connect(_on_button_hover.bind(button.name))
		button.mouse_exited.connect(_on_button_exit.bind(button.name))
		button.pressed.connect(_on_button_pressed.bind(button.name))

func _on_button_hover(button_name: String) -> void:
	match button_name:
		"Room2Button":
			print("show transparent room 2")
		"Room3Button":
			print("show transparent room 3")
		"Room4Button":
			print("show transparent room 4")

func _on_button_exit(button_name: String) -> void:
	match button_name:
		"Room2Button":
			print("hide transparent room 2")
		"Room3Button":
			print("hide transparent room 3")
		"Room4Button":
			print("hide transparent room 4")

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"CloseButton":
			get_parent().queue_free()
		"Room2Button":
			# check for collision with other rooms
			print("Place room 2 at ", Globals.room_location_to_build)

			var instance = Globals.room2_scene.instantiate()
			get_tree().root.add_child(instance)
			instance.position = Globals.room_location_to_build + Vector2(96, -272)
			
			room_bought.emit()
			get_parent().queue_free()
		"Room3Button":
			# check for collision with other rooms
			print("Place room 3 at ", Globals.room_location_to_build)
			
			var instance = Globals.room3_scene.instantiate()
			get_tree().root.add_child(instance)
			instance.position = Globals.room_location_to_build + Vector2(96, -272)
			
			room_bought.emit()
			get_parent().queue_free()
		"Room4Button":
			# check for collision with other rooms
			print("Place room 4 at ", Globals.room_location_to_build)
			
			var instance = Globals.room4_scene.instantiate()
			get_tree().root.add_child(instance)
			instance.position = Globals.room_location_to_build + Vector2(96, -272)
			
			room_bought.emit()
			get_parent().queue_free()
