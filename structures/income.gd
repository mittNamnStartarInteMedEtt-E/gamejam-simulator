extends Node

@export var income := 5 
@export var interval := 2.0

var _t := 0.0

func _process(delta: float) -> void:
	if interval <= 0.0:
		return
	
	_t += delta
	if _t >= interval:
		_t -= interval
		Globals.add(income)
