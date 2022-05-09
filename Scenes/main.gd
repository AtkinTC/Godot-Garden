extends Node2D

func _init():
	ActionManager.initialize()
	SupplyManager.initialize()
	ObjectsManager.initialize()
	UpgradeManager.initialize()
	GardenManager.initialize()
	
	GardenManager.get_plot(Vector2(0,0)).insert_object("FOCUS_BASIC")

func _process(_delta):
	SupplyManager.step(_delta)
	GardenManager.step_plots(_delta)
