# WorldUnitsParentNode
# Manages the WorldUnit nodes

class_name WorldUnitsParentNode
extends Node2D

@onready var world : World = self.get_parent()

var units_dict : Dictionary = {}
var units_to_coord_dict : Dictionary = {}
var coord_to_units_dict : Dictionary = {}
var next_char_id : int = 0

@export var world_unit_scene : PackedScene

func _ready() -> void:
	# clear out test content
	for child in get_children():
		child.queue_free()
	
	WorldUnitsManager.world_unit_created.connect(_on_world_unit_created)

# trigger the creation of a WorldUnitNode when a new WorldUnitVO is created
func _on_world_unit_created(id : int):
	var wuVO := WorldUnitsManager.get_world_unit_by_id(id)
	insert_world_unit(wuVO)

# create new WorldUnit node from a WorldUnitVO and add as a child
func insert_world_unit(wuVO : WorldUnitVO) -> int:
	next_char_id = max(wuVO.get_id() + 1, next_char_id)
	
	var new_unit : WorldUnit = world_unit_scene.instantiate()
	new_unit.set_world(world)
	new_unit.set_VO(wuVO)
	
	add_child(new_unit)
	new_unit.unit_moved.connect(update_unit_coord)
	units_dict[wuVO.get_id()] = new_unit
	update_unit_coord(wuVO.get_id())
	
	return 0

# update data related to unit's coordinate
func update_unit_coord(unit_id : int):
	if(!units_dict.has(unit_id)):
		return
	
	var new_coord = units_dict[unit_id].get_coord()
	
	if(units_to_coord_dict.has(unit_id)):
		# remove unit from old coordinate entry
		var old_coord : Vector2i = units_to_coord_dict[unit_id]
		if(coord_to_units_dict.has(old_coord)):
			var old_coord_units : Array = coord_to_units_dict[old_coord]
			old_coord_units.erase(unit_id)
			if(old_coord_units.size() == 0):
				coord_to_units_dict.erase(old_coord)
			else:
				coord_to_units_dict[old_coord] = old_coord_units
	
	# add unit to new coordinate entry
	var new_coord_units : Array = coord_to_units_dict.get(new_coord, [])
	new_coord_units.append(unit_id)
	coord_to_units_dict[new_coord] = new_coord_units
	
	# update recorded unit coordinate
	units_to_coord_dict[unit_id] = new_coord

func get_world_units() -> Array:
	return units_dict.values()

func get_world_unit_ids() -> Array:
	return units_dict.keys()

func get_world_unit(unit_id : int) -> WorldUnit:
	return units_dict.get(unit_id, null)
