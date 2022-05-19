extends Resource
class_name SupplyVO

var supply_key : String = ""
var display_name : String = ""
var quantity : float = 0.0
var capacity : float = -1.0
var change : float = 0.0
var display_colors : Array
var locked : bool = true

func get_supply_key() -> String:
	return supply_key

func get_display_name() -> String:
	return display_name

func get_quantity() -> float:
	return quantity

func get_capacity() -> float:
	return capacity

func get_change() -> float:
	return change

func get_display_colors() -> Array:
	return display_colors

func get_display_color(index : int, default = null):
	if(index >= display_colors.size()):
		return default
	return display_colors[index]

func is_locked() -> bool:
	return locked
