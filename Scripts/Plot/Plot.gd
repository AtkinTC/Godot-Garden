class_name Plot

signal plot_object_changed()

var coord : Vector2 = Vector2.ZERO
var object_key : String = ""
var components : Dictionary = {}

#purchase and insert object to the plot
func purchase_object(_object_key : String = ""):
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
	for comp in components.values():
		comp.cleanup_before_delete()
	components = {}
	var object_type := get_object_type()
	if(object_type.get(ObjectsManager.PASSIVE_GAIN, null) != null):
		var job_comp := PassivePlotComponent.new(coord, object_key)
		components["PASSIVE"] = job_comp
	if(object_type.get(ObjectsManager.JOB_LENGTH, null) != null):
		var job_comp := JobPlotComponent.new(coord, object_key)
		components["JOB"] = job_comp
	if(object_type.get(ObjectsManager.CAPACITY, null) != null):
		var job_comp := CapacityPlotComponent.new(coord, object_key)
		components["CAPACITY"] = job_comp
	
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
