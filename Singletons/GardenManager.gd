extends Node

signal garden_resized()
signal garden_state_changed()
signal garden_plot_updated(coord : Vector2)

var plot_type_neighbors := {
	"empty" : {
		"river" : 0.5,
		"forest" : 0.5,
		"field" : 0.5
	},
	"field" : {
		"forest" : 0.25,
		"field" : 0.75,
		"swamp" : 0.1,
		"cave" : 0.05
	},
	"forest" : {
		"forest" : 0.5,
		"field" : 0.5,
		"cave" : 0.2,
		"swamp" : 0.2
	},
	"cave" : {
		"cave" : 0.1,
		"forest" : 0.5,
		"field" : 0.5,
	},
	"swamp" : {
		"swamp" : 0.25,
		"field" : 0.5
	},
	"river" : {
		"river" : 1.0
	},
}

var plots_dict : Dictionary
var min_x : int
var max_x : int
var min_y : int
var max_y : int

var owned_plots : int = 0

var wave_collapse : WaveCollapse

# setup initial state of the garden
func initialize():
	wave_collapse = WaveCollapse.new(TileDefinitions.cell_defs, Vector2i(-20,-20), Vector2i(20,20))

func setup_from_plots_array(plots : Array):
	plots_dict = {}
	for i in plots.size():
		var plot : PlotVO = plots[i]
		insert_plot(plot)

# process step time for all garden plots
func step_plots(step_time : float):
	for p in plots_dict.values():
		if(p.has_method("step")):
			(p as PlotVO).step(step_time)

# create and insert a plot with an automatically selected plot type
func create_plot_auto(coord : Vector2, base_type : String) -> PlotVO:
	var plot_type : String = wave_collapse.collapse_cell(coord)
	
	var plot : PlotVO = PlotVO.new()
	plot.set_coord(coord)
	plot.set_display_name(plot_type)
	plot.set_plot_type(plot_type)
	plot.set_base_type(base_type)
	
	insert_plot(plot)
	return plot

# create and insert a plot with a set plot type
func create_plot(coord : Vector2, plot_type : String, base_type : String) -> PlotVO:
	var plot : PlotVO = PlotVO.new()
	plot.set_coord(coord)
	plot.set_display_name(plot_type)
	plot.set_plot_type(plot_type)
	plot.set_base_type(base_type)
	wave_collapse.collapse_cell_forced(coord, plot_type)
	insert_plot(plot)
	return plot

# internal use only, new plots should be inserted using create_plot_auto or create_plot
func insert_plot(plot : PlotVO):
	plot.changed.connect(_on_plot_updated.bind(plot.get_coord()))
	plots_dict[plot.get_coord()] = plot
	update_extents(plot.get_coord())
	garden_plot_updated.emit(plot.get_coord())

func update_extents(coord : Vector2):
	var changed = false
	if(min_x == null || coord.x < min_x):
		min_x = coord.x as int
		changed = true
	if(min_y == null || coord.y < min_y):
		min_y = coord.y as int
		changed = true
	if(max_x == null || coord.x > max_x):
		max_x = coord.x as int
		changed = true
	if(max_y == null || coord.y > max_y):
		max_y = coord.y as int
		changed = true
	if(changed):
		garden_resized.emit()

func get_extents() -> Rect2:
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func get_garden_rect() -> Rect2:
	#return garden_rect
	return get_extents()

func set_plot(coord : Vector2, plot : PlotVO):
	#plots.set_at(coord, plot)
	insert_plot(plot)

func get_used_plot_coords() -> Array:
	return plots_dict.keys()

func get_used_plots() -> Array:
	return plots_dict.values()

func get_plot(coord : Vector2i) -> PlotVO:
	return plots_dict.get(coord, null)

func connect_garden_resized(reciever_method : Callable):
	garden_resized.connect(reciever_method)

func get_empty_neighbors(coord : Vector2) -> Array:
	var neighbors := []
	for d in [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]:
		var neighbor : PlotVO = get_plot(coord+d)
		if(neighbor == null):
			neighbors.append(coord+d)
	return neighbors

# returns the dictionary of potential neighbor types for this plot type
func get_plot_type_neighbors(plot_type : String) -> Dictionary:
	return plot_type_neighbors.get(plot_type, {})

# Begin the exploration process
# A character assigned to the plot advances the exploration progress
# new plots/features/items are earned when an exploration stage is completed
func explore_plot(coord : Vector2i):
	var plot : PlotVO = get_plot(coord)
	if(plot == null || plot.explored):
		return
	complete_exploration(coord)

# triggered on the completion of an exploration stage
# reveals neighboring plots and gives other rewards
func complete_exploration(coord : Vector2i):
	var plot : PlotVO = get_plot(coord)
	if(plot == null):
		return
	
	plot.set_owned(true)
	plot.set_explored(true)
	
	var empty_neighbor_coords = GardenManager.get_empty_neighbors(coord)
	
	var found : int = empty_neighbor_coords.size() 
#	if(empty_neighbor_coords.size() > 1):
#		found = randi() % empty_neighbor_coords.size() + 1
#
#	if(found < empty_neighbor_coords.size()):
#		empty_neighbor_coords.shuffle()
	
	for i in found:
		var neighbor_coord : Vector2i = empty_neighbor_coords[i]
		var base_type : String = "grass"
		var n_plot = create_plot_auto(neighbor_coord, base_type)
	
	plot.changed.emit()

func _on_plot_updated(coord : Vector2):
	var updated_plot : PlotVO = get_plot(coord)
	
	if(updated_plot == null):
		return false

#func step(_delta : float):
#	if(plot_structure != null):
#		plot_structure.step(_delta)
#
#func purchase_structure(_structure_key : String = ""):
#	if(!explored || !owned):
#		return
#	insert_structure(_structure_key)
#
#func insert_structure(_structure_key : String = ""):
#	var temp_structure_key
#	if(_structure_key == ""):
#		temp_structure_key = StructuresManager.get_selected_structure_key()
#	else:
#		temp_structure_key = _structure_key
#
#	if(temp_structure_key == null || temp_structure_key == ""):
#		return false
#
#	StructuresManager.adjust_structure_count(temp_structure_key, 1)
#	plot_structure = Structure.new(temp_structure_key, coord)
#	plot_structure.start_building()
#	plot_structure.structure_updated.connect(_on_structure_updated)
#	plot_updated.emit(coord)
#
#func upgrade_structure():
#	if(plot_structure == null):
#		return false
#	if(!plot_structure.can_be_upgraded()):
#		return false
#
#	plot_structure.start_upgrading()
#	plot_updated.emit(coord)
#
#func remove_structure():
#	if(!owned):
#		return false
#	if(plot_structure == null):
#		return false
#	if(!plot_structure.get_structure_data().is_removable()):
#		return false
#
#	StructuresManager.adjust_structure_count(plot_structure.get_structure_key(), -1)
#	plot_structure.cleanup_before_delete()
#	plot_structure = null
#	plot_updated.emit(coord)
