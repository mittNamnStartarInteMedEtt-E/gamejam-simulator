extends Area2D

var gui_scene = preload("res://ui/room_picker_8.tscn")
var gui_instance

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_instance_valid(gui_instance):
				gui_instance.queue_free()
			
			gui_instance = gui_scene.instantiate()
			get_tree().current_scene.add_child(gui_instance)
			gui_instance.global_position = get_global_mouse_position()
			
			Globals.room_location_to_build_8 = global_position
			
			gui_instance.get_child(0).get_child(0).room_bought.connect(_on_room_bought)

func _on_room_bought() -> void:
	get_node("/root/MainGame/PlacementManager").is_placing = false
	get_node("/root/MainGame/PlacementManager").ghost.visible = false
	
	get_parent().get_child(2).queue_free() # Delete left closed door
	queue_free()
