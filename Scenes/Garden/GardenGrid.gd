extends Control
class_name GardenGrid

@export var base_plot_node_scene : PackedScene

@onready var grid : GridContainer = $UIGrid/Grid

var initialized := false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2.ZERO
	GardenManager.connect_garden_resized(_on_garden_resized)
	reset_grid_plots()

func reset_grid_plots():
	for child in grid.get_children():
		child.queue_free()
	
	var _offset : Vector2 = GardenManager.get_garden_rect().position
	var _size : Vector2 = GardenManager.get_garden_rect().size
	
	grid.set_columns(_size.x as int)
	
	for y in range(_offset.y, _offset.y + _size.y):
		for x in range(_offset.x, _offset.x + _size.x):
			var garden_plot_node = base_plot_node_scene.instantiate()
			garden_plot_node.set_plot_coord(Vector2(x,y))
			grid.add_child(garden_plot_node)

func _on_expand_panel_pressed(exp_v : Vector2):
	GardenManager.purchase_expansion(exp_v)

func _on_garden_resized():
	reset_grid_plots()
