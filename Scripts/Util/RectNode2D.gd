@tool

class_name RectNode2D
extends Node2D

@export var size := Vector2(10.0, 10.0): set = set_size
@export var fill_color := Color(1,1,1,0.33): set = set_fill_color
@export var color := Color(1,1,1): set = set_color
@export var offset := Vector2(0,0): set = set_offset

var _rect: Rect2
var rect: Rect2

func set_size(_size : Vector2) -> void:
	size = _size
	_recalculate_rect()
	update()

func set_offset(_offset : Vector2) -> void:
	offset = _offset
	_recalculate_rect()
	update()

func _recalculate_rect() -> void:
	_rect = Rect2(offset, size)
	rect = Rect2(position + offset, size)
	update()

func get_rect() -> Rect2:
	return rect

func set_color(_color : Color) -> void:
	color = _color
	update()

func set_fill_color(_fill_color : Color) -> void:
	fill_color = _fill_color
	update()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_rect(_rect, fill_color, true)
	draw_rect(_rect, color, false)

func has_point(_global_point : Vector2) -> bool:
	var rect_global = Rect2(global_position + _rect.position, _rect.size)
	return rect_global.has_point(_global_point)
