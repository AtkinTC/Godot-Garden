extends Control
class_name GardenGrid

@onready var garden_plot_node_scene : PackedScene = preload("res://Scenes/Garden/GardenPlotNode.tscn")

@onready var grid : GridContainer = $UIGrid/Grid

var width: int = 3
var height: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	PlantManager.setup_garden_plots(width, height)
	reset_grid_plots()

func reset_grid_plots():
	for child in grid.get_children():
		child.queue_free()
	
	grid.set_columns(width)
	
	for y in height:
		for x in width:
			var garden_plot_node : GardenPlotNode = garden_plot_node_scene.instantiate()
			garden_plot_node.set_plot_coord(Vector2(x,y))
			grid.add_child(garden_plot_node)

func expand(right: int, down: int):
	width += right
	height += down
	
	PlantManager.setup_garden_plots(width, height)
	reset_grid_plots()

func _on_expand_right_button_pressed():
	expand(1,0)

func _on_expand_left_button_pressed():
	expand(0,1)
