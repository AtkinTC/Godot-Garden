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
var display_capacity : String = "0.00"
var display_colors : Array = []
var show_sign : bool = false
var number_format_string : String
var allow_negative_quantity : bool = false

var needs_update : bool = true

func _ready() -> void:
	ready()

func ready():
	needs_update = true
	update_display()

func _process(_delta) -> void:
	update_display()

func update_display() -> void:
	pass

func set_display_name(_display_name : String) -> void:
	if(display_name != _display_name):
		display_name = _display_name
		needs_update = true

func set_quantity(_quantity : float) -> void:
	if(quantity != _quantity):
		quantity = _quantity
		needs_update = true

func set_display_quantity(_display_quantity : String) -> void:
	if(display_quantity != _display_quantity):
		display_quantity = _display_quantity
		needs_update = true

func set_change(_change : float) -> void:
	if(change != _change):
		change = _change
		needs_update = true

func set_display_change(_display_change : String) -> void:
	if(display_change != _display_change):
		display_change = _display_change
		needs_update = true

func set_capacity(_capacity : float) -> void:
	if(capacity != _capacity):
		capacity = _capacity
		needs_update = true

func set_display_capacity(_display_capacity : String) -> void:
	if(display_capacity != _display_capacity):
		display_capacity = _display_capacity
		needs_update = true

func set_display_colors(_display_colors : Array) -> void:
	if(display_colors != _display_colors):
		display_colors = _display_colors
		needs_update = true

func set_show_sign(_show_sign : bool) -> void:
	if(show_sign != _show_sign):
		show_sign = _show_sign
		needs_update = true

func set_number_format_string(_number_format_string : String) -> void:
	number_format_string = _number_format_string
	needs_update = true

func set_allow_negative_quantity(_allow_negative_quantity : bool) -> void:
	allow_negative_quantity = _allow_negative_quantity
	needs_update = true

func format_value(_value : float) -> String:
	if(number_format_string):
		return number_format_string % _value
	else:
		return str(_value)
