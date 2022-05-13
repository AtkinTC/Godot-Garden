extends Node

signal locked_status_changed(key, category)

var locked_status : Dictionary

func initialize():
	locked_status = {}
	
	var action_types : Dictionary = ActionData.action_types
	var action_locked_status := {}
	for key in action_types.keys():
		action_locked_status[key] = action_types[key].get(Const.LOCKED, true)
	locked_status[Const.ACTION] = action_locked_status
	
	var object_types : Dictionary = ObjectData.object_types
	var object_locked_status := {}
	for key in object_types.keys():
		object_locked_status[key] = object_types[key].get(Const.LOCKED, true)
	locked_status[Const.OBJECT] = object_locked_status
	
	var supply_types : Dictionary = SupplyData.supply_types
	var supply_locked_status := {}
	for key in supply_types.keys():
		supply_locked_status[key] = supply_types[key].get(Const.LOCKED, true)
	locked_status[Const.SUPPLY] = supply_locked_status
	
	var upgrade_types : Dictionary = UpgradeData.upgrade_types
	var upgrade_locked_status := {}
	for key in upgrade_types.keys():
		upgrade_locked_status[key] = upgrade_types[key].get(Const.LOCKED, true)
	locked_status[Const.UPGRADE] = upgrade_locked_status

func is_locked(key : String, category : String) -> bool:
	return locked_status.get(category, {}).get(key, false)

func set_locked(key : String, category : String, _locked : bool):
	var category_locked_status = locked_status.get(category, {})
	var locked = category_locked_status.get(key)
	category_locked_status[key] = _locked
	locked_status[category] = category_locked_status
	
	if(locked != _locked):
		locked_status_changed.emit(key, category)
		
