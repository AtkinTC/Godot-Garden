class_name WorldUnitVO
extends Resource

var id : int = -1
var coord : Vector2i = Vector2.ZERO

func set_id(_id : int):
	id = _id
	changed.emit()

func set_coord(_coord : Vector2i):
	coord = _coord
	changed.emit()

func get_id() -> int:
	return id

func get_coord() -> Vector2i:
	return coord

