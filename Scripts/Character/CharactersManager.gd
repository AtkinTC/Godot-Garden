extends Node

signal characters_changed()

var characters_dict : Dictionary = {}
var next_char_id : int = 0

func initialize() -> void:
	characters_dict = {}
	next_char_id = 0

func get_character_ids() -> Array:
	return characters_dict.keys()

func get_character_by_id(char_id : int) -> CharacterVO:
	return characters_dict.get(char_id)

func create_empty_character() -> CharacterVO:
	var new_char_id = next_char_id
	next_char_id += 1
	
	var new_char = CharacterVO.new()
	new_char.set_character_id(new_char_id)
	new_char.set_character_portrait_name("portrait_default.png")
	new_char.set_attr_HP(CharAttrDAO.new(CharAttrUtil.ATTR_HP).get_default_value())
	new_char.set_attr_SP(CharAttrDAO.new(CharAttrUtil.ATTR_SP).get_default_value())
	new_char.set_attr_STR(CharAttrDAO.new(CharAttrUtil.ATTR_STR).get_default_value())
	new_char.set_attr_AGI(CharAttrDAO.new(CharAttrUtil.ATTR_AGI).get_default_value())
	new_char.set_attr_INT(CharAttrDAO.new(CharAttrUtil.ATTR_INT).get_default_value())
	new_char.set_current_HP(new_char.attr_HP)
	new_char.set_current_SP(new_char.attr_SP)
	
	characters_dict[new_char_id] = new_char
	new_char.changed.connect(_on_char_changed.bind(new_char_id))
	
	return new_char

func _on_char_changed(char_id : int):
	if(characters_dict.has(char_id)):
		characters_changed.emit()
