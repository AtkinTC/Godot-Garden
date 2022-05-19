extends PlotComponent
class_name UpgradePlotComponent

signal upgrade_complete()

var upgrade_progress : float
var upgrade_length : float
var current_level : int

var completed : bool

func _init(_coord : Vector2, _object_key : String, _current_level : int = 0):
	coord = _coord
	object_key = _object_key
	current_level = _current_level
	completed = false
	
	var object_type := ObjectsManager.get_object_type(_object_key)
	var upgrade_dict : Dictionary = object_type.get(Const.UPGRADE)
	
	# fall back on the LENGTH if no LENGTH set
	if(upgrade_dict.has(Const.LENGTH)):
		upgrade_length = upgrade_dict.get(Const.LENGTH, -1.0)
	else:
		upgrade_length = object_type.get(Const.LENGTH, -1.0)
		
	upgrade_progress = 0.0


func step(_delta : float):
	if(!running || completed):
		running = false
		return
		
	complete_upgrade()
	
	if(!running):
		return
		
	upgrade_progress += _delta

# complete the current job
func complete_upgrade():
	if(upgrade_length > 0 && upgrade_progress < ((current_level + 1) * upgrade_length)):
		return
	upgrade_complete.emit()
	running = false
	completed = true

func get_progress() -> float:
	return upgrade_progress

func get_progress_percent() -> float:
	if(upgrade_length <= 0):
		return -1.0
	return upgrade_progress * 100.0 / ((current_level + 1) * upgrade_length)
	
