extends Node

var frame_count := 0
var gui_scene = load("res://ui/too_expensive-popup.tscn")

func _process(_delta: float) -> void:
	if frame_count % 60 == 0:
		if Globals.money < -10000:
			print("Player has lost")
	frame_count += 1

func _too_expensive():
	var gui_instance = gui_scene.instantiate()
	get_node("/root/MainGame/Player").add_child(gui_instance)
