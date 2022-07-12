class_name Plot

signal plot_updated(coord : Vector2)

var explored : bool = false
var owned : bool = false
var coord : Vector2i = Vector2i.ZERO

var plot_type : String
var base_type : String
var display_name : String

var plot_structure : Structure
var plot_area : AreaVO

func step(_delta : float):
	if(plot_structure != null):
		plot_structure.step(_delta)

# Begin the exploration process
# A character assigned to the plot advances the exploration progress
# new plots/features/items are earned when an exploration stage is completed
func explore():
	if(explored):
		return
	complete_exploration()

# triggered on the completion of an exploration stage
# reveals neighboring plots and gives other rewards
func complete_exploration():
	owned = true
	explored = true
	
	var empty_neighbor_coords = GardenManager.get_empty_neighbors(coord)

	for neighbor_coord in empty_neighbor_coords:
		var plot = GardenManager.create_plot(neighbor_coord)
		plot.set_display_name(plot_type)
		plot.plot_type = GardenManager.select_plot_type_neighbor(plot_type)
		plot.base_type = "grass"
		plot.plot_updated.emit(neighbor_coord)
	
	plot_updated.emit(coord)

func purchase_structure(_structure_key : String = ""):
	if(!explored || !owned):
		return
	insert_structure(_structure_key)

func insert_structure(_structure_key : String = ""):
	var temp_structure_key
	if(_structure_key == ""):
		temp_structure_key = StructuresManager.get_selected_structure_key()
	else:
		temp_structure_key = _structure_key
	
	if(temp_structure_key == null || temp_structure_key == ""):
		return false
	
	StructuresManager.adjust_structure_count(temp_structure_key, 1)
	plot_structure = Structure.new(temp_structure_key, coord)
	plot_structure.start_building()
	plot_structure.structure_updated.connect(_on_structure_updated)
	plot_updated.emit(coord)

func upgrade_structure():
	if(plot_structure == null):
		return false
	if(!plot_structure.can_be_upgraded()):
		return false
	
	plot_structure.start_upgrading()
	plot_updated.emit(coord)

func remove_structure():
	if(!owned):
		return false
	if(plot_structure == null):
		return false
	if(!plot_structure.get_structure_data().is_removable()):
		return false
	
	StructuresManager.adjust_structure_count(plot_structure.get_structure_key(), -1)
	plot_structure.cleanup_before_delete()
	plot_structure = null
	plot_updated.emit(coord)

func set_coord(_coord : Vector2i):
	coord = _coord

func get_coord() -> Vector2i:
	return coord

func has_structure():
	return (plot_structure != null)

func get_structure() -> Structure:
	return plot_structure

func set_owned(_owned : bool):
	owned = _owned

func is_owned() -> bool:
	return owned

func set_area(area : AreaVO):
	plot_area = area

func get_area() -> AreaVO:
	return plot_area

func has_area() -> bool:
	return (plot_area != null)

func set_explored(_explored : bool):
	explored = _explored

func is_explored() -> bool:
	return explored

func set_display_name(_display_name : String):
	display_name = _display_name

func get_display_name() -> String:
	if(explored):
		return display_name
	else:
		return "?" + display_name + "?"

func _on_structure_updated(_world_coord : Vector2i):
	if(_world_coord == coord):
		plot_updated.emit(coord)
