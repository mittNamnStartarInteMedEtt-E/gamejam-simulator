extends CanvasLayer

@onready var money_label: Label = %MoneyLabel
@onready var rate_label: Label = %RateLabel

func _ready() -> void:
	_update_money(Globals.money)
	_update_rate(Globals.income_per_minute)
	Globals.changed.connect(_update_money)
	Globals.income_rate_changed.connect(_update_rate)

func _update_money(amount: int) -> void:
	money_label.text = "$%d" % amount

func _update_rate(per_minute: float) -> void:
	rate_label.text = "+$%.1f/min" % per_minute
