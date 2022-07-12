class_name PlotVO
extends Resource

@export var coord : Vector2i = Vector2i.ZERO
@export var explored : bool = false
@export var owned : bool = false

@export var plot_type : String
@export var base_type : String
@export var display_name : String

func set_coord(_coord : Vector2i):
	coord = _coord
	changed.emit()

func set_explored(_explored : bool):
	explored = _explored
	changed.emit()

func set_owned(_owned : bool):
	owned = _owned
	changed.emit()

func set_plot_type(_plot_type : String):
	plot_type = _plot_type
	changed.emit()

func set_base_type(_base_type : String):
	base_type = _base_type
	changed.emit()

func set_display_name(_display_name : String):
	display_name = _display_name
	changed.emit()

func get_coord() -> Vector2i:
	return coord

func get_explored() -> bool:
	return explored

func is_explored() -> bool:
	return explored

func get_owned() -> bool:
	return owned

func is_owned() -> bool:
	return owned

func get_plot_type() -> String:
	return plot_type

func get_base_type() -> String:
	return base_type

func get_display_name() -> String:
	return display_name
