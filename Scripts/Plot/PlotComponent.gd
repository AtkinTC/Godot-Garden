class_name PlotComponent

var coord : Vector2 = Vector2.ZERO
var object_key : String

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key

func step(_delta : float):
	pass

func cleanup_before_delete():
	pass
