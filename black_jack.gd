
extends Control

var balance: int = 1000
var bet: int = 100
var deck: Array[Dictionary] = []
var player_hand: Array[Dictionary] = []
var dealer_hand: Array[Dictionary] = []
var round_over := false
var game_started := false

var balance_label: Label
var bet_label: Label
var player_cards: HBoxContainer
var dealer_cards: HBoxContainer
var player_score: Label
var dealer_score: Label
var message_label: Label
var hit_button: Button
var stand_button: Button
var next_button: Button
var minus_button: Button
var plus_button: Button
var dealer_portrait: Control


class PixelDealer extends Control:
	func _draw() -> void:
		# En enkel pixelerad dealer, ritad direkt i Godot.
		var skin := Color("#e5a783")
		var hair := Color("#543020")
		var shirt := Color("#eee7d9")
		var vest := Color("#29252b")
		var gold := Color("#e9b64e")
		var dark := Color("#17171b")

		var pixels := [
			[5, 0, 7, 2, hair],
			[3, 1, 11, 2, hair],
			[2, 3, 12, 3, skin],
			[4, 2, 8, 1, skin],
			[3, 3, 2, 2, hair],
			[12, 3, 2, 2, hair],
			[5, 4, 2, 1, dark],
			[10, 4, 2, 1, dark],
			[7, 5, 2, 1, dark],
			[6, 6, 4, 1, skin],
			[5, 7, 6, 2, shirt],
			[2, 9, 12, 5, vest],
			[0, 10, 3, 4, shirt],
			[13, 10, 3, 4, shirt],
			[6, 9, 4, 3, shirt],
			[7, 10, 2, 2, dark],
			[4, 13, 3, 2, skin],
			[9, 13, 3, 2, skin],
			[7, 13, 2, 2, gold]
		]

		var pixel_size := 12.0

		for p in pixels:
			draw_rect(
				Rect2(
					Vector2(float(p[0]) * pixel_size,
					float(p[1]) * pixel_size),
					Vector2(float(p[2]) * pixel_size,
					float(p[3]) * pixel_size)
				),
				p[4]
			)


func _ready() -> void:
	_build_interface()
	_start_round()


func _build_interface() -> void:
	# Bakgrund
	var background := ColorRect.new()
	background.color = Color("#24140f")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Dekorativt mörkt trä bakom bordet
	var wood := ColorRect.new()
	wood.color = Color("#382018")
	wood.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wood)

	# Bordets ram
	var table_frame := Panel.new()
	table_frame.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	table_frame.offset_left = 35
	table_frame.offset_top = 175
	table_frame.offset_right = -35
	table_frame.offset_bottom = -30

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("#4b2919")
	frame_style.border_color = Color("#a87835")
	frame_style.set_border_width_all(8)
	frame_style.set_corner_radius_all(100)
	table_frame.add_theme_stylebox_override(
		"panel", frame_style
	)
	add_child(table_frame)

	# Grön spelyta
	var felt := Panel.new()
	felt.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	felt.offset_left = 65
	felt.offset_top = 205
	felt.offset_right = -65
	felt.offset_bottom = -65

	var felt_style := StyleBoxFlat.new()
	felt_style.bg_color = Color("#07502f")
	felt_style.border_color = Color("#b58a3d")
	felt_style.set_border_width_all(3)
	felt_style.set_corner_radius_all(90)
	felt.add_theme_stylebox_override("panel", felt_style)
	add_child(felt)

	# Titel
	var title := Label.new()
	title.text = "BLACKJACK"
	title.position = Vector2(65, 30)
	title.size = Vector2(520, 100)
	title.add_theme_font_size_override("font_size", 62)
	title.add_theme_color_override(
		"font_color", Color("#ffd15c")
	)
	add_child(title)

	# Saldo uppe till höger
	var balance_panel := PanelContainer.new()
	balance_panel.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_RIGHT
	)
	balance_panel.offset_left = -370
	balance_panel.offset_top = 30
	balance_panel.offset_right = -45
	balance_panel.offset_bottom = 120

	var balance_style := StyleBoxFlat.new()
	balance_style.bg_color = Color("#151719")
	balance_style.border_color = Color("#d5a342")
	balance_style.set_border_width_all(3)
	balance_style.set_corner_radius_all(12)
	balance_panel.add_theme_stylebox_override(
		"panel", balance_style
	)
	add_child(balance_panel)

	balance_label = Label.new()
	balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	balance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	balance_label.add_theme_font_size_override("font_size", 28)
	balance_label.add_theme_color_override(
		"font_color", Color("#ffd15c")
	)
	balance_panel.add_child(balance_label)

	# Dealerporträtt
	dealer_portrait = PixelDealer.new()
	dealer_portrait.custom_minimum_size = Vector2(192, 180)
	dealer_portrait.position = Vector2(
		(get_viewport_rect().size.x - 192) / 2.0,
		115
	)
	dealer_portrait.scale = Vector2(0.75, 0.75)
	dealer_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dealer_portrait)

	var dealer_title := _make_label("DEALER", 26)
	dealer_title.position = Vector2(0, 275)
	dealer_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dealer_title.offset_top = 0
	dealer_title.offset_bottom = 40
	add_child(dealer_title)

	dealer_cards = HBoxContainer.new()
	dealer_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	dealer_cards.add_theme_constant_override("separation", 14)
	dealer_cards.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dealer_cards.offset_top = 315
	dealer_cards.offset_bottom = 435
	add_child(dealer_cards)

	dealer_score = _make_label("", 22)
	dealer_score.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dealer_score.offset_top = 435
	dealer_score.offset_bottom = 470
	add_child(dealer_score)

	# Meddelande
	message_label = _make_label("", 22)
	message_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	message_label.offset_top = 475
	message_label.offset_bottom = 515
	message_label.add_theme_color_override(
		"font_color", Color("#ffd15c")
	)
	add_child(message_label)

	# Spelarens kort
	var player_title := _make_label("DINA KORT", 26)
	player_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	player_title.offset_top = 520
	player_title.offset_bottom = 555
	add_child(player_title)

	player_cards = HBoxContainer.new()
	player_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	player_cards.add_theme_constant_override("separation", 14)
	player_cards.set_anchors_preset(Control.PRESET_TOP_WIDE)
	player_cards.offset_top = 560
	player_cards.offset_bottom = 680
	add_child(player_cards)

	player_score = _make_label("", 22)
	player_score.set_anchors_preset(Control.PRESET_TOP_WIDE)
	player_score.offset_top = 680
	player_score.offset_bottom = 715
	add_child(player_score)

	# Insatskontroller
	var bet_row := HBoxContainer.new()
	bet_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bet_row.add_theme_constant_override("separation", 12)
	bet_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bet_row.offset_top = 720
	bet_row.offset_bottom = 790
	add_child(bet_row)

	minus_button = _make_button("- 50", "#222831")
	minus_button.custom_minimum_size = Vector2(90, 60)
	minus_button.pressed.connect(_change_bet.bind(-50))
	bet_row.add_child(minus_button)

	bet_label = Label.new()
	bet_label.custom_minimum_size = Vector2(260, 60)
	bet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bet_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bet_label.add_theme_font_size_override("font_size", 28)
	bet_label.add_theme_color_override(
		"font_color", Color("#ffd15c")
	)
	bet_row.add_child(bet_label)

	plus_button = _make_button("+ 50", "#222831")
	plus_button.custom_minimum_size = Vector2(90, 60)
	plus_button.pressed.connect(_change_bet.bind(50))
	bet_row.add_child(plus_button)

	# Spelknappar
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 18)
	actions.set_anchors_preset(Control.PRESET_TOP_WIDE)
	actions.offset_top = 800
	actions.offset_bottom = 880
	add_child(actions)

	hit_button = _make_button("DRA KORT", "#16723b")
	hit_button.custom_minimum_size = Vector2(300, 75)
	hit_button.pressed.connect(_hit)
	actions.add_child(hit_button)

	stand_button = _make_button("STANNA", "#8e252b")
	stand_button.custom_minimum_size = Vector2(300, 75)
	stand_button.pressed.connect(_stand)
	actions.add_child(stand_button)

	next_button = _make_button("NÄSTA RUNDA", "#174b80")
	next_button.custom_minimum_size = Vector2(300, 75)
	next_button.pressed.connect(_start_round)
	actions.add_child(next_button)


func _make_label(text_value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override(
		"font_color", Color("#f5eee0")
	)
	return label


func _make_button(text_value: String, color_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", 24)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color_value)
	normal.border_color = Color("#d6a54b")
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 12
	normal.content_margin_right = 12

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(color_value).lightened(0.18)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override(
		"font_color", Color("#ffffff")
	)
	button.add_theme_color_override(
		"font_hover_color", Color("#ffe19a")
	)

	return button


func _create_deck() -> void:
	deck.clear()

	var suits: Array[String] = ["♠", "♥", "♦", "♣"]
	var ranks: Array[String] = [
		"A", "2", "3", "4", "5", "6", "7",
		"8", "9", "10", "J", "Q", "K"
	]

	for suit in suits:
		for rank in ranks:
			var value := 0

			match rank:
				"A":
					value = 11
				"J", "Q", "K":
					value = 10
				_:
					value = int(rank)

			deck.append({
				"rank": rank,
				"suit": suit,
				"value": value
			})

	deck.shuffle()


func _draw_card(hand: Array[Dictionary]) -> void:
	if deck.is_empty():
		_create_deck()

	hand.append(deck.pop_back())


func _hand_value(hand: Array[Dictionary]) -> int:
	var total := 0
	var aces := 0

	for card in hand:
		total += int(card["value"])
		if card["rank"] == "A":
			aces += 1

	while total > 21 and aces > 0:
		total -= 10
		aces -= 1

	return total


func _make_card(card: Dictionary, hidden: bool = false) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(85, 116)

	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(5)
	style.set_border_width_all(3)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 30)

	if hidden:
		style.bg_color = Color("#9e292b")
		style.border_color = Color("#f3d29a")
		label.text = "✦\n✦"
		label.add_theme_color_override(
			"font_color", Color("#ffd15c")
		)
	else:
		style.bg_color = Color("#fff4df")
		style.border_color = Color("#171717")
		label.text = "%s\n%s" % [
			card["rank"], card["suit"]
		]

		var red_suit: bool = card["suit"] == "♥" or card["suit"] == "♦"
		label.add_theme_color_override(
			"font_color",
			Color("#d52d35") if red_suit else Color("#171717")
		)

	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	return panel


func _update_ui() -> void:
	balance_label.text = "DINA MARKER\n$%d" % balance
	bet_label.text = "INSATS: $%d" % bet

	for child in player_cards.get_children():
		child.queue_free()

	for card in player_hand:
		player_cards.add_child(_make_card(card))

	for child in dealer_cards.get_children():
		child.queue_free()

	for i in range(dealer_hand.size()):
		var hidden := not round_over and i == 1
		dealer_cards.add_child(_make_card(dealer_hand[i], hidden))

	player_score.text = "SUMMA: %d" % _hand_value(player_hand)

	if round_over:
		dealer_score.text = "SUMMA: %d" % _hand_value(dealer_hand)
	else:
		dealer_score.text = "SUMMA: ?"

	minus_button.disabled = not round_over or bet <= 50
	plus_button.disabled = not round_over or bet + 50 > balance
	hit_button.disabled = round_over
	stand_button.disabled = round_over
	next_button.disabled = not round_over or balance < 50


func _start_round() -> void:
	if balance < 50:
		message_label.text = "Du har slut på marker!"
		return

	bet = clampi(bet, 50, balance)
	player_hand.clear()
	dealer_hand.clear()
	round_over = false
	game_started = true

	_create_deck()
	_draw_card(player_hand)
	_draw_card(dealer_hand)
	_draw_card(player_hand)
	_draw_card(dealer_hand)

	message_label.text = "Din tur! Dra kort eller stanna."

	if _hand_value(player_hand) == 21:
		_finish_round()
	else:
		_update_ui()


func _hit() -> void:
	if round_over:
		return

	_draw_card(player_hand)

	if _hand_value(player_hand) >= 21:
		_finish_round()
	else:
		message_label.text = "Vill du dra ett kort till eller stanna?"

	_update_ui()


func _stand() -> void:
	if round_over:
		return

	while _hand_value(dealer_hand) < 17:
		_draw_card(dealer_hand)

	_finish_round()
	_update_ui()


func _finish_round() -> void:
	if round_over:
		return

	round_over = true

	var player_total := _hand_value(player_hand)
	var dealer_total := _hand_value(dealer_hand)

	if player_total > 21:
		balance -= bet
		message_label.text = "Du blev tjock! Du förlorade $%d." % bet
	elif player_total == 21 and player_hand.size() == 2:
		if dealer_total == 21 and dealer_hand.size() == 2:
			message_label.text = "Oavgjort! Insatsen återbetalas."
		else:
			balance += int(round(float(bet) * 1.5))
			message_label.text = "BLACKJACK! Du vann $%d!" % int(round(float(bet) * 1.5))
	elif dealer_total > 21:
		balance += bet
		message_label.text = "Dealern blev tjock! Du vann $%d." % bet
	elif player_total > dealer_total:
		balance += bet
		message_label.text = "Du vann $%d!" % bet
	elif player_total < dealer_total:
		balance -= bet
		message_label.text = "Du förlorade $%d." % bet
	else:
		message_label.text = "Oavgjort! Insatsen återbetalas."

	_update_ui()


func _change_bet(amount: int) -> void:
	if not round_over:
		return

	bet = clampi(bet + amount, 50, balance)
	_update_ui()
