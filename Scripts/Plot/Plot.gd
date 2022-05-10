class_name Plot

signal plot_object_changed()

var coord : Vector2 = Vector2.ZERO
var object_key : String = ""
var components : Dictionary = {}
var level : int = 0

var under_construction : bool = false

#purchase and insert object to the plot
func purchase_object(_object_key : String = "", _level : int = 1):
	if(!get_object_type().get(Const.REMOVABLE, true) || under_construction):
		return false
	
	if(_object_key == ""):
		object_key = ObjectsManager.selected_object_key
	else:
		object_key = _object_key
	
	var object_type := get_object_type()
	
	if(object_type == null || object_type.size() == 0):
		return false
		
	var purchase_price : Dictionary = object_type.get(Const.PURCHASE_COST, {})
	if(!PurchaseManager.can_afford(purchase_price)):
		return false
	PurchaseManager.spend(purchase_price)
	
	level = _level
	apply_set_object()
	
	plot_object_changed.emit()
	
	return true

#insert object to the plot
func insert_object(_object_key : String = "", _level : int = 1, skip_build : bool = false):
	if(_object_key == ""):
		object_key = ObjectsManager.get_selected_object_key()
	else:
		object_key = _object_key
	
	var object_type := get_object_type()
	
	if(object_type == null || object_type.size() == 0):
		return false
	
	level = _level
	apply_set_object(skip_build)
	
	plot_object_changed.emit()
	
	return true

#reset the plot components for the currently applied object type
func apply_set_object(skip_build : bool = false):
	clear_components()
	setup_components(skip_build)
	
	plot_object_changed.emit()

func clear_components():
	for comp in components.values():
		comp.cleanup_before_delete()
	components = {}

func setup_components(build_complete : bool = false):
	var object_type := get_object_type()
	
	#if object needs to be built, then only setup BuildPlotComponent
	if(!build_complete && object_type.get(Const.BUILD_LENGTH, null) != null):
		var comp := BuildPlotComponent.new(coord, object_key)
		comp.build_complete.connect(_on_build_complete)
		components[Const.BUILD] = comp
		under_construction = true
		return
	
	if(object_type.get(Const.PASSIVE_GAIN, null) != null):
		var comp := PassivePlotComponent.new(coord, object_key, level)
		components[Const.PASSIVE] = comp
	if(object_type.get(Const.JOB_LENGTH, null) != null):
		var comp := JobPlotComponent.new(coord, object_key, level)
		components[Const.JOB] = comp
	if(object_type.get(Const.CAPACITY, null) != null):
		var comp := CapacityPlotComponent.new(coord, object_key, level)
		components[Const.CAPACITY] = comp
	
	under_construction = false

#apply upgrade action to plot object
func upgrade_object():
	if(!get_object_type().has(Const.UPGRADE) || level < 1 || under_construction):
		return false
	
	var upgrade : Dictionary = get_object_type().get(Const.UPGRADE)
	
	var upgrade_instant : bool
	if(upgrade.has(Const.UPGRADE_LENGTH)):
		upgrade_instant = (upgrade.get(Const.UPGRADE_LENGTH) <= 0)
	else:
		upgrade_instant = (get_object_type().get(Const.BUILD_LENGTH, 0) <= 0)
	
	if(upgrade_instant):
		#apply upgrade immediatly
		#TODO: spend purchase/upgrade cost to perform instant upgrade
		if(get_object_type().has(Const.UPGRADE_OBJECT)):
			var upgrade_key : String = upgrade.get(Const.UPGRADE_OBJECT)
			insert_object(upgrade_key, 1, true)
		else:
			var price_modifier := 1.0
			if(upgrade.has(Const.PRICE_MODIFIER_TYPE)):
				var price_modifier_type : String = upgrade.get(Const.PRICE_MODIFIER_TYPE)
				if(price_modifier_type == Const.PRICE_MODIFIER_FLAT_LEVEL):
					price_modifier = level + 1
			
			insert_object(object_key, level + 1, true)
	else:
		#setup upgrade component progress upgrade job
		var comp := UpgradePlotComponent.new(coord, object_key, level)
		comp.upgrade_complete.connect(_on_upgrade_complete)
		components[Const.UPGRADE] = comp
		under_construction = true
		
		plot_object_changed.emit()
	
	return true
	
func remove_object():
	var object_type := get_object_type()
	
	if(!object_type.get(Const.REMOVABLE, true)):
		return false
	
	object_key = ""
	
	clear_components()
	
	plot_object_changed.emit()

func step(_delta : float):
	for comp_key in components.keys():
		(components[comp_key] as PlotComponent).step(_delta)

func set_coord(_coord : Vector2):
	coord = _coord

func get_coord() -> Vector2:
	return coord

func get_component(comp_key : String):
	return components.get(comp_key)

func get_object_key() -> String:
	return object_key

func get_object_type() -> Dictionary:
	return ObjectsManager.get_object_type(object_key)

func get_level () -> int:
	return level

func _on_build_complete():
	clear_components()
	setup_components(true)
	plot_object_changed.emit()

func _on_upgrade_complete():
	var upgrade : Dictionary = get_object_type().get(Const.UPGRADE)
	if(upgrade.has(Const.UPGRADE_OBJECT)):
		# replace with the target upgrade object
		insert_object(upgrade.get(Const.UPGRADE_OBJECT), 1, true)
	else:
		# level up current object
		insert_object(object_key, level + 1, true)
