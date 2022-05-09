extends Node

signal supplies_status_updated()

var supplies := {}

# setup initial state of supplies
func initialize():
	supplies = {}
	for key in  SupplyData.supply_types.keys():
		var dict : Dictionary = SupplyData.supply_types.get(key, {})
		var supply := Supply.new(key, dict)
		supplies[key] = supply
		
func get_supply_type_keys() -> Array:
	return supplies.keys()

func get_visible_supply_type_keys() -> Array:
	var visible_keys = []
	for key in supplies.keys():
		if(!supplies[key].is_locked()):
			visible_keys.append(key)
	return visible_keys

func get_supply(_key : String) -> Supply:
	return supplies.get(_key)

func unlock_supply(_key : String):
	get_supply(_key).set_locked(false)
	supplies_status_updated.emit()

func connect_to_supply_quantity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_quantity_changed.connect(_callable)
		
func connect_to_supply_capacity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_capacity_changed.connect(_callable)
