class_name PlotDisplay
extends Control

@export var structure_display_scene : PackedScene

@export_node_path(Control) var content_container_path : NodePath
@export_node_path(Label) var name_label_path : NodePath
@export_node_path(Label) var coord_label_path : NodePath
@export_node_path(Button) var plot_button_path : NodePath

@onready var content_container : Control = get_node(content_container_path)
@onready var name_label : Label = get_node(name_label_path)
@onready var coord_label : Label = get_node(coord_label_path)
@onready var plot_button : Button = get_node(plot_button_path)

var plot_coord : Vector2
var plot_display_content : PlotDisplayContent
var structure_display : StructureDisplay

func _ready():
	if(GardenManager.get_plot(plot_coord) == null):
		queue_free()
		return
	plot_button.pressed.connect(_on_plot_button_pressed)
	if(plot_coord != null):
		GardenManager.get_plot(plot_coord).plot_updated.connect(_on_plot_updated)
	for child in content_container.get_children():
		child.queue_free()
	update_display()

func set_plot_coord(_plot_coord : Vector2) -> void:
	plot_coord = _plot_coord

func get_plot_coord() -> Vector2:
	return plot_coord

func update_display() -> void:
	coord_label.text = str(plot_coord)
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	for child in get_children():
		if(child.has_method("set_visible")):
			child.set_visible(true)
	
	# set plot display label
	name_label.visible = true
	name_label.text = plot.get_display_name()
	
	if(plot.has_structure()):
		if(structure_display == null || !is_instance_valid(structure_display)):
			structure_display = structure_display_scene.instantiate()
			structure_display.set_world_coord(plot_coord)
			content_container.add_child(structure_display)
	else:
		if(structure_display != null && is_instance_valid(structure_display)):
			structure_display.queue_free()
		structure_display = null
	
	if(plot_display_content != null && is_instance_valid(plot_display_content)):
		plot_display_content.queue_free()
		plot_display_content = null
	if(plot_display_content != null && is_instance_valid(plot_display_content)):
		content_container.add_child(plot_display_content)

func _on_plot_button_pressed():
	var plot : Plot = GardenManager.get_plot(plot_coord)
	ActionManager.apply_current_action_to_plot(plot_coord)

func _on_plot_updated(coord : Vector2):
	if(plot_coord == coord):
		update_display()
