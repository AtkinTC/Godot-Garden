class_name WorldUnitsActionController
extends Node2D

enum ACTION {NONE, MOVE, EXPLORE}

class ActionObject:
	var unit_id : int
	var action_type : ACTION
	var move_coord : Vector2i

@onready var world : World = self.get_parent()
@onready var world_units_manager : WorldUnitsParentNode = get_node("../WorldUnitsParentNode") #TODO: UGLY
@onready var world_navigation_controller : WorldNavigationController = get_node("../WorldNavigationController") #TODO: UGLY

var ready_for_next_turn : bool = false

var unit_objective_groups : Dictionary

var action_queue : Array

var minimum_turn_time = 0.20
var minimum_timer : SceneTreeTimer

var maximum_turn_time = 1.0
var maximum_timer : SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minimum_timer = get_tree().create_timer(1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(ready_for_next_turn):
		ready_for_next_turn = false
		process_turn()
	
	# turn won't end until the minimum
	elif(minimum_timer.time_left <= 0 && (waiting_on_ids.size() == 0 || maximum_timer.time_left <= 0)):
			for id in waiting_on_ids:
				var unit = world_units_manager.get_world_unit(id as int)
				if(unit != null):
					(unit as WorldUnit).force_action_end()
			set_ready_for_next_turn()
	

func process_turn() -> void:
	update_unit_objective_states()
	action_decision_precalculation()
	action_decision()
	execute_unit_actions()
	
	minimum_timer = get_tree().create_timer(minimum_turn_time)
	maximum_timer = get_tree().create_timer(maximum_turn_time)

func update_unit_objective_states():
	var world_units : Array = world_units_manager.get_world_units()
	unit_objective_groups = {}
	
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		var current_plot : PlotVO = GardenManager.get_plot(world_unit.get_coord())
		
		if(world_unit.objective_state == WorldUnit.OBJECTIVE.NONE):
			world_unit.objective_state = WorldUnit.OBJECTIVE.EXPLORE
			world_unit.target_set = false
		
		var group : Array = unit_objective_groups.get(world_unit.objective_state, [])
		group.append(world_unit)
		unit_objective_groups[world_unit.objective_state] = group


func action_decision_precalculation():
	exploration_decision_precalculation()

var reserved_exploration_targets : Dictionary

# reserve already chosen exploration targets
# or unset targets that are no longer valid
func exploration_decision_precalculation():
	reserved_exploration_targets = {}
	var world_units : Array = unit_objective_groups.get( WorldUnit.OBJECTIVE.EXPLORE, [])
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		if(world_unit.target_set):
			var target_coord : Vector2i = world_unit.target_map_coord
			var target_plot : PlotVO = GardenManager.get_plot(target_coord)
			if(target_plot.is_explored()):
				# clear target if target is already explored
				world_unit.target_set = false
			elif(reserved_exploration_targets.has(target_coord) && reserved_exploration_targets.get(target_coord) != world_unit.get_id()):
				# clear target if already reserved by another unit
				world_unit.target_set = false
			else:
				# reserve exploration target
				reserved_exploration_targets[target_coord] = world_unit.get_id()

func action_decision():
	action_queue = []
	exploration_decision()

func exploration_decision():
	var world_units : Array = unit_objective_groups.get( WorldUnit.OBJECTIVE.EXPLORE, [])
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		
		# if no explore target set, choose a new target
		if(!world_unit.target_set):
			#TODO : smarter target decision, this is just minimum viable filler
			for plot_coord in GardenManager.get_used_plot_coords():
				if(reserved_exploration_targets.has(plot_coord as Vector2i)):
					# skip plots that are already target for exploration
					continue
				var plot : PlotVO = GardenManager.get_plot(plot_coord)
				if(!plot.is_explored()):
					world_unit.target_map_coord = plot.coord
					world_unit.target_set = true
					
					# reserve exploration target
					reserved_exploration_targets[plot.coord] = world_unit.get_id()
					break
		
		if(world_unit.target_set):
			if(world_unit.get_coord() != world_unit.target_map_coord):
				# move towards exploration target
				var action := ActionObject.new()
				action.unit_id = world_unit.get_id()
				action.action_type = ACTION.MOVE
				action.move_coord = world_navigation_controller.get_next_path_step(world_unit.get_coord(), world_unit.target_map_coord)
				action_queue.append(action)
			else:
				#explore current position
				var current_plot : PlotVO = GardenManager.get_plot(world_unit.get_coord())
				if(!current_plot.is_explored()):
					var action := ActionObject.new()
					action.unit_id = world_unit.get_id()
					action.action_type = ACTION.EXPLORE
					
					action_queue.append(action)

var waiting_on_ids : Array = []

func execute_unit_actions():
	waiting_on_ids = []
	
	while(action_queue.size() > 0):
		var action : ActionObject = action_queue.pop_back()
		
		var unit : WorldUnit = world_units_manager.get_world_unit(action.unit_id)
		if(action.action_type == ACTION.MOVE):
			waiting_on_ids.append(unit.get_id())
			unit.action_complete.connect(_on_unit_action_complete, CONNECT_ONESHOT)
			unit.start_move_action(action.move_coord)
		if(action.action_type == ACTION.EXPLORE):
			var plot_coord = unit.get_coord()
			GardenManager.explore_plot(unit.get_coord())

func _on_unit_action_complete(id : int):
	waiting_on_ids.erase(id)

func set_ready_for_next_turn():
	ready_for_next_turn = true
