extends Panel

var frame_count := 0

func _process(delta: float) -> void: # Good looking exponential function
	if frame_count > 30:
		position.y -= 2
		if frame_count > 40:
			position.y -= 2
			if frame_count > 50:
				position.y -= 2
				if frame_count > 60:
					position.y -= 2
					if frame_count > 70:
						position.y -= 2
						if frame_count > 80:
							position.y -= 2
							if frame_count > 180:
								get_parent().queue_free()
	frame_count += 1
