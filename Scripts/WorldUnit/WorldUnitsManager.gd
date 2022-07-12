extends Node

signal world_units_changed()
signal world_unit_created(int)

var world_units_dict : Dictionary = {}
var next_id : int = 0

func initialize() -> void:
	world_units_dict = {}
	next_id = 0

func get_used_ids() -> Array:
	return world_units_dict.keys()

func get_world_unit_by_id(id : int) -> WorldUnitVO:
	return world_units_dict.get(id)

func insert_world_unit(wuVO : WorldUnitVO) -> int:
	var new_id = next_id
	next_id += 1
	
	wuVO.set_id(new_id)

	world_units_dict[new_id] = wuVO
	wuVO.changed.connect(_on_world_unit_changed.bind(new_id))
	world_unit_created.emit(new_id)
	
	return wuVO.id

func _on_world_unit_changed(id : int):
	if(world_units_dict.has(id)):
		world_units_changed.emit()
