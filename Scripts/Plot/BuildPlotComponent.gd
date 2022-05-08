extends PlotComponent
class_name BuildPlotComponent

signal build_complete()

var build_progress : float
var build_length : float
var build_cost : Dictionary

var build_running : bool

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	
	var object_type := ObjectsManager.get_object_type(_object_key)
	build_length = object_type.get(ObjectsManager.BUILD_LENGTH, -1.0)
	build_progress = 0.0
	build_cost = object_type.get(ObjectsManager.BUILD_COST, {})
		
	build_running = true

func step(_delta : float):
	if(!build_running):
		return
		
	complete_build()
	
	if(!build_running):
		return
	
	var build_cost_delta = {}
	for key in build_cost.keys():
		build_cost_delta[key] = build_cost[key]  * _delta / build_length
	
	if(PurchaseManager.can_afford(build_cost_delta)):
		for key in build_cost_delta.keys():
			SupplyManager.get_supply(key).change_quantity(-build_cost_delta[key])
		
		build_progress += _delta

# complete the current job
func complete_build():
	if(build_length > 0 && build_progress < build_length):
		return
	
	build_complete.emit()
		
	build_running = false

func get_build_progress() -> float:
	return build_progress

func get_build_progress_percent() -> float:
	if(build_length <= 0):
		return -1.0
	return build_progress * 100.0 / build_length
	
