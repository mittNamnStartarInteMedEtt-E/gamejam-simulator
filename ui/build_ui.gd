extends CanvasLayer

signal structure_chosen(structure_scene: PackedScene, cost: int)

@onready var cards: HBoxContainer = %Cards

func _ready() -> void:
	visible = false
	for card in cards.get_children():
		card.picked.connect(_on_card_picked)

func _on_card_picked(scene: PackedScene, cost: int) -> void:
	structure_chosen.emit(scene, cost)
