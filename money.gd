extends Node

var frame_count := 0

func _process(_delta: float) -> void:
	if frame_count % 60 == 0:
		if Globals.money < -10000:
			print("Player has lost")
	frame_count += 1
