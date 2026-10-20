class_name PlayerCamera2D
extends Camera2D

@export var speed := 10.0
@export var enable_drag := true
@export var drag_button := MOUSE_BUTTON_LEFT

var _is_dragging := false

func _process(delta: float) -> void:
	_handle_keyboard_movement(delta)

func _unhandled_input(event: InputEvent) -> void:
	if enable_drag:
		_handle_drag_input(event)

func _handle_keyboard_movement(delta: float) -> void:
	# grab keyboard movement
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += dir * (speed / zoom.x)

func _handle_drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == drag_button:
		_is_dragging = event.pressed
	elif event is InputEventMouseMotion and _is_dragging:
		# drag opposite to mouse movement
		position -= event.relative / zoom
