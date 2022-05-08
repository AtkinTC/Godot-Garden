extends PlotComponent
class_name UpgradePlotComponent

signal upgrade_complete()

var upgrade_progress : float
var upgrade_length : float
var upgrade_cost : Dictionary

var upgrade_running : bool

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	
	var object_type := ObjectsManager.get_object_type(_object_key)
	upgrade_length = object_type.get(ObjectsManager.UPGRADE_LENGTH, -1.0)
	upgrade_progress = 0.0
	upgrade_cost = object_type.get(ObjectsManager.UPGRADE_COST, {})
		
	upgrade_running = true

func step(_delta : float):
	if(!upgrade_running):
		return
		
	complete_upgrade()
	
	if(!upgrade_running):
		return
	
	var upgrade_cost_delta = {}
	for key in upgrade_cost.keys():
		upgrade_cost_delta[key] = upgrade_cost[key]  * _delta / upgrade_length
	
	if(PurchaseManager.can_afford(upgrade_cost_delta)):
		for key in upgrade_cost_delta.keys():
			SupplyManager.get_supply(key).change_quantity(-upgrade_cost_delta[key])
		
		upgrade_progress += _delta

# complete the current job
func complete_upgrade():
	if(upgrade_length > 0 && upgrade_progress < upgrade_length):
		return
	
	upgrade_complete.emit()
		
	upgrade_running = false

func get_progress() -> float:
	return upgrade_progress

func get_progress_percent() -> float:
	if(upgrade_length <= 0):
		return -1.0
	return upgrade_progress * 100.0 / upgrade_length
	
