extends Control
class_name GardenPlotNode

enum ZOOM_STATES {ZOOMED_IN, ZOOMED_OUT}

var zoom_state = ZOOM_STATES.ZOOMED_IN
@export var zoom_threshold := 0.75

var plot_coord : Vector2

@onready var body : Control = $V

@onready var coord_label : Label = $V/CoordLabel
@onready var planted_label : Label = $V/PlantedLabel
@onready var grow_progress_bar : TextureProgressBar = $V/GrowProgressBar
@onready var water_progress_bar : TextureProgressBar = $V/WaterProgressBar

func _ready():
	update_display()
	update_zoom_state()

func _process(_delta):
	update_display()
	update_zoom_state()

func set_plot_coord(_plot_coord : Vector2) -> void:
	plot_coord = _plot_coord

func update_display() -> void:
	coord_label.text = str(plot_coord)
	var garden_plot : GardenPlot = PlantManager.get_garden_plot(plot_coord)
	if(!garden_plot):
		return
	
	if(garden_plot.is_planted()):
		planted_label.text = str(garden_plot.get_plant_display_name())
	else:
		planted_label.text = "Empty"

	grow_progress_bar.max_value = garden_plot.get_grow_capacity()
	grow_progress_bar.value = garden_plot.get_grow_progress()
	
	water_progress_bar.max_value = garden_plot.get_water_capacity()
	water_progress_bar.value = garden_plot.get_water_level()

func update_zoom_state() -> void:
	var zoom_level = CameraManager.get_camera_zoom_level()
	
	if(zoom_level <= zoom_threshold):
		set_zoom_state(ZOOM_STATES.ZOOMED_OUT)
	else:
		set_zoom_state(ZOOM_STATES.ZOOMED_IN)
		
func set_zoom_state(_zoom_state):
	if(zoom_state == _zoom_state):
		return
	
	zoom_state = _zoom_state
	if(zoom_state == ZOOM_STATES.ZOOMED_OUT):
		coord_label.visible = false
		grow_progress_bar.size.y = 30
		grow_progress_bar.minimum_size.y = 30
		water_progress_bar.size.y = 30
		water_progress_bar.minimum_size.y = 30
		return
	if(zoom_state == ZOOM_STATES.ZOOMED_IN):
		coord_label.visible = true
		grow_progress_bar.size.y = 20
		grow_progress_bar.minimum_size.y = 20
		water_progress_bar.size.y = 20
		water_progress_bar.minimum_size.y = 20
		return

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

func _on_plot_button_pressed():
	var garden_plot : GardenPlot = PlantManager.get_garden_plot(plot_coord)
	ActionManager.apply_current_action_to_garden_plot(garden_plot)
