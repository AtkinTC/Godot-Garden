class_name Plot

signal plot_object_changed()

var coord : Vector2 = Vector2.ZERO
var object_key : String = ""
var components : Dictionary = {}

func insert_object(_object_key : String = ""):
	if(_object_key == ""):
		object_key = ObjectsManager.selected_object_key
	else:
		object_key = _object_key
	
	var object_type := get_object_type()
	
	if(object_type == null || object_type.size() == 0):
		return
	
#	var purchase_price : Dictionary = plant_type[PlantManager.PURCHASE_PRICE]
#	if(!PurchaseManager.can_afford(purchase_price)):
#		return
#	PurchaseManager.spend(purchase_price)
	
	components = {}
	if(object_type.get(ObjectsManager.PASSIVE_RESOURCE_GAIN, null) != null):
		var job_comp := PassivePlotComponent.new(object_key)
		components["PASSIVE"] = job_comp
	elif(object_type.get(ObjectsManager.JOB_LENGTH, null) != null):
		var job_comp := JobPlotComponent.new(object_key)
		components["JOB"] = job_comp
	
	plot_object_changed.emit()

#func water_plot(water_amount : int = -1, override_capacity : bool = false):
#	var new_water_level = water_level
#	if(water_amount == -1):
#		## fills to capacity, or doesn't change if already above capacity
#		new_water_level = max(water_capacity, water_level)
#	else:
#		new_water_level = water_level + water_amount
#		if(!override_capacity):
#			## increase is capped by water_capacity, but doesn't change if already above capacity
#			new_water_level = max(water_level, min(new_water_level, water_capacity))
#
#	water_level = new_water_level

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
