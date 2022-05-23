extends Node

signal supplies_status_updated()

signal supply_capacity_updated(key : String)
signal supply_change_updated(key : String)
signal supply_quantity_updated(key : String)

var supplies : Dictionary
var capacity_sources : Dictionary
var change_sources : Dictionary

var capacity_needs_recalculate : bool
var change_needs_recalculate : bool

# setup initial state of supplies
func initialize():
	SignalBus.locked_status_changed.connect(_on_locked_status_changed)
	
	supplies = {}
	capacity_sources = {}
	change_sources = {}
	capacity_needs_recalculate = true
	change_needs_recalculate = true
	
	for supply_key in Database.get_category(Const.SUPPLY).keys():
		setup_supply(supply_key)

func setup_supply(supply_key : String):
	var supply_def := Database.get_entry(Const.SUPPLY, supply_key)
	var supply := SupplyVO.new()
	supply.supply_key = supply_key
	supply.display_name = supply_def.get(Const.DISPLAY_NAME, "")
	supply.display_colors = supply_def.get(Const.DISPLAY_COLORS, [])
	supply.quantity = 0.0
	supply.capacity = 0.0
	supply.change = 0.0
	supply.locked = supply_def.get(Const.LOCKED, false)
	supplies[supply_key] = supply

func set_source(source_key : String, supply_key : String, source_id : String, value : float):
	if(source_key == Const.CAPACITY):
		set_capacity_source(supply_key, source_id, value)
	elif(source_key == Const.GAIN):
		set_change_source(supply_key, source_id, value)

func remove_source(source_key : String, supply_key : String, source_id : String):
	if(source_key == Const.CAPACITY):
		remove_capacity_source(supply_key, source_id)
	elif(source_key == Const.GAIN):
		remove_change_source(supply_key, source_id)

# set a supply capacity source, inserting or overwriting if the source already exists
func set_capacity_source(supply_key : String, source_id : String, capacity : float):
	if(!capacity_sources.has(supply_key)):
		capacity_sources[supply_key] = {}
	if(capacity_sources[supply_key].get(source_id) == capacity):
		#no change
		return false
	capacity_sources[supply_key][source_id] = capacity
	capacity_needs_recalculate = true
	return true

# remove supply capacity source
func remove_capacity_source(supply_key : String, source_id : String):
	if(!capacity_sources.get(supply_key, {}).has(source_id)):
		#source doesn't exist
		return false
	capacity_sources[supply_key].erase(source_id)
	capacity_needs_recalculate = true
	return true

# set a supply change source, inserting or overwriting if the source already exists
func set_change_source(supply_key : String, source_id : String, capacity : float):
	if(!change_sources.has(supply_key)):
		change_sources[supply_key] = {}
	if(change_sources[supply_key].get(source_id) == capacity):
		#no change
		return false
	change_sources[supply_key][source_id] = capacity
	change_needs_recalculate = true
	return true

# remove supply change source
func remove_change_source(supply_key : String, source_id : String):
	if(!change_sources.get(supply_key, {}).has(source_id)):
		#source doesn't exist
		return false
	change_sources[supply_key].erase(source_id)
	change_needs_recalculate = true
	return true

# recalculates supply capacity value from all gain sources and applies any modifiers
# emits supply_capacity_updated signal if a change has been made
func recalculate_capacity():
	capacity_needs_recalculate = false
	for supply_key in supplies.keys():
		var supply : SupplyVO = supplies[supply_key]
		if(supply.get_capacity() < 0):
			#negative capacity = no limit
			continue
		
		var new_capacity : float = 0
		var supply_capacity_sources : Dictionary = capacity_sources.get(supply_key, {})
		for source_id in supply_capacity_sources.keys():
			new_capacity += supply_capacity_sources[source_id]
		
		if(!is_equal_approx(new_capacity, supply.get_capacity())):
			supply.capacity = new_capacity
			supply_capacity_updated.emit(supply_key)

# recalculates supply gain value from all gain sources and applies any modifiers
# emits supply_change_updated signal if a change has been made
func recalculate_change():
	change_needs_recalculate = false
	for supply_key in supplies.keys():
		var supply : SupplyVO = supplies[supply_key]
		
		var new_change : float = 0
		var supply_change_sources : Dictionary = change_sources.get(supply_key, {})
		for source_id in supply_change_sources.keys():
			new_change += supply_change_sources[source_id]
		
		if(!is_equal_approx(new_change, supply.get_change())):
			supply.change = new_change
			supply_change_updated.emit(supply_key)

func change_supply_quantity(supply_key : String, change: float):
	assert(supplies.has(supply_key))
	set_supply_quantity(supply_key, supplies.get(supply_key).get_quantity() + change)

# set supply quantity value limited by capacity
#	emit supply_quantity_updated signal if the quantity has changed
func set_supply_quantity(supply_key : String, quantity: float):
	assert(supplies.has(supply_key))
	var supply : SupplyVO = supplies[supply_key]
	
	var new_quantity = quantity
	if(supply.get_capacity() >= 0 && supply.get_capacity() < new_quantity):
		new_quantity = supply.get_capacity()
	
	if(is_equal_approx(supply.get_quantity(), new_quantity)):
		#no change
		return false
	
	supply.quantity = new_quantity
	supply_quantity_updated.emit(supply_key)

func step(_delta):
	if(capacity_needs_recalculate):
		recalculate_capacity()
	if(change_needs_recalculate):
		recalculate_change()
		
	for supply_key in supplies.keys():
		var supply : SupplyVO = supplies[supply_key]
		if(is_equal_approx(supply.get_change(), 0.0)):
			continue
		change_supply_quantity(supply_key, _delta * supply.get_change())

func get_supply_type_keys() -> Array:
	return supplies.keys()

func get_visible_supply_type_keys() -> Array:
	var visible_keys = []
	for key in supplies.keys():
		if(!LockUtil.is_locked(Const.SUPPLY, key)):
			visible_keys.append(key)
	return visible_keys

func get_supply(_key : String) -> SupplyVO:
	return supplies.get(_key)

func _on_locked_status_changed(category : String, key : String):
	if(category == Const.SUPPLY && supplies.has(key)):
		supplies[key].locked = Database.get_entry_attr(category, key, Const.LOCKED, false)
		supplies_status_updated.emit()
		
