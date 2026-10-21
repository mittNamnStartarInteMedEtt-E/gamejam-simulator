class_name PlayerCamera2D
extends Camera2D

@export var speed := 10.0
@export var enable_drag := true
@export var drag_action := "scroll_click"

@export var enable_zoom := true
@export var zoom_step := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 4.0

var _is_dragging := false

func _process(delta: float) -> void:
	_handle_keyboard_movement(delta)

func _unhandled_input(event: InputEvent) -> void:
	if enable_drag:
		_handle_drag_input(event)
	if enable_zoom:
		_handle_zoom_input(event)

func _handle_keyboard_movement(delta: float) -> void:
	# grab keyboard movement
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += dir * (speed / zoom.x)

func _handle_drag_input(event: InputEvent) -> void:
	if event.is_action(drag_action):
		_is_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and _is_dragging:
		# drag opposite to mouse movement
		position -= event.relative / zoom

func _handle_zoom_input(event: InputEvent) -> void:
	var new_zoom := zoom.x
	if event.is_action_pressed("scroll_up"):
		new_zoom += zoom_step
	elif event.is_action_pressed("scroll_down"):
		new_zoom -= zoom_step
	else:
		return
	new_zoom = clampf(new_zoom, min_zoom, max_zoom)
	
	# world point under the cursor before zooming
	var mouse_before := get_global_mouse_position()
	zoom = Vector2(new_zoom, new_zoom)
	# world point under the cursor after zooming
	var mouse_after := get_global_mouse_position()
	# move the camera by the drift so the point under the cursor stays put
	position += mouse_before - mouse_after
