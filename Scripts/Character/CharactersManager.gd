extends Node

signal characters_changed()

var characters_dict : Dictionary = {}
var next_id : int = 0

func initialize() -> void:
	reset()

func reset() -> void:
	characters_dict = {}
	next_id = 0

func setup_from_character_array(characters : Array):
	reset()
	for i in characters.size():
		var character : CharacterVO = characters[i]
		insert_character(character)

func get_characters() -> Array:
	return characters_dict.values()

func get_character_ids() -> Array:
	return characters_dict.keys()

func get_character_by_id(char_id : int) -> CharacterVO:
	return characters_dict.get(char_id)

func create_new_character() -> CharacterVO:
	var new_id = next_id
	next_id += 1
	
	var charVO = CharacterVO.new()
	charVO.set_id(new_id)
	charVO.set_portrait_name("portrait_default.png")
	charVO.set_attr_HP(CharAttrDAO.new(CharAttrUtil.ATTR_HP).get_default_value())
	charVO.set_attr_SP(CharAttrDAO.new(CharAttrUtil.ATTR_SP).get_default_value())
	charVO.set_attr_STR(CharAttrDAO.new(CharAttrUtil.ATTR_STR).get_default_value())
	charVO.set_attr_AGI(CharAttrDAO.new(CharAttrUtil.ATTR_AGI).get_default_value())
	charVO.set_attr_INT(CharAttrDAO.new(CharAttrUtil.ATTR_INT).get_default_value())
	charVO.set_current_HP(charVO.attr_HP)
	charVO.set_current_SP(charVO.attr_SP)
	
	insert_character(charVO)
	
	return charVO

func insert_character(charVO : CharacterVO):
	next_id = max(next_id, charVO.get_id() + 1)
	
	characters_dict[charVO.get_id()] = charVO
	charVO.changed.connect(_on_char_changed.bind(charVO.get_id()))
	characters_changed.emit()

func _on_char_changed(char_id : int):
	if(characters_dict.has(char_id)):
		characters_changed.emit()
