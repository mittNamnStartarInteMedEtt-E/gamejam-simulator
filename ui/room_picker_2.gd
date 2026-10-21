extends Control


func _ready() -> void:
	for button in [$Room2Button, $Room3Button]:
		button.mouse_entered.connect(_on_button_hover.bind(button.name))
		button.mouse_exited.connect(_on_button_exit.bind(button.name))
		button.pressed.connect(_on_button_pressed.bind(button.name))

func _on_button_hover(button_name: String) -> void:
	match button_name:
		"Room2Button":
			print("show transparent room 2")
		"Room3Button":
			print("show transparent room 3")

func _on_button_exit(button_name: String) -> void:
	match button_name:
		"Room2Button":
			print("hide transparent room 2")
		"Room3Button":
			print("hide transparent room 3")

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"Room2Button":
			# check for collision with other rooms
			print("Place room 2 at ", Globals.room_location_to_build_2)

			var instance = Globals.room2_scene.instantiate()
			get_tree().root.add_child(instance)
			instance.position = Globals.room_location_to_build_2 + Vector2(96, -272)

			print("open door")
			get_parent().queue_free()
		"Room3Button":
			# check for collision with other rooms
			print("Place room 3 at ", Globals.room_location_to_build_2)
			
			var instance = Globals.room3_scene.instantiate()
			get_tree().root.add_child(instance)
			instance.position = Globals.room_location_to_build_2 + Vector2(96, -272)
			print("open door")
			get_parent().queue_free()
