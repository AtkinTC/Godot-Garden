extends Node2D

func _process(_delta):
	PlantManager.step_garden_plots(_delta)
