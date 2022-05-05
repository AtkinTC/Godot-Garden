extends PlotContent
class_name JobPlotContent

@onready var job_progress_bar : TextureProgressBar = $JobProgressBar
@onready var job_progress_label : Label = $JobProgressBar/Label

func _ready():
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var job_component : JobPlotComponent = plot.get_component("JOB")
	if(!job_component):
		return
	
	job_progress_bar.max_value = 100.00
	job_progress_bar.value = job_component.get_job_progress_percent()
	job_progress_label.text = "%.1f%%" % job_component.get_job_progress_percent()
