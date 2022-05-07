extends Node2D

func _init():
	SupplyManager.initialize()
	GardenManager.initialize()

func _process(_delta):
	GardenManager.step_plots(_delta)
