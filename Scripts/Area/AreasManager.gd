extends Node

signal areas_changed()

var areas_dict : Dictionary = {}
var next_area_id : int = 0

func initialize() -> void:
	areas_dict = {}
	next_area_id = 0

func get_area_ids() -> Array:
	return areas_dict.keys()

func get_area_by_id(area_id : int) -> AreaVO:
	return areas_dict.get(area_id)

func create_empty_area() -> AreaVO:
	var new_area_id = next_area_id
	next_area_id += 1
	
	var new_area = AreaVO.new()
	new_area.set_area_id(new_area_id)
	
	new_area.set_area_icon_name("area_icon_default.png")
	new_area.set_area_level(1)
	new_area.set_area_rank(1)

	areas_dict[new_area_id] = new_area
	new_area.changed.connect(_on_area_changed.bind(new_area_id))
	
	return new_area

func _on_area_changed(area_id : int):
	if(areas_dict.has(area_id)):
		areas_changed.emit()
