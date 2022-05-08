extends PlotContent
class_name UpgradePlotContent

@onready var progress_bar : TextureProgressBar = $ProgressBar
@onready var progress_label : Label = $ProgressBar/Label

func _ready():
	progress_bar.max_value = 100.00
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var component : UpgradePlotComponent = plot.get_component("UPGRADE")
	if(!component):
		return
	
	progress_bar.value = component.get_progress_percent()
	progress_label.text = "%.1f%%" % component.get_progress_percent()
