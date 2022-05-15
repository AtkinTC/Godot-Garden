extends PlotComponent
class_name BuildPlotComponent

signal build_complete()

var build_progress : float
var build_length : float
var completed : bool

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	completed = false
	
	var object_type := ObjectsManager.get_object_type(_object_key)
	build_length = object_type.get(Const.BUILD, {}).get(Const.LENGTH, -1)
	build_progress = 0.0

func step(_delta : float):
	if(!running || completed):
		running = false
		return
		
	complete_build()
	
	if(!running):
		return
		
	build_progress += _delta

# complete the current job
func complete_build():
	if(build_length > 0 && build_progress < build_length):
		return
	build_complete.emit()
	running = false
	completed = true

func get_build_progress() -> float:
	return build_progress

func get_build_progress_percent() -> float:
	if(build_length <= 0):
		return -1.0
	return build_progress * 100.0 / build_length
	
