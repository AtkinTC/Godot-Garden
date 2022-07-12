class_name WorldUnit
extends Node2D

signal unit_moved(id : int)
signal action_complete(id : int)

var wuVO : WorldUnitVO

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
	if(wuVO == null):
		print_debug("WorldUnit started without WorldUnitVO")
		self.queue_free()
		return
	
	objective_state = OBJECTIVE.NONE
	
	if(world != null):
		self.position = world.map_to_world(get_coord())
	
	target_map_coord = get_coord()

func _process(delta: float) -> void:
	if(action_state == ACTION.MOVE):
		process_move_action(delta)

# sets the world map coord and updates the actual position
func set_world_coord(coord : Vector2i):
	wuVO.set_coord(coord)
	self.position = world.map_to_world(coord)
	unit_moved.emit(get_id())

# enter the move action state
func start_move_action(target_coord : Vector2):
	action_state = ACTION.MOVE
	move_action_target_coord = target_coord
	move_action_target_pos = world.map_to_world(target_coord)

# frame-by-frame process for move action
# called from the class _process function
func process_move_action(delta : float) -> void:
	if(self.position.is_equal_approx(move_action_target_pos)):
		finish_move_action()
	else:
		self.position = self.position.move_toward(move_action_target_pos, delta*150)

# finalize move action results and exit the move action state
func finish_move_action() -> void:
	set_world_coord(move_action_target_coord)
	action_complete.emit(get_id())
	action_state = ACTION.NONE

# force the action to conclude
# called by action controller if unit action is running too long
func force_action_end():
	if(action_state == ACTION.MOVE):
		finish_move_action()

func set_world(_world : World):
	world = _world

func set_VO(_wuVO : WorldUnitVO):
	wuVO = _wuVO

func get_id() -> int:
	return wuVO.get_id()

func get_coord() -> Vector2i:
	return wuVO.get_coord()
