extends Node2D

@onready var garden_plot_scene : PackedScene = preload("res://Scenes/Garden/GardenPlotNode.tscn")

@onready var garden_grid : GridContainer = $Control/H/GardenGrid

@export_range(1, 100) var width : int = 10
@export_range(1, 100) var height : int = 10

var step_timer : Timer

var garden_plots := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in garden_grid.get_children():
		child.queue_free()
	
	garden_grid.set_columns(width)
	
	for y in height:
		for x in width:
			var garden_plot : GardenPlot = GardenPlot.new()
			garden_plot.set_coord(Vector2(x,y))
			garden_plots[Vector2(x,y)] = garden_plot
			
			var garden_plot_node : GardenPlotNode = garden_plot_scene.instantiate()
			garden_plot_node.set_garden_plot(garden_plot)
			
			garden_grid.add_child(garden_plot_node)
	
	step_timer = Timer.new()
	step_timer.wait_time = 0.1
	step_timer.one_shot = true
	step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(step_timer)
	step_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_step_timer_timeout():
	for coord in garden_plots.keys():
		(garden_plots[coord] as GardenPlot).step()
	
	step_timer.start()
