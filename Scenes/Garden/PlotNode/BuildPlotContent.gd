extends PlotContent
class_name BuildPlotContent

@onready var build_progress_bar : TextureProgressBar = $ProgressBar
@onready var build_progress_label : Label = $ProgressBar/Label

func _ready():
	build_progress_bar.max_value = 100.00
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var component : BuildPlotComponent = plot.get_component("BUILD")
	if(!component):
		return
	
	build_progress_bar.value = component.get_build_progress_percent()
	build_progress_label.text = "%.1f%%" % component.get_build_progress_percent()
