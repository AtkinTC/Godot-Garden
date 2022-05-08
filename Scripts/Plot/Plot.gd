class_name Plot

signal plot_object_changed()

var coord : Vector2 = Vector2.ZERO
var object_key : String = ""
var components : Dictionary = {}

var build_progress : float

#purchase and insert object to the plot
func purchase_object(_object_key : String = ""):
	if(!get_object_type().get(ObjectsManager.REMOVABLE, true)):
		return false
	
	if(_object_key == ""):
		object_key = ObjectsManager.selected_object_key
	else:
		object_key = _object_key
	
	var object_type := get_object_type()
	
	if(object_type == null || object_type.size() == 0):
		return false
		
	var purchase_price : Dictionary = object_type.get(ObjectsManager.PURCHASE_COST, {})
	if(!PurchaseManager.can_afford(purchase_price)):
		return false
	PurchaseManager.spend(purchase_price)
	
	apply_set_object()
	
	plot_object_changed.emit()
	
	return true

#insert object to the plot
func insert_object(_object_key : String = ""):
	if(_object_key == ""):
		object_key = ObjectsManager.selected_object_key
	else:
		object_key = _object_key
	
	var object_type := get_object_type()
	
	if(object_type == null || object_type.size() == 0):
		return false
	
	apply_set_object()
	
	plot_object_changed.emit()
	
	return true

#reset the plot components for the currently applied object type
func apply_set_object():
	clear_components()
	setup_components()
	
	plot_object_changed.emit()

func clear_components():
	for comp in components.values():
		comp.cleanup_before_delete()
	components = {}

func setup_components(build_complete : bool = false):
	var object_type := get_object_type()
	
	#if object needs to be built, then only setup BuildPlotComponent
	if(!build_complete && object_type.get(ObjectsManager.BUILD_LENGTH, null) != null):
		var comp := BuildPlotComponent.new(coord, object_key)
		comp.build_complete.connect(_on_build_complete)
		components["BUILD"] = comp
		return
	
	if(object_type.get(ObjectsManager.PASSIVE_GAIN, null) != null):
		var comp := PassivePlotComponent.new(coord, object_key)
		components["PASSIVE"] = comp
	if(object_type.get(ObjectsManager.JOB_LENGTH, null) != null):
		var comp := JobPlotComponent.new(coord, object_key)
		components["JOB"] = comp
	if(object_type.get(ObjectsManager.CAPACITY, null) != null):
		var comp := CapacityPlotComponent.new(coord, object_key)
		components["CAPACITY"] = comp

#apply upgrade action to plot object
func upgrade_object():
	var upgrade_key : String = get_object_type().get(ObjectsManager.UPGRADE_OBJECT, "")
	if(upgrade_key == ""):
		return false
	
	var upgrade_instant : bool = (get_object_type().get(ObjectsManager.UPGRADE_LENGTH, 0) <= 0)
	
	if(upgrade_instant):
		#apply upgrade immediatly
		insert_object(upgrade_key)
	else:
		#setup upgrade component progress upgrade job
		var comp := UpgradePlotComponent.new(coord, object_key)
		comp.upgrade_complete.connect(_on_upgrade_complete)
		components["UPGRADE"] = comp
		
		plot_object_changed.emit()
	
	return true
	
func remove_object():
	var object_type := get_object_type()
	
	if(!object_type.get(ObjectsManager.REMOVABLE, true)):
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

func _on_build_complete():
	clear_components()
	setup_components(true)
	plot_object_changed.emit()

func _on_upgrade_complete():
	insert_object(get_object_type().get(ObjectsManager.UPGRADE_OBJECT))
