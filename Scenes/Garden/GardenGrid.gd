extends Control
class_name GardenGrid

@onready var garden_plot_node_scene : PackedScene = preload("res://Scenes/Garden/GardenPlotNode.tscn")

@onready var grid : GridContainer = $UIGrid/Grid

var min_x : int = -1
var max_x : int = 1
var min_y : int = -1
var max_y : int = 1

@export var plot_base_price : float = (100.0/3)
@export var min_garden_size : int = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2.ZERO
	PlantManager.setup_garden_plots(Vector2(width(), height()), Vector2(min_x, min_y))
	reset_grid_plots()

func width() -> int:
	return max_x - min_x + 1

func height()  -> int:
	return max_y - min_y + 1

func reset_grid_plots():
	for child in grid.get_children():
		child.queue_free()
	
	grid.set_columns(width())
	
	for y in range(min_y, max_y+1):
		for x in range(min_x, max_x+1):
			var garden_plot_node : GardenPlotNode = garden_plot_node_scene.instantiate()
			garden_plot_node.set_plot_coord(Vector2(x,y))
			grid.add_child(garden_plot_node)

func get_expansion_price(exp_v : Vector2) -> float:
	var new_width : int = width() + abs(exp_v.x)
	var new_height : int = height() + abs(exp_v.y)
	
	var current_plots := width() * height()
	var new_plots := (new_width * new_height) - current_plots
	
	return plot_base_price * new_plots * (current_plots * 1.0 / min_garden_size)
	
func purchase_expansion(exp_v : Vector2):
	var total_cost := {"MONEY": get_expansion_price(exp_v)}
	if(!PurchaseManager.can_afford(total_cost)):
		return
		
	PurchaseManager.spend(total_cost)
	expand(exp_v)

func expand(exp_v : Vector2):
	min_x += min(exp_v.x, 0) as int
	max_x += max(exp_v.x, 0) as int
	min_y += min(exp_v.y, 0) as int
	max_y += max(exp_v.y, 0) as int
	
	PlantManager.setup_garden_plots(Vector2(width(), height()), Vector2(min_x, min_y))
	reset_grid_plots()

func _on_expand_panel_pressed(exp_v : Vector2):
	purchase_expansion(exp_v)
