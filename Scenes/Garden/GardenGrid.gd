extends Control
class_name GardenGrid

@onready var garden_plot_node_scene : PackedScene = preload("res://Scenes/Garden/GardenPlotNode.tscn")

@onready var grid : GridContainer = $UIGrid/Grid

@onready var expand_right_button: Button = $UIGrid/Right/ExpandRightButton
@onready var expand_down_button: Button = $UIGrid/Down/ExpandDownButton

var width: int = 3
var height: int = 3

@export var plot_base_price : float = (100.0/3)
@export var min_garden_size : int = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2.ZERO
	PlantManager.setup_garden_plots(width, height)
	reset_grid_plots()
	update_expand_price_display()

func reset_grid_plots():
	for child in grid.get_children():
		child.queue_free()
	
	grid.set_columns(width)
	
	for y in height:
		for x in width:
			var garden_plot_node : GardenPlotNode = garden_plot_node_scene.instantiate()
			garden_plot_node.set_plot_coord(Vector2(x,y))
			grid.add_child(garden_plot_node)

func get_expansion_price(right: int, down: int):
	var new_width := width + right
	var new_height := height + down
	
	var current_plots := width * height
	var new_plots := (new_width * new_height) - current_plots
	
	return plot_base_price * new_plots * (current_plots * 1.0 / min_garden_size)
	
func purchase_expansion(right: int, down: int):
	var total_cost := {"MONEY": get_expansion_price(right, down)}
	if(!PurchaseManager.can_afford(total_cost)):
		return
		
	PurchaseManager.spend(total_cost)
	expand(right, down)

func update_expand_price_display():
	var base_price_right : float = get_expansion_price(1, 0)
	var base_price_down : float = get_expansion_price(0, 1)
	
	expand_right_button.text = "Expand\n($%.2f)" % base_price_right
	expand_down_button.text = "Expand\n($%.2f)" % base_price_down

func expand(right: int, down: int):
	width += right
	height += down
	
	PlantManager.setup_garden_plots(width, height)
	reset_grid_plots()
	update_expand_price_display()

func _on_expand_right_button_pressed():
	purchase_expansion(1,0)

func _on_expand_left_button_pressed():
	purchase_expansion(0,1)
