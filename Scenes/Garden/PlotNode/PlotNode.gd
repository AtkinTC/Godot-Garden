extends Control
class_name PlotNode

@onready var build_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/BuildPlotContent.tscn")
@onready var upgrade_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/UpgradePlotContent.tscn")
@onready var job_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/JobPlotContent.tscn")
@onready var passive_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/PassivePlotContent.tscn")

var plot_coord : Vector2

@onready var body : Control = $V

@onready var coord_label : Label = $V/CoordLabel
@onready var display_label : Label = $V/DisplayLabel
@onready var plot_button : Button = $PlotButton

var plot_content : PlotContent

func _ready():
	plot_button.pressed.connect(_on_plot_button_pressed)
	if(plot_coord != null):
		GardenManager.get_plot(plot_coord).plot_object_changed.connect(_on_plot_object_changed)
	update_display()

#func _process(_delta):
#	update_display()

func set_plot_coord(_plot_coord : Vector2) -> void:
	plot_coord = _plot_coord

func update_display() -> void:
	coord_label.text = str(plot_coord)
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	if(plot.get_object_key()):
		var display_name := str(plot.get_object_type()[Const.DISPLAY_NAME])
		if(plot.level > 1):
			display_name += " " + str(plot.level)
		display_label.text = display_name
	else:
		display_label.text = "Empty"
	
	if(plot_content):
		plot_content.queue_free()
	plot_content = null
	if(plot.get_component(Const.BUILD)):
		plot_content = build_plot_content_scene.instantiate() as PlotContent
	elif(plot.get_component(Const.UPGRADE)):
		plot_content = upgrade_plot_content_scene.instantiate() as PlotContent
	elif(plot.get_component(Const.PASSIVE)):
		plot_content = passive_plot_content_scene.instantiate() as PlotContent
	elif(plot.get_component(Const.JOB)):
		plot_content = job_plot_content_scene.instantiate() as PlotContent
	
	if(plot_content):
		plot_content.set_plot_coord(plot_coord)
		body.add_child(plot_content)

func _on_plot_button_pressed():
	var plot : Plot = GardenManager.get_plot(plot_coord)
	ActionManager.apply_current_action_to_plot(plot)

func _on_plot_object_changed():
	update_display()
