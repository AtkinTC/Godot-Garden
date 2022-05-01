extends Control
class_name GardenPlotNode

var garden_plot : GardenPlot

@onready var coord_label : Label = $V/CoordLabel
@onready var planted_label : Label = $V/PlantedLabel
@onready var grow_progress_bar : TextureProgressBar = $V/GrowProgressBar
@onready var water_progress_bar : TextureProgressBar = $V/WaterProgressBar

@onready var plant_button : Button = $V/PlantButton
@onready var water_button : Button = $V/WaterButton

func _ready():
	update_display()

func _process(delta):
	update_display()

func set_garden_plot(_garden_plot : GardenPlot) -> void:
	garden_plot = _garden_plot

func update_display():
	if(!garden_plot):
		return
	coord_label.text = str(garden_plot.get_coord())
	planted_label.text = "Planted : " + str(garden_plot.is_planted())

	grow_progress_bar.max_value = garden_plot.get_grow_capacity()
	grow_progress_bar.value = garden_plot.get_grow_progress()
	
	water_progress_bar.max_value = garden_plot.get_water_capacity()
	water_progress_bar.value = garden_plot.get_water_level()
	
	plant_button.disabled = garden_plot.is_planted()

func _on_plant_button_pressed():
	garden_plot.plant_plot()
	update_display()

func _on_water_button_pressed():
	garden_plot.water_plot()
	update_display()
