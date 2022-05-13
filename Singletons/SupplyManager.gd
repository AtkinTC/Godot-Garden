extends Node

signal supplies_status_updated()

var supplies := {}

# setup initial state of supplies
func initialize():
	LockStatusManager.locked_status_changed.connect(_on_locked_status_changed)
	supplies = {}
	for key in  SupplyData.supply_types.keys():
		var dict : Dictionary = SupplyData.supply_types.get(key, {})
		var supply := Supply.new(key, dict)
		supplies[key] = supply

func step(_delta):
	for supply in supplies.values():
		(supply as Supply).step(_delta)

func get_supply_type_keys() -> Array:
	return supplies.keys()

func get_visible_supply_type_keys() -> Array:
	var visible_keys = []
	for key in supplies.keys():
		if(!LockStatusManager.is_locked(key, Const.SUPPLY)):
			visible_keys.append(key)
	return visible_keys

func get_supply(_key : String) -> Supply:
	return supplies.get(_key)

func connect_to_supply_quantity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_quantity_changed.connect(_callable)
		
func connect_to_supply_capacity_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_capacity_changed.connect(_callable)

func connect_to_supply_gain_changed(_key : String, _callable : Callable):
	var supply : Supply = supplies.get(_key)
	if(supply):
		supply.supply_gain_changed.connect(_callable)

func _on_locked_status_changed(key : String, category : String):
	if(category == Const.SUPPLY):
		supplies_status_updated.emit()
