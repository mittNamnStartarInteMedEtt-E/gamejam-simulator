extends AudioStreamPlayer

func _ready() -> void:
	stream = preload("res://assets/music/chiptune_game_jam_soundtrack.mp3")
	volume_db = -8.0
	play()
