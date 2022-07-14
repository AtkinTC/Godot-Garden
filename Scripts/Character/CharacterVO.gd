class_name CharacterVO
extends Resource

@export var char_id : int = -1
@export var char_name : String
@export var char_portrait_name : String

@export var attr_HP : float
@export var attr_SP : float
@export var attr_STR : float
@export var attr_AGI : float
@export var attr_INT : float

@export var current_HP : float
@export var current_SP : float

func set_id(_id : int):
	char_id = _id
	emit_signal("changed")

func set_character_name(_name : String):
	char_name = _name
	emit_signal("changed")

func set_portrait_name(_portrait_name : String):
	char_portrait_name = _portrait_name
	emit_signal("changed")

func set_attr_HP(_attr_HP : float):
	attr_HP = _attr_HP
	emit_signal("changed")

func set_attr_SP(_attr_SP : float):
	attr_SP = _attr_SP
	emit_signal("changed")

func set_attr_STR(_attr_STR : float):
	attr_STR = _attr_STR
	emit_signal("changed")

func set_attr_AGI(_attr_AGI : float):
	attr_AGI = _attr_AGI
	emit_signal("changed")

func set_attr_INT(_attr_INT : float):
	attr_INT = _attr_INT
	emit_signal("changed")

func set_current_HP(_current_HP : float):
	current_HP = _current_HP
	emit_signal("changed")

func set_current_SP(_current_SP : float):
	current_SP = _current_SP
	emit_signal("changed")

func get_id() -> int:
	return char_id

func get_character_name() -> String:
	return char_name

func get_portrait_name() -> String:
	return char_portrait_name

func get_attr_HP() -> float:
	return attr_HP

func get_attr_SP() -> float:
	return attr_SP

func get_attr_STR() -> float:
	return attr_STR

func get_attr_AGI() -> float:
	return attr_AGI

func get_attr_INT() -> float:
	return attr_INT

func get_current_HP() -> float:
	return current_HP

func get_current_SP() -> float:
	return current_SP
