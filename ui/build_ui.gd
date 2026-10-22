extends CanvasLayer

signal structure_chosen(structure_scene: PackedScene, cost: int)

@onready var cards: HBoxContainer = %Cards

func _ready() -> void:
	visible = false
	
	for card in cards.get_children():
		card.picked.connect(_on_card_picked)
		
	# Sort the cards by cost (cheapest to most expensive)
	_sort_cards()

func _sort_cards() -> void:
	var card_list := cards.get_children()
	
	# Sort custom: compares the 'cost' variable on your button scripts
	card_list.sort_custom(func(a, b):
		return a.cost < b.cost
	)
	
	# Re-apply the sorted order to the HBoxContainer
	for i in card_list.size():
		cards.move_child(card_list[i], i)

func _on_card_picked(scene: PackedScene, cost: int) -> void:
	structure_chosen.emit(scene, cost)
