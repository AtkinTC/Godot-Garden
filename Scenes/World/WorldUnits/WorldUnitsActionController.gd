class_name WorldUnitsActionController
extends Node2D

enum ACTION {NONE, MOVE, EXPLORE}

class ActionObject:
	var unit_id : int
	var action_type : ACTION
	var move_coord : Vector2i

@onready var world : World = self.get_parent()
@onready var world_units_manager : WorldUnitsManager = get_node("../WorldUnitsManager") #TODO: UGLY

var ready_for_next_turn : bool = false

var unit_action_groups : Dictionary

var action_queue : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(1.0).timeout.connect(set_ready_for_next_turn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(ready_for_next_turn):
		ready_for_next_turn = false
		process_turn()

func process_turn() -> void:
	update_unit_action_states()
	action_decision_precalculation()
	action_decision()
	execute_unit_actions()
	
	get_tree().create_timer(0.5).timeout.connect(set_ready_for_next_turn)

func update_unit_action_states():
	var world_units : Array = world_units_manager.get_world_units()
	unit_action_groups = {}
	
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		var current_plot : Plot = GardenManager.get_plot(world_unit.world_map_coord)
		
		if(world_unit.action_state == WorldUnit.ACTION.NONE):
			world_unit.action_state = WorldUnit.ACTION.EXPLORE
			world_unit.target_set = false
		
		var group : Array = unit_action_groups.get(world_unit.action_state, [])
		group.append(world_unit)
		unit_action_groups[world_unit.action_state] = group

var exploration_targets : Dictionary

func action_decision_precalculation():
	exploration_decision_precalculation()

func exploration_decision_precalculation():
	exploration_targets = {}
	var world_units : Array = unit_action_groups.get( WorldUnit.ACTION.EXPLORE, [])
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		if(world_unit.target_set):
			var target_plot : Plot = GardenManager.get_plot(world_unit.target_map_coord)
			if(target_plot.is_explored()):
				# clear target if target is already explored
				world_unit.target_set = false
			else:
				# record exploration targets that are already set
				var target_group : Array = exploration_targets.get(world_unit.target_map_coord, [])
				target_group.append(world_unit)
				exploration_targets[world_unit.target_map_coord] = target_group

func action_decision():
	action_queue = []
	exploration_decision()

func exploration_decision():
	var world_units : Array = unit_action_groups.get( WorldUnit.ACTION.EXPLORE, [])
	for i in world_units.size():
		var world_unit : WorldUnit = world_units[i]
		
		# if no explore target set, choose a new target
		if(!world_unit.target_set):
			#TODO : smarter target decision, this is just minimum viable filler
			for plot_coord in GardenManager.get_used_plots():
				if(exploration_targets.has(plot_coord as Vector2i)):
					# skip plots that are already target for exploration
					continue
				var plot : Plot = GardenManager.get_plot(plot_coord)
				if(!plot.is_explored()):
					world_unit.target_map_coord = (plot as Plot).coord
					world_unit.target_set = true
					
					# add target to selected exploration targets
					var target_group : Array = exploration_targets.get(world_unit.target_map_coord, [])
					target_group.append(world_unit)
					exploration_targets[world_unit.target_map_coord] = target_group
					break
		
		if(world_unit.target_set):
			if(world_unit.world_map_coord != world_unit.target_map_coord):
				# move towards exploration target
				var action := ActionObject.new()
				action.unit_id = world_unit.id
				action.action_type = ACTION.MOVE
				action.move_coord = world_unit.target_map_coord
				action_queue.append(action)
			else:
				#explore current position
				var current_plot : Plot = GardenManager.get_plot(world_unit.world_map_coord)
				if(!current_plot.is_explored()):
					var action := ActionObject.new()
					action.unit_id = world_unit.id
					action.action_type = ACTION.EXPLORE
					
					action_queue.append(action)

func execute_unit_actions():
	while(action_queue.size() > 0):
		var action : ActionObject = action_queue.pop_back()
		
		var unit : WorldUnit = world_units_manager.get_world_unit(action.unit_id)
		if(action.action_type == ACTION.MOVE):
			unit.move_to(action.move_coord)
		if(action.action_type == ACTION.EXPLORE):
			var plot_coord = unit.world_map_coord
			ActionManager.apply_action_to_plot("EXPLORE_PLOT", unit.world_map_coord)

func set_ready_for_next_turn():
	ready_for_next_turn = true
