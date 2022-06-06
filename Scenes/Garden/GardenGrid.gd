extends Control
class_name GardenGrid

@export var base_plot_node_scene : PackedScene
@export var empty_plot_scene : PackedScene

@onready var grid : GridContainer = $UIGrid/Grid

var nodes := {}

var initialized := false

# Called when the node enters the scene tree for the first time.
func _ready():
	#position = Vector2.ZERO
	GardenManager.garden_resized.connect(_on_garden_resized)
	GardenManager.garden_plot_updated.connect(_on_garden_plot_updated)
	reset_grid_plots()

func reset_grid_plots():
	for child in grid.get_children():
		child.queue_free()
	
	var _offset : Vector2 = GardenManager.get_garden_rect().position
	var _size : Vector2 = GardenManager.get_garden_rect().size
	
	grid.set_columns(_size.x as int + 1)
	
	for y in range(_offset.y, _offset.y + _size.y + 1):
		for x in range(_offset.x, _offset.x + _size.x + 1):
			if(GardenManager.get_plot(Vector2(x,y)) != null):
				var garden_plot_node = base_plot_node_scene.instantiate()
				garden_plot_node.set_plot_coord(Vector2(x,y))
				grid.add_child(garden_plot_node)
				nodes[Vector2(x,y)] = garden_plot_node
			else:
				var empty_plot = empty_plot_scene.instantiate()
				grid.add_child(empty_plot)
				nodes[Vector2(x,y)] = empty_plot

func _on_expand_panel_pressed(exp_v : Vector2):
	GardenManager.purchase_expansion(exp_v)

func _on_garden_resized():
	reset_grid_plots()

func _on_garden_plot_updated(coord : Vector2):
	if(nodes.has(coord)):
		#deletes and recreates the display node
		var current_node = nodes.get(coord)
		var garden_plot_node = base_plot_node_scene.instantiate()
		garden_plot_node.set_plot_coord(coord)
		current_node.add_sibling(garden_plot_node)
		grid.remove_child(current_node)
		current_node.queue_free()
		
		nodes[coord] = garden_plot_node
