extends Node2D

func _init():
	SupplyManager.initialize()
	GardenManager.initialize()
	
	GardenManager.get_plot(Vector2(0,0)).insert_object("FOCUS_BASIC")

func _process(_delta):
	GardenManager.step_plots(_delta)
