extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var rate_label: Label = %RateLabel

var _last_money: int = 0
var _recent_gained := 0.0
var _display_rate := 0.0
var _timer := 0.0

func _ready() -> void:
	_last_money = Globals.money

func _process(delta: float) -> void:
	var money: int = Globals.money
	money_label.text = "$%d" % money

	if money > _last_money:
		_recent_gained += (money - _last_money)
	_last_money = money

	_timer += delta
	# Updates every 3 seconds smoothly without dividing by delta
	if _timer >= 3.0:
		var per_minute = (_recent_gained / _timer) * 60.0
		_display_rate = lerp(_display_rate, per_minute, 0.8)
		_recent_gained = 0.0
		_timer = 0.0

	rate_label.text = "+$%.1f/min" % _display_rate
