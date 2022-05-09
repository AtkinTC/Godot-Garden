class_name Supply

signal supply_quantity_changed(key : String, old_quantity : float, new_quantity : float)
signal supply_capacity_changed(key : String, old_capacity : float, new_capacity : float)

var key : String

var display_name : String
var quantity : float
var base_capacity : float
var display_colors : Array

var locked : bool

var capacity_sources : Dictionary

func _init(_key : String, _supply_def : Dictionary):
	key = _key
	display_name = _supply_def.get(Const.DISPLAY_NAME, key)
	quantity = _supply_def.get(Const.QUANTITY_BASE, 0.00)
	base_capacity = _supply_def.get(Const.CAPACITY_BASE, 0.00)
	display_colors = _supply_def.get(Const.DISPLAY_COLORS, [])
	locked = _supply_def.get(Const.LOCKED, false)
	capacity_sources = {}

func get_display_name() -> String:
	return display_name

func get_capacity() -> float:
	if(base_capacity < 0):
		return -1.0
	
	var total_capacity = base_capacity
	for capacity in capacity_sources.values():
		total_capacity += capacity
	
	return total_capacity

func get_quantity() -> float:
	return quantity

func get_display_colors() -> Array:
	return display_colors

func get_display_color(index : int, default = null):
	if(index >= display_colors.size()):
		return default
	
	return display_colors[index]

func is_locked() -> bool:
	return locked

func set_locked(_locked : bool):
	locked = _locked

func change_quantity(_change: float):
	set_quantity(quantity + _change)

func set_quantity(_quantity: float):
	if(_quantity != quantity):
		var new_quantity : float = _quantity
		if(get_capacity() >= 0):
			new_quantity = min(new_quantity, get_capacity())
		
		if(new_quantity != quantity):
			var old_quantity := quantity
			quantity = new_quantity
			supply_quantity_changed.emit(key, old_quantity, new_quantity)

func set_capacity_source(_id : String, _capacity : float):
	var old_capacity := get_capacity()
	capacity_sources[_id] = _capacity
	var new_capacity := get_capacity()
	
	if(new_capacity != old_capacity):
		supply_capacity_changed.emit(key, old_capacity, new_capacity)

func remove_capacity_source(_id : String):
	var old_capacity := get_capacity()
	capacity_sources.erase(_id)
	var new_capacity := get_capacity()
	
	if(new_capacity != old_capacity):
		supply_capacity_changed.emit(key, old_capacity, new_capacity)
