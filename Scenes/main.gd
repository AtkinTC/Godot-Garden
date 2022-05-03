extends Node2D

var step_timer : Timer

func _ready():
	#start step timer
	step_timer = Timer.new()
	step_timer.wait_time = 0.1
	step_timer.one_shot = true
	step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(step_timer)
	step_timer.start()

func _process(_delta):
	pass

func _on_step_timer_timeout():
	PlantManager.step_garden_plots()
	step_timer.start()

