class_name WorldUnitsManager
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

# create new world unit and add it to the world as a child of this node
#TODO: seperate creation of unit and adding unit to world
#TODO: unit creation should be based on an existing characterVO
func add_new_world_unit(map_coord : Vector2i) -> int:
	var new_unit_id = next_char_id
	next_char_id += 1
	
	var new_unit : WorldUnit = world_unit_scene.instantiate()
	new_unit.set_world(world)
	new_unit.set_world_map_coord(map_coord)
	new_unit.set_id(new_unit_id)
	
	add_child(new_unit)
	new_unit.unit_moved.connect(update_unit_coord)
	
	units_dict[new_unit_id] = new_unit
	update_unit_coord(new_unit_id)
	
	return new_unit_id

# update data related to unit's coordinate
func update_unit_coord(unit_id : int):
	if(!units_dict.has(unit_id)):
		return
	
	var new_coord = units_dict[unit_id].world_map_coord
	
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
