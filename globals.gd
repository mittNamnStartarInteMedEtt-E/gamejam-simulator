extends Node

var room_location_to_build = null
var room_location_to_build_2 = null
var room_location_to_build_3 = null
var room_location_to_build_4 = null
var room_location_to_build_7 = null
var room_location_to_build_8 = null
var room_location_to_build_9 = null

var room_location_to_build_center = null
var room_location_to_build_2_center = null
var room_location_to_build_3_center = null
var room_location_to_build_4_center = null # unused?
var room_location_to_build_5_center = null
var room_location_to_build_7_center = null
var room_location_to_build_8_center = null
var room_location_to_build_10_center = null
var room_location_to_build_11_center = null

var room_location_to_build_1_left = null

var room2_scene = load("res://maps/room2.tscn")
var room3_scene = load("res://maps/room3.tscn")
var room4_scene = load("res://maps/room4.tscn")
var room5_scene = load("res://maps/room5.tscn")
var room6_scene = load("res://maps/room6.tscn")
var room7_scene = load("res://maps/room7.tscn")
var room8_scene = load("res://maps/room8.tscn")
var room9_scene = load("res://maps/room9.tscn")
var room10_scene = load("res://maps/room10.tscn")
var room11_scene = load("res://maps/room11.tscn")

var center_room_cost := 15000
var side_room_cost := 20000

signal changed(new_amount: int)

var money := 10000:
	set(value):
		money = max(value, 0)
		changed.emit(money)

func can_afford(cost: int) -> bool:
	return money >= cost

func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	money -= cost
	return true

func add(value: int) -> void:
	money += value
var frame_count := 0
var gui_scene = load("res://ui/too_expensive-popup.tscn")

func _process(_delta: float) -> void:
	if frame_count % 60 == 0:
		if money < -10000:
			print("Player has lost")
	frame_count += 1

func _too_expensive():
	var gui_instance = gui_scene.instantiate()
	get_node("/root/MainGame/Player").add_child(gui_instance)
