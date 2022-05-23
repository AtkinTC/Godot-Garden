class_name SupplyDisplay
extends Control

# # # # #
# Base class for Supply Display Control elements
# Does nothing on its own, just an interface class for inheritance 
# # # # #

var display_name : String = ""
var quantity : float = 0.0
var change : float  = 0.0
var capacity : float = -1
var display_quantity : String = "0.00"
var display_change : String = "0.00"
var display_colors : Array = []
var show_sign : bool = false

func set_display_name(_display_name : String) -> void:
	display_name = _display_name

func set_quantity(_quantity : float) -> void:
	quantity = _quantity
	set_display_quantity(str(quantity))

func set_display_quantity(_display_quantity : String) -> void:
	display_quantity = _display_quantity

func set_change(_change : float) -> void:
	change = _change
	set_display_change(str(change))

func set_display_change(_display_quantity : String) -> void:
	display_quantity = _display_quantity

func set_capacity(_capacity : float) -> void:
	capacity = _capacity

func set_display_colors(_display_colors : Array) -> void:
	display_colors = _display_colors

func set_show_sign(_show_sign : bool) -> void:
	show_sign = _show_sign
