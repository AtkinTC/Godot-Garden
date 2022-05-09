extends Node

signal upgrades_status_updated()

const DISPLAY_NAME := "display_name"

const LOCKED := "locked"
const DISABLED := "disabled"

const PURCHASE_COST := "purchase_cost"

const UNLOCK := "unlock"
const UNLOCK_KEY := "unlock_key"
const UNLOCK_TYPE := "unlock_type"

var upgrade_types := {
	"UNLOCK_MIND" : {
		DISPLAY_NAME : "path of the mind",
		PURCHASE_COST : {
			"AIR_ESS" : 10,
			"EARTH_ESS" : 10,
			"FIRE_ESS" : 10,
			"WATER_ESS" : 10
		},
		UNLOCK : [
			{
				UNLOCK_KEY : "MIND_ESS",
				UNLOCK_TYPE : "SUPPLY"
			},
			{
				UNLOCK_KEY : "MIND_SOURCE_BASIC",
				UNLOCK_TYPE : "OBJECT"
			},
			{
				UNLOCK_KEY : "ENHANCE_MIND_001",
				UNLOCK_TYPE : "UPGRADE"
			}
		]
	},
	"ENHANCE_MIND_001" : {
		DISPLAY_NAME : "enhance mind",
		LOCKED : true,
		PURCHASE_COST : {
			"AIR_ESS" : 10,
			"EARTH_ESS" : 10,
			"FIRE_ESS" : 10,
			"WATER_ESS" : 10
		}
	}
}

# setup initial state of upgrades
func initialize():
	for key in upgrade_types.keys():
		upgrade_types[key][LOCKED] = upgrade_types[key].get(LOCKED, false)
		upgrade_types[key][DISABLED] = upgrade_types[key].get(DISABLED, false)

func get_upgrade_keys() -> Array:
	return upgrade_types.keys()
	
# get keys of all upgrades that are available for purchase
func get_available_upgrade_keys() -> Array:
	var available_keys = []
	for key in upgrade_types.keys():
		if(!upgrade_types[key].get(LOCKED, false) && !upgrade_types[key].get(DISABLED, false)):
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
	var purchase_cost : Dictionary = upgrade_types[key].get(PURCHASE_COST, {})
	if(!PurchaseManager.can_afford(purchase_cost)):
		return false
	
	PurchaseManager.spend(purchase_cost)
	apply_upgrade(key)
	return true

func unlock_upgrade(_key : String):
	upgrade_types[_key][LOCKED] = false
	refresh_upgrades()

func disable_upgrade(_key : String):
	upgrade_types[_key][DISABLED] = true
	refresh_upgrades()

# apply the selected upgrade
func apply_upgrade(key : String):
	if(upgrade_types[key].has(UNLOCK)):
		var unlocks : Array = upgrade_types[key][UNLOCK]
		for unlock in unlocks:
			if(unlock[UNLOCK_TYPE] == "SUPPLY"):
				SupplyManager.unlock_supply(unlock[UNLOCK_KEY])
			if(unlock[UNLOCK_TYPE] == "OBJECT"):
				ObjectsManager.unlock_object(unlock[UNLOCK_KEY])
			if(unlock[UNLOCK_TYPE] == "UPGRADE"):
				UpgradeManager.unlock_upgrade(unlock[UNLOCK_KEY])
	
	disable_upgrade(key)
