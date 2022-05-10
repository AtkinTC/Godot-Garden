extends PlotComponent
class_name UpgradePlotComponent

signal upgrade_complete()

var upgrade_progress : float
var upgrade_length : float
var upgrade_cost : Dictionary
var current_level : int

var upgrade_running : bool

func _init(_coord : Vector2, _object_key : String, _current_level : int = 1):
	coord = _coord
	object_key = _object_key
	current_level = _current_level
	
	var object_type := ObjectsManager.get_object_type(_object_key)
	var upgrade_dict : Dictionary = object_type.get(Const.UPGRADE)
	
	# fall back on the BUILD_LENGTH if no UPGRADE_LENGTH set
	if(upgrade_dict.has(Const.UPGRADE_LENGTH)):
		upgrade_length = upgrade_dict.get(Const.UPGRADE_LENGTH, -1.0)
	else:
		upgrade_length = object_type.get(Const.BUILD_LENGTH, -1.0)
		
	upgrade_progress = 0.0
	
	# fall back on the BUILD_COST if no UPGRADE_COST set
	if(upgrade_dict.has(Const.UPGRADE_COST)):
		upgrade_cost = upgrade_dict.get(Const.UPGRADE_COST, {})
	else:
		upgrade_cost = object_type.get(Const.BUILD_COST, {})
	
	upgrade_running = true

func step(_delta : float):
	if(!upgrade_running):
		return
		
	complete_upgrade()
	
	if(!upgrade_running):
		return
	
	var upgrade_cost_delta = {}
	for key in upgrade_cost.keys():
		upgrade_cost_delta[key] = upgrade_cost[key] * current_level * _delta / upgrade_length
	
	if(PurchaseManager.can_afford(upgrade_cost_delta)):
		for key in upgrade_cost_delta.keys():
			SupplyManager.get_supply(key).change_quantity(-upgrade_cost_delta[key])
		
		upgrade_progress += _delta

# complete the current job
func complete_upgrade():
	if(upgrade_length > 0 && upgrade_progress < (upgrade_length * current_level)):
		return
	upgrade_complete.emit()
	upgrade_running = false

func get_progress() -> float:
	return upgrade_progress

func get_progress_percent() -> float:
	if(upgrade_length <= 0):
		return -1.0
	return upgrade_progress * 100.0 / (upgrade_length * current_level)
	
