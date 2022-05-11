extends Control
class_name PlotNode

@onready var available_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/AvailablePlotContent.tscn")
@onready var build_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/BuildPlotContent.tscn")
@onready var upgrade_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/UpgradePlotContent.tscn")
@onready var job_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/JobPlotContent.tscn")
@onready var passive_plot_content_scene : PackedScene = load("res://Scenes/Garden/PlotNode/PassivePlotContent.tscn")

var plot_coord : Vector2

@export_node_path(Control) var body_path : NodePath
@export_node_path(Label) var coord_label_path : NodePath
@export_node_path(Label) var display_label_path : NodePath
@export_node_path(Button) var plot_button_path : NodePath

@onready var body : Control = get_node(body_path)
@onready var coord_label : Label = get_node(coord_label_path)
@onready var display_label : Label = get_node(display_label_path)
@onready var plot_button : Button = get_node(plot_button_path)

var plot_content : PlotContent

func _ready():
	plot_button.pressed.connect(_on_plot_button_pressed)
	if(plot_coord != null):
		GardenManager.get_plot(plot_coord).plot_object_changed.connect(_on_plot_object_changed)
	update_display()

func set_plot_coord(_plot_coord : Vector2) -> void:
	plot_coord = _plot_coord

func update_display() -> void:
	coord_label.text = str(plot_coord)
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	# hide plot if not owned and not available
	if(!plot.is_owned() && !plot.is_available()):
		for child in get_children():
			child.visible = false
		return
	
	# set plot display label
	display_label.visible = true
	if(!plot.is_owned()):
		display_label.text = ""
		display_label.visible = false
	elif(plot.get_object_key()):
		var display_name := str(plot.get_object_type()[Const.DISPLAY_NAME])
		if(plot.level > 1):
			display_name += " " + str(plot.level)
		display_label.text = display_name
	else:
		display_label.text = "Empty"
	
	# setup plot display content
	if(plot_content):
		plot_content.queue_free()
	plot_content = null
	if(plot.is_available() && !plot.is_owned()):
		plot_content = available_plot_content_scene.instantiate() as PlotContent
	elif(plot.get_component(Const.BUILD)):
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
	if(plot.is_available() && !plot.is_owned()):
		ActionManager.apply_action_to_plot("PURCHASE_PLOT", plot_coord)
	else:
		ActionManager.apply_current_action_to_plot(plot_coord)

func _on_plot_object_changed():
	update_display()
