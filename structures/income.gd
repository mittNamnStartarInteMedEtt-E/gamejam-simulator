extends Node

@export var income := 5:
	set(value):
		_unregister()
		income = value
		_register()
@export var interval := 2.0:
	set(value):
		_unregister()
		interval = value
		_register()

# toggles for the two visual effects
@export var show_screen_popup := true
@export var show_building_effect := true

const POPUP_LAYER_GROUP := "income_popup_layer"

var _t := 0.0
var _registered := false

func _ready() -> void:
	_register()

func _exit_tree() -> void:
	_unregister()

func _process(delta: float) -> void:
	if interval <= 0.0:
		return
	_t += delta
	if _t >= interval:
		_t -= interval
		Globals.add(income)
		if show_building_effect:
			_play_building_effect()
		if show_screen_popup:
			_play_screen_popup()

func _register() -> void:
	# skip if already counted, not in the tree yet, or disabled (ghost/templates)
	if _registered or not is_inside_tree() or not can_process():
		return
	Globals.register_income(income, interval)
	_registered = true

func _unregister() -> void:
	if not _registered:
		return
	Globals.unregister_income(income, interval)
	_registered = false

func _play_building_effect() -> void:
	var building := get_parent() as Node2D
	if building == null or building.get_parent() == null:
		return

	var label := Label.new()
	label.text = "+$%d" % income
	label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	label.add_theme_font_size_override("font_size", 8)
	label.z_index = 50
	# added to the building's parent so it survives if the building is removed mid-animation
	building.get_parent().add_child(label)
	label.global_position = building.global_position + Vector2(randf_range(0.0, 16.0), -8.0)

	var tween := label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 16.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

# ---- floating "+$X" in the top right of the screen ----
func _play_screen_popup() -> void:
	var layer := _get_popup_layer()
	var label := Label.new()
	label.text = "+$%d" % income
	label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	label.add_theme_font_size_override("font_size", 14)
	layer.add_child(label)
	label.reset_size()

	# small random shift so simultaneous payouts don't sit exactly on top of each other
	var screen := get_viewport().get_visible_rect().size
	label.position = Vector2(
		screen.x - label.size.x - 16.0 - randf_range(0.0, 20.0),
		48.0 + randf_range(0.0, 8.0))

	var tween := label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 24.0, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.chain().tween_callback(label.queue_free)

# one shared CanvasLayer for all buildings, created on first use
func _get_popup_layer() -> CanvasLayer:
	var existing := get_tree().get_first_node_in_group(POPUP_LAYER_GROUP)
	if existing:
		return existing as CanvasLayer
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(POPUP_LAYER_GROUP)
	get_tree().root.add_child(layer)
	return layer
