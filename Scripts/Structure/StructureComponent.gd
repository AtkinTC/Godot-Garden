class_name StructureComponenet
extends Object

var world_coord : Vector2 = Vector2.ZERO
var structure_key : String
var running : bool = true

func _init(_world_coord : Vector2, _structure_key : String):
	world_coord = _world_coord
	structure_key = _structure_key

func step(_delta : float):
	pass

func cleanup_before_delete():
	pass

func set_running(_running : bool):
	running = _running

func is_running() -> bool:
	return running
