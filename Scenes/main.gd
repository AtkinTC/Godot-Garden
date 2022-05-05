extends Node2D

func _process(_delta):
	GardenManager.step_plots(_delta)
