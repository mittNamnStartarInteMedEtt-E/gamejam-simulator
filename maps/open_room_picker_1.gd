extends Area2D

var gui_scene = preload("res://ui/room_picker.tscn")
var gui_instance

# Called when the node enters  the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_instance_valid(gui_instance):
				gui_instance.queue_free()

			gui_instance = gui_scene.instantiate()
			get_tree().current_scene.add_child(gui_instance)
			gui_instance.global_position = get_global_mouse_position()
			
			Globals.room_location_to_build = global_position
