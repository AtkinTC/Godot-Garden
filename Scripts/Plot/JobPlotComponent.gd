extends PlotComponent
class_name JobPlotComponent

var object_key : String

var job_progress : float
var job_running : bool

var plant_display_name : String

func _init(_object_key : String):
	object_key = _object_key
	
	job_progress = 0.0
	job_running = true

func get_object_attribute(attr_key : String, default = null) -> Variant:
	var val : Variant = ObjectsManager.get_object_type_attribute(object_key, attr_key)
	if(val == null):
		return default
	return val

func step(_delta : float):
	if(!job_running):
		return
		
	complete_job()
	
	if(!job_running):
		return
	
	job_progress += get_object_attribute(ObjectsManager.JOB_SPEED_SATISFIED, 0.0) * _delta

# complete the current job
func complete_job():
	if(job_progress < get_object_attribute(ObjectsManager.JOB_LENGTH, 0.0)):
		return
	
	var reward_dict : Dictionary = get_object_attribute(ObjectsManager.JOB_COMPLETION_REWARD, {})
	
	for resource_key in reward_dict:
		ResourceManager.change_resource_quantity(resource_key, reward_dict[resource_key])
		#var current_amount = ResourceManager.get_resource_attribute(resource_key, ResourceManager.AMOUNT)
		#var new_amount = current_amount + reward_dict[resource_key]
		#ResourceManager.set_resource_attribute(resource_key, ResourceManager.AMOUNT, new_amount)
		
	# reset job progress 
	job_progress = 0.0

func get_job_progress() -> float:
	return job_progress

func get_job_progress_percent() -> float:
	var job_length : float =  get_object_attribute(ObjectsManager.JOB_LENGTH, 0.0)
	if(job_length <= 0):
		return -1.0
	return job_progress * 100.0 / job_length
	
