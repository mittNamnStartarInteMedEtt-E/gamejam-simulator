extends Node2D

@onready var layers: Array[TileMapLayer] = [
	$RedFloor,
	$VerticalStripedFloor,
	$HorizontalStripedFloor,
	$BlueFloor
]

var current_layer_index: int = -1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("floor_change"):

		var mouse_pos = get_global_mouse_position()
		var hovering_over_tile := false

		for layer in layers:
			var local_mouse_pos = layer.to_local(mouse_pos)
			var tile_pos = layer.local_to_map(local_mouse_pos)
			if layer.get_cell_source_id(tile_pos) != -1:
				hovering_over_tile = true
				break

		if not hovering_over_tile:
			return

		current_layer_index = (
			current_layer_index + 1
		) % layers.size()

		for i in range(layers.size()):
			layers[i].visible = (i == current_layer_index)

		get_viewport().set_input_as_handled()
