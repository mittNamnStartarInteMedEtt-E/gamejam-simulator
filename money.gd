extends Node

var gui_scene = load("res://ui/too_expensive-popup.tscn")

func _too_expensive():
	var gui_instance = gui_scene.instantiate()
	get_node("/root/MainGame/Player").add_child(gui_instance)
