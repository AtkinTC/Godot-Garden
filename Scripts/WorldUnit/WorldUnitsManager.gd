extends Node

signal world_units_changed()
signal world_unit_created(int)

var world_units_dict : Dictionary = {}
var next_id : int = 0

func initialize() -> void:
	reset()

func reset() -> void:
	world_units_dict = {}
	next_id = 0

func setup_from_world_units_array(world_units : Array):
	reset()
	for i in world_units.size():
		var wuVO : WorldUnitVO = world_units[i]
		insert_world_unit(wuVO)

func get_used_ids() -> Array:
	return world_units_dict.keys()

func get_world_unit_by_id(id : int) -> WorldUnitVO:
	return world_units_dict.get(id)

func get_world_units() -> Array:
	return world_units_dict.values()

func create_new_world_unit() -> WorldUnitVO:
	var new_id = next_id
	next_id += 1
	
	var wuVO := WorldUnitVO.new()
	wuVO.set_id(new_id)
	
	insert_world_unit(wuVO)
	
	return wuVO

func insert_world_unit(wuVO : WorldUnitVO) -> int:
	next_id = max(next_id, wuVO.get_id() + 1)

	world_units_dict[wuVO.get_id()] = wuVO
	wuVO.changed.connect(_on_world_unit_changed.bind(wuVO.get_id()))
	world_unit_created.emit(wuVO.get_id())
	
	return wuVO.id

func _on_world_unit_changed(id : int):
	if(world_units_dict.has(id)):
		world_units_changed.emit()
