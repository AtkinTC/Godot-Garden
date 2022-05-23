class_name Structure
extends Object

#############################
# Structure object is the cotent of a Plot that can be placed by the player
# Player pays the build price to start construction, structure doesn't take affect until construction complete
# Structure can be uograded to improve the structure's effect
#############################

signal structure_updated(world_coord : Vector2)

var structure_data : StructureDAO

var world_coord : Vector2
var active : bool = false
var building : bool = false
var upgrading : bool = false
var upgrade_level : int = 0
var construction_work_length : float
var construction_work_progress : float
var components : Dictionary = {}
var paused : bool = false

func _init(_structure_key : String, _world_coord : Vector2):
	world_coord = _world_coord
	if(structure_data == null || _structure_key != structure_data.get_structure_key()):
		structure_data = StructureDAO.new(_structure_key)

func step(_delta : float):
	process_construction_work(_delta)

func get_structure_key() -> String:
	return structure_data.get_structure_key()

func get_structure_data() -> StructureDAO:
	return structure_data

func get_world_coord() -> Vector2:
	return world_coord

func get_component(type_key : String) -> StructureComponenet:
	return components.get(type_key, null)

func is_active() -> bool:
	return active

func get_upgrade_level() -> int:
	return upgrade_level

func set_paused(_paused : bool):
	paused = _paused

func is_paused() -> bool:
	return paused

func is_building_in_progress() -> bool:
	return building

func is_upgrading_in_progress() -> bool:
	return upgrading

func get_work_progress_percent() -> float:
	if(construction_work_length <= 0):
		return 100.0
	return construction_work_progress * 100.0 / construction_work_length

func can_be_upgraded() -> bool:
	if(!active):
		return false
	if(building || upgrading || is_under_construction()):
		return false
	if(structure_data.get_upgrade_level_limit() >= 0 && structure_data.get_upgrade_level_limit() <= upgrade_level):
		return false
	return true

func start_building():
	active = false
	if(structure_data.is_build_instant()):
		finish_building()
	else:
		var base_work_length = structure_data.get_build_work_length()
		var modified_work_length = base_work_length #TODO apply local modifiers
		construction_work_length = modified_work_length
		construction_work_progress = 0
		building = true
		refresh_structure()

func start_upgrading():
	if(structure_data.is_upgrade_instant()):
		finish_upgrade()
	else:
		var base_work_length = structure_data.get_upgrade_work_length()
		var modified_work_length = base_work_length #TODO apply local modifiers
		construction_work_length = modified_work_length
		construction_work_progress = 0
		upgrading = true
		refresh_structure()

func finish_building():
	construction_work_length = -1
	construction_work_progress = 0
	upgrade_level = 0
	building = false
	active = true
	refresh_structure()

func finish_upgrade():
	construction_work_length = -1
	construction_work_progress = 0
	upgrading = false
	upgrade_level += 1
	refresh_structure()

func is_under_construction() -> bool:
	return !(construction_work_length == null || construction_work_length <= 0)

func process_construction_work(_delta : float):
	if(!is_under_construction() || is_paused()):
		return
	construction_work_progress += _delta * structure_data.get_build_work_speed()
	if(construction_work_progress >= construction_work_length):
		if(building):
			finish_building()
		elif(upgrading):
			finish_upgrade()
		else:
			refresh_structure()

func refresh_structure():
	if(active):
		for unlock in structure_data.get_unlocks():
			LockUtil.set_locked(unlock[Const.UNLOCK_TYPE], unlock[Const.UNLOCK_KEY], false)
		
		if(structure_data.get_supply_source_gain() != {}):
			# setup supply gains componenet
			var component := StructureSupplySourceComponent.new(world_coord, structure_data.get_structure_key(), Const.GAIN, upgrade_level)
			components[Const.GAIN] = component
		if(structure_data.get_supply_source_capacity() != {}):
			# setup supply 
			var component := StructureSupplySourceComponent.new(world_coord, structure_data.get_structure_key(), Const.CAPACITY, upgrade_level)
			components[Const.CAPACITY] = component
		
	structure_updated.emit(world_coord)

func cleanup_before_delete():
	for component in components.values():
		component.cleanup_before_delete()
		
