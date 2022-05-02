extends Control
class_name GardenPlotNode

var plot_coord : Vector2

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

func set_plot_coord(_plot_coord : Vector2) -> void:
	plot_coord = _plot_coord

func update_display() -> void:
	coord_label.text = str(plot_coord)
	
	var garden_plot : GardenPlot = PlantManager.get_garden_plot(plot_coord)
	if(!garden_plot):
		return
	
	if(garden_plot.is_planted()):
		planted_label.text = "Planted : " + str(garden_plot.get_plant_display_name())

	grow_progress_bar.max_value = garden_plot.get_grow_capacity()
	grow_progress_bar.value = garden_plot.get_grow_progress()
	
	water_progress_bar.max_value = garden_plot.get_water_capacity()
	water_progress_bar.value = garden_plot.get_water_level()
	
	plant_button.disabled = garden_plot.is_planted()

func _on_plant_button_pressed():
	var garden_plot : GardenPlot = PlantManager.get_garden_plot(plot_coord)
	if(garden_plot):
		garden_plot.plant_plot()
	update_display()

func _on_water_button_pressed():
	var garden_plot : GardenPlot = PlantManager.get_garden_plot(plot_coord)
	if(garden_plot):
		garden_plot.water_plot()
	update_display()
