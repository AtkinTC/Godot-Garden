extends PlotComponent
class_name JobPlotComponent

var job_progress : float
var job_running : bool
var level : int

func _init(_coord : Vector2, _object_key : String, _level : int = 1):
	coord = _coord
	object_key = _object_key
	level = _level
	
	job_progress = 0.0
	job_running = true

func step(_delta : float):
	if(!job_running):
		return
		
	complete_job()
	
	if(!job_running):
		return
	
	job_progress += ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.JOB_SPEED_SATISFIED, 0.0) * _delta

# complete the current job
func complete_job():
	if(job_progress < ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.JOB_LENGTH, 0.0)):
		return
	
	var reward_dict : Dictionary = ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.JOB_COMPLETION_REWARD, {})
	
	for key in reward_dict:
		SupplyManager.get_supply(key).change_quantity(reward_dict[key])
		
	# reset job progress 
	job_progress = 0.0

func get_job_progress() -> float:
	return job_progress

func get_job_progress_percent() -> float:
	var job_length : float =  ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.JOB_LENGTH, 0.0)
	if(job_length <= 0):
		return -1.0
	return job_progress * 100.0 / job_length
	
