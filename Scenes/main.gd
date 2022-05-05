extends Node2D

func _process(_delta):
	GardenManager.step_garden_plots(_delta)
