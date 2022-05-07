class_name Supply

signal supply_quantity_changed(key : String, old_quantity : float, new_quantity : float)

var key : String

var display_name : String
var quantity : float
var base_capacity : float
var display_colors : Array

func _init(_key : String, _supply_def : Dictionary):
	key = _key
	display_name = _supply_def.get(SupplyManager.DISPLAY_NAME, key)
	quantity = _supply_def.get(SupplyManager.QUANTITY_BASE, 0.00)
	base_capacity = _supply_def.get(SupplyManager.CAPACITY_BASE, -1)
	display_colors = _supply_def.get(SupplyManager.DISPLAY_COLORS, [])

func get_display_name() -> String:
	return display_name

func get_capacity() -> float:
	return base_capacity

func get_quantity() -> float:
	return quantity

func get_display_colors() -> Array:
	return display_colors

func get_display_color(index : int, default = null):
	if(index >= display_colors.size()):
		return default
	
	return display_colors[index]

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
