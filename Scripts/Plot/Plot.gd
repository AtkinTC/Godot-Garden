class_name Plot

signal plot_updated(coord : Vector2)

var owned : bool = false
var available : bool = false
var visible : bool = false
var coord : Vector2 = Vector2.ZERO

var plot_structure : Structure

func purchase_plot():
	if(owned || !available):
		return
	
	# check if can afford to purchase plot
	var total_cost := GardenManager.get_plot_purchase_price(coord)
	if(!PurchaseUtil.can_afford(total_cost)):
		return
		
	# subtract spent resources
	PurchaseUtil.spend(total_cost)
	
	# purchase plot
	owned = true
	plot_updated.emit(coord)
	GardenManager.add_available_plots()

func purchase_structure(_structure_key : String = ""):
	if(!owned):
		return false
	if(plot_structure != null):
		return false
	
	var temp_structure_key
	if(_structure_key == ""):
		temp_structure_key = StructuresManager.get_selected_structure_key()
	else:
		temp_structure_key = _structure_key
	
	if(temp_structure_key == null || temp_structure_key == ""):
		return false
	
	var structure_data : StructureDAO = StructureDAO.new(temp_structure_key)
	
	var purchase_props := {
		Const.MOD_TARGET_CAT : Const.OBJECT,
		Const.MOD_TARGET_KEY : temp_structure_key,
		Const.MOD_TYPE : Const.BUILD,
		Const.COUNT : structure_data.get_count()
	}
	if(!PurchaseUtil.make_purchase(purchase_props)):
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
	
	var purchase_props := {
		Const.MOD_TARGET_CAT : Const.OBJECT,
		Const.MOD_TARGET_KEY : plot_structure.get_structure_key(),
		Const.MOD_TYPE : Const.UPGRADE,
		Const.LEVEL : plot_structure.get_upgrade_level()
	}
	if(!PurchaseUtil.make_purchase(purchase_props)):
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

func toggle_pause():
	if(plot_structure == null):
		return false
	pause_structure(!plot_structure.is_paused())

func pause_structure(_paused: bool = true):
	if(plot_structure == null):
		return false
		
	plot_structure.set_paused(_paused)

func step(_delta : float):
	if(plot_structure == null):
		return false
	plot_structure.step(_delta)

func set_visible(_visible : bool):
	if(visible != _visible):
		visible = _visible
		plot_updated.emit(coord)

func is_visible() -> bool:
	return visible

func set_coord(_coord : Vector2):
	coord = _coord

func get_coord() -> Vector2:
	return coord

func has_structure():
	return (plot_structure != null)

func get_structure() -> Structure:
	return plot_structure

func set_available(_available : bool):
	available = _available

func is_available() -> bool:
	return available

func set_owned(_owned : bool):
	owned = _owned

func is_owned() -> bool:
	return owned

func _on_structure_updated(_world_coord : Vector2):
	if(_world_coord == coord):
		plot_updated.emit(coord)
