class_name ExplorationVO
extends Resource

var char_id : int
var character : CharacterVO

var area_id : int
var area : AreaVO

var stage_progress : float

## char_id ##
func set_char_id(_char_id : int) -> void:
	if(char_id != _char_id):
		char_id = _char_id
		#TODO: set_exp_area(AreaManager.get_area_by_id(exp_area_id))

func get_char_id() -> int:
	return char_id

## character ##
func set_character(_character : CharacterVO):
	if(character != _character):
		if(character != null && character.changed.is_connected(_on_character_changed)):
			character.changed.disconnect(_on_character_changed)
		character = _character
		if(character != null):
			character.changed.connect(_on_character_changed)

func get_character() -> CharacterVO:
	return character

## exp_area_id ##
func set_area_id(_area_id : int) -> void:
	if(area_id != _area_id):
		area_id = _area_id
		set_area(AreasManager.get_area_by_id(area_id))

func get_area_id() -> int:
	return area_id

## exp_area ##
func set_area(_area : AreaVO):
	if(area != _area):
		if(area != null && area.changed.is_connected(_on_area_changed)):
			area.changed.disconnect(_on_area_changed)
		area = _area
		if(area != null):
			area.changed.connect(_on_area_changed)

func get_area() -> AreaVO:
	return area

func _on_character_changed():
	pass

func _on_area_changed():
	pass
