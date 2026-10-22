extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var rate_label: Label = %RateLabel

var _last_money: int = 0
var _gained := 0 # money earned during the current window
var _window := 0.0
var _rate := 0.0

func _ready() -> void:
	_last_money = Globals.money

func _process(delta: float) -> void:
	var money: int = Globals.money
	money_label.text = "$%d" % money
	rate_label.text = "+$%.1f/min" % _rate

	# only count increases, so spending on structures doesn't show as negative income
	if money > _last_money:
		_gained += money - _last_money
	_last_money = money

	# average over a 1 second window so the number doesn't jitter
	_window += delta
	if _window >= 1.0:
		_rate = _gained * 60.0
		_gained = 0
		_window = 0.0
		rate_label.text = "+$%.1f/min" % _rate
