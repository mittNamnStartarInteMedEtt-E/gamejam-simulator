extends Area2D

@export var explosion_scene = preload("res://entities/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FuseTimer.start(3.0)
	$AnimatedSprite2D.play("bomb_fuse")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fuse_timer_timeout() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()
