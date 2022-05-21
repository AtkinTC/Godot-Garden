class_name StructureDAO

#############################
# Structure Data Access Object
# a utility class used to access data pertinent to a specific Structure type
#############################

var structure_key : String

func _init(_structure_key : String):
	structure_key = _structure_key

func get_structure_key() -> String:
	return structure_key

func get_structure_data() -> Dictionary:
	return Database.get_entry(Const.OBJECT, structure_key)

#############
# top level #
#############

func get_display_name() -> String:
	return get_structure_data().get(Const.DISPLAY_NAME, "")

func is_locked() -> bool:
	return get_structure_data().get(Const.LOCKED, false)

func is_removable() -> bool:
	return get_structure_data().get(Const.REMOVABLE, false)

func is_disabled() -> bool:
	return get_structure_data().get(Const.DISABLED, false)

func get_unlocks() -> Array:
	return get_structure_data().get(Const.UNLOCKS, {})

func get_count() -> int:
	return get_structure_data().get(Const.COUNT, 0)

############
# purchase #
############

func get_purchase_data() -> Dictionary:
	return get_structure_data().get(Const.PURCHASE, {})

func get_purchase_price() -> Dictionary:
	return get_purchase_data().get(Const.VALUE, {})

func get_purchase_local_modifiers() -> Array:
	return get_purchase_data().get(Const.LOCAL_MODIFIERS, {})

func get_purchase_limit() -> int:
	return get_purchase_data().get(Const.LIMIT, -1)

#########
# build #
#########

func get_build_data() -> Dictionary:
	return get_structure_data().get(Const.BUILD, {})

func get_build_price() -> Dictionary:
	return get_build_data().get(Const.VALUE, {})

func get_build_limit() -> int:
	return get_build_data().get(Const.LIMIT, -1)

func get_build_work_length() -> float:
	return get_build_data().get(Const.LENGTH, -1)

func is_build_instant() -> bool:
	return (get_build_work_length() < 0)

func get_build_work_speed() -> float:
	return get_build_data().get(Const.SPEED, 1.0)
	
func get_build_local_modifiers() -> Array:
	return get_build_data().get(Const.LOCAL_MODIFIERS, {})

###########
# upgrade #
###########

func get_upgrade_data() -> Dictionary:
	return get_structure_data().get(Const.UPGRADE, {})

func get_upgrade_price() -> Dictionary:
	return get_upgrade_data().get(Const.VALUE, {})

func get_upgrade_level_limit() -> int:
	return get_upgrade_data().get(Const.LIMIT, -1)

func get_upgrade_work_length() -> float:
	return get_upgrade_data().get(Const.LENGTH, -1)

func is_upgrade_instant() -> bool:
	return (get_upgrade_work_length() < 0)

func get_upgrade_work_speed() -> float:
	return get_upgrade_data().get(Const.SPEED, 1.0)

func get_upgrade_local_modifiers() -> Array:
	return get_upgrade_data().get(Const.LOCAL_MODIFIERS, [])

#################
# supply source #
#################

func get_supply_source_data() -> Dictionary:
	return get_structure_data().get(Const.SOURCE, {})

func get_supply_source_gain() -> Dictionary:
	return get_supply_source_data().get(Const.GAIN, {})

func get_supply_source_gain_values() -> Dictionary:
	return get_supply_source_gain().get(Const.VALUE, {})

func get_supply_source_gain_local_modifiers() -> Array:
	return get_supply_source_gain().get(Const.LOCAL_MODIFIERS, [])

func get_supply_source_capacity() -> Dictionary:
	return get_supply_source_data().get(Const.CAPACITY, {})

func get_supply_source_capacity_values() -> Dictionary:
	return get_supply_source_capacity().get(Const.VALUE, {})

func get_supply_source_capacity_local_modifiers() -> Array:
	return get_supply_source_capacity().get(Const.LOCAL_MODIFIERS, [])

##########
# vision #
##########

func get_vision_data() -> Dictionary:
	return get_structure_data().get(Const.VISION, {})

func get_vision_distance() -> int:
	return get_vision_data().get(Const.VALUE, 1)

func get_vision_local_modifiers() -> Array:
	return get_vision_data().get(Const.LOCAL_MODIFIERS, {})
