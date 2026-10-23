extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var rate_label: Label = %RateLabel

const TAU_SECONDS := 120.0  # memory length: longer = steadier but slower to react
const MIN_ELAPSED := 15.0   # don't trust the estimate before this much history

var _last_money: int = 0
var _acc := 0.0             # decayed sum of gains
var _start_time := 0.0
var _last_update := 0.0

func _ready() -> void:
	_start_time = _now()
	_last_update = _start_time
	_last_money = Globals.money
	money_label.text = "$%d" % _last_money
	Globals.changed.connect(_on_money_changed)

func _on_money_changed(new_amount: int) -> void:
	money_label.text = "$%d" % new_amount
	_decay()
	if new_amount > _last_money:
		_acc += new_amount - _last_money
	_last_money = new_amount

func _process(_delta: float) -> void:
	_decay()
	var elapsed := maxf(_now() - _start_time, MIN_ELAPSED)
	# at steady income R, _acc settles at R * TAU * (1 - e^(-elapsed/TAU)).
	# dividing by that factor corrects the underestimate during the first minutes
	var norm := TAU_SECONDS * (1.0 - exp(-elapsed / TAU_SECONDS))
	rate_label.text = "+$%.1f/min" % (_acc / norm * 60.0)

# fade old gains by how much time has passed since the last update
func _decay() -> void:
	var now := _now()
	_acc *= exp(-(now - _last_update) / TAU_SECONDS)
	_last_update = now

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
