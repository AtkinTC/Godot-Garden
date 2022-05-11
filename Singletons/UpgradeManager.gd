extends Node

signal upgrades_status_updated()
signal selected_upgrade_changed()

var upgrade_types : Dictionary
var selected_upgrade_key : String

# setup initial state of upgrades
func initialize():
	upgrade_types = UpgradeData.upgrade_types
	for key in upgrade_types.keys():
		upgrade_types[key][Const.LEVEL] = upgrade_types[key].get(Const.LEVEL, 0)
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

func set_selected_upgrade_key(upgrade_key : String):
	selected_upgrade_key = upgrade_key
	selected_upgrade_changed.emit()

func get_selected_upgrade_key() -> String:
	return selected_upgrade_key

# purchase an upgrade, spending the required resources and then applying it
func purchase_upgrade(key : String) -> bool:
	var purchase_cost : Dictionary = upgrade_types[key].get(Const.PURCHASE_COST, {})
	var price_modifier := 1.0
	
	set_selected_upgrade_key(key)
	
	if(upgrade_types[key][Const.LEVEL] > 0):
		# rebuying a multi-level upgrade
		if(!upgrade_types[key].has(Const.REBUY)):
			return false
		var rebuy : Dictionary = upgrade_types[key].get(Const.REBUY)
		var price_modifier_type : String = rebuy[Const.PRICE_MODIFIER_TYPE]
		if(price_modifier_type == Const.PRICE_MODIFIER_FLAT_LEVEL):
			price_modifier = upgrade_types[key][Const.LEVEL] + 1
	
	if(!PurchaseManager.can_afford(purchase_cost, price_modifier)):
		return false
	
	PurchaseManager.spend(purchase_cost, price_modifier)
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
	upgrade_types[key][Const.LEVEL] = upgrade_types[key][Const.LEVEL] + 1
	
	var upgrade_type : Dictionary = upgrade_types[key] 
	
	#apply upgrade unlocks
	if(upgrade_type.has(Const.UNLOCK)):
		var unlocks : Array = upgrade_type[Const.UNLOCK]
		for unlock in unlocks:
			if(unlock[Const.UNLOCK_TYPE] == Const.SUPPLY):
				SupplyManager.unlock_supply(unlock[Const.UNLOCK_KEY])
			if(unlock[Const.UNLOCK_TYPE] == Const.OBJECT):
				ObjectsManager.unlock_object(unlock[Const.UNLOCK_KEY])
			if(unlock[Const.UNLOCK_TYPE] == Const.UPGRADE):
				UpgradeManager.unlock_upgrade(unlock[Const.UNLOCK_KEY])
	
	#setup upgrade supply source attributes (gain and capacity values)
	if(upgrade_type.has(Const.SOURCE)):
		var source : Dictionary = upgrade_type[Const.SOURCE]
		if(source.has(Const.GAIN)):
			var gain = source.get(Const.GAIN)
			for supply_key in gain.keys():
				SupplyManager.get_supply(supply_key).set_gain_source(str(key), gain[supply_key] * upgrade_type[Const.LEVEL])
		if(source.has(Const.CAPACITY)):
			var capacity = source.get(Const.CAPACITY)
			for supply_key in capacity.keys():
				SupplyManager.get_supply(supply_key).set_capacity_source(str(key), capacity[supply_key] * upgrade_type[Const.LEVEL])
	
	#setup upgrade modifier values
	if(upgrade_type.has(Const.MODIFIER)):
		var modifiers : Array = upgrade_type[Const.MODIFIER]
		for mod in modifiers:
			mod[Const.LEVEL] = upgrade_type[Const.LEVEL]
		ModifiersManager.set_modifier_source(key, modifiers)
	
	if(!upgrade_types[key].has(Const.REBUY)):
		disable_upgrade(key)
	else:
		refresh_upgrades()
