class_name WorldUnit
extends Node2D

signal unit_moved(id : int)

var id : int
var world_map_coord : Vector2i

enum ACTION {NONE, MOVE, EXPLORE}

var action_state : ACTION
var target_set : bool = false
var target_map_coord : Vector2i

var world : World

func _ready():
	action_state = ACTION.NONE
	
	if(world != null):
		self.position = world.map_to_world(world_map_coord)
	
	target_map_coord = world_map_coord

func move_to(new_coord : Vector2i):
	world_map_coord = new_coord
	self.position = world.map_to_world(world_map_coord)
	unit_moved.emit(id)

func set_world(_world : World):
	world = _world

func set_id(_id : int):
	id = _id

func set_world_map_coord(_world_map_coord : Vector2i):
	world_map_coord = _world_map_coord
