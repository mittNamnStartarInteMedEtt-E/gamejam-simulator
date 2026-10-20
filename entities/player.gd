extends Area2D

@export var bomb_scene: PackedScene
@export var speed: float = 32.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Vector2(0.0, 0.0)
	var anim_name: String
	if Input.is_action_pressed("move_up"):
		direction.y -= 1.0
		anim_name = "walk_up"
	if Input.is_action_pressed("move_down"):
		direction.y += 1.0
		anim_name = "walk_down"
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
		anim_name = "walk_left"
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
		anim_name = "walk_right"
	
	direction = direction.normalized()
	var velocity = direction * speed
		
	if anim_name:
		$AnimatedSprite2D.play(anim_name)
	else:
		$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
		
	global_position += velocity * delta

	if Input.is_action_just_pressed("place_bomb"):
		var bomb = bomb_scene.instantiate()
		bomb.global_position = position + direction * 12.0
		get_tree().current_scene.add_child(bomb)
