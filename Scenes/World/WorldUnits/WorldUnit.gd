class_name WorldUnit
extends Node2D

signal unit_moved(id : int)
signal action_complete(id : int)

var id : int
var world_map_coord : Vector2i

enum OBJECTIVE {NONE, EXPLORE}

var objective_state : OBJECTIVE

var target_set : bool = false
var target_map_coord : Vector2i

var world : World

enum ACTION {NONE, MOVE}

var action_state : ACTION = ACTION.NONE

var move_action_target_coord: Vector2i
var move_action_target_pos: Vector2

func _ready():
	objective_state = OBJECTIVE.NONE
	
	if(world != null):
		self.position = world.map_to_world(world_map_coord)
	
	target_map_coord = world_map_coord

func _process(delta: float) -> void:
	if(action_state == ACTION.MOVE):
		process_move_action(delta)

func set_world_coord(coord : Vector2i):
	world_map_coord = coord
	self.position = world.map_to_world(coord)
	unit_moved.emit(id)

# start the move action process
func start_move_action(target_coord : Vector2):
	action_state = ACTION.MOVE
	move_action_target_coord = target_coord
	move_action_target_pos = world.map_to_world(target_coord)

func process_move_action(delta : float) -> void:
	if(self.position.is_equal_approx(move_action_target_pos)):
		finish_move_action()
	else:
		self.position = self.position.move_toward(move_action_target_pos, delta*150)

func finish_move_action() -> void:
	set_world_coord(move_action_target_coord)
	action_complete.emit(id)
	action_state = ACTION.NONE

func force_action_end():
	if(action_state == ACTION.MOVE):
		finish_move_action()

func set_world(_world : World):
	world = _world

func set_id(_id : int):
	id = _id

func set_world_map_coord(_world_map_coord : Vector2i):
	world_map_coord = _world_map_coord
