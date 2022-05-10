extends Node

signal upgrades_status_updated()

var upgrade_types : Dictionary

# setup initial state of upgrades
func initialize():
	upgrade_types = UpgradeData.upgrade_types
	for key in upgrade_types.keys():
		upgrade_types[key][Const.LOCKED] = upgrade_types[key].get(Const.LOCKED, false)
		upgrade_types[key][Const.DISABLED] = upgrade_types[key].get(Const.DISABLED, false)

func get_upgrade_keys() -> Array:
	return upgrade_types.keys()
	
# get keys of all upgrades that are available for purchase
func get_available_upgrade_keys() -> Array:
	var available_keys = []
	for key in upgrade_types.keys():
		if(!upgrade_types[key].get(Const.LOCKED, false) && !upgrade_types[key].get(Const.DISABLED, false)):
			available_keys.append(key)
	return available_keys

func refresh_upgrades():
	upgrades_status_updated.emit()

func get_upgrade_type(upgrade_key : String) -> Dictionary:
	return upgrade_types.get(upgrade_key, {})

func get_upgrade_type_attribute(upgrade_key : String, attribute_key : String, default = null):
	return upgrade_types.get(upgrade_key, {}).get(attribute_key, default)

# purchase an upgrade, spending the required resources and then applying it
func purchase_upgrade(key : String) -> bool:
	var purchase_cost : Dictionary = upgrade_types[key].get(Const.PURCHASE_COST, {})
	if(!PurchaseManager.can_afford(purchase_cost)):
		return false
	
	PurchaseManager.spend(purchase_cost)
	apply_upgrade(key)
	return true

func unlock_upgrade(_key : String):
	upgrade_types[_key][Const.LOCKED] = false
	refresh_upgrades()

func disable_upgrade(_key : String):
	upgrade_types[_key][Const.DISABLED] = true
	refresh_upgrades()

# apply the selected upgrade
func apply_upgrade(key : String):
	if(upgrade_types[key].has(Const.UNLOCK)):
		var unlocks : Array = upgrade_types[key][Const.UNLOCK]
		for unlock in unlocks:
			if(unlock[Const.UNLOCK_TYPE] == Const.SUPPLY):
				SupplyManager.unlock_supply(unlock[Const.UNLOCK_KEY])
			if(unlock[Const.UNLOCK_TYPE] == Const.OBJECT):
				ObjectsManager.unlock_object(unlock[Const.UNLOCK_KEY])
			if(unlock[Const.UNLOCK_TYPE] == Const.UPGRADE):
				UpgradeManager.unlock_upgrade(unlock[Const.UNLOCK_KEY])
	
	if(upgrade_types[key].has(Const.MODIFIER)):
		var modifiers : Array = upgrade_types[key][Const.MODIFIER]
		ModifiersManager.set_modifier_source(key, modifiers)
		
	disable_upgrade(key)
