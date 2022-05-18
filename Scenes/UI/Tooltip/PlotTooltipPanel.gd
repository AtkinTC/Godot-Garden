extends TooltipPanel
class_name PlotTooltipPanel

@export_node_path(Label) var title_label_path : NodePath
@export_node_path(Label) var type_label_path : NodePath
@export_node_path(Label) var coord_label_path : NodePath
@export_node_path(Control) var content_container_path : NodePath

@onready var title_label : Label = get_node_or_null(title_label_path)
@onready var type_label : Label = get_node_or_null(type_label_path)
@onready var coord_label : Label = get_node_or_null(coord_label_path)
@onready var content_container : Control = get_node(content_container_path)

var display_name : String
var plot_type : String
var plot_coord : Vector2

@onready var components : Array = []

func _ready():
	super._ready()
	assert(owner_node != null)
	assert(owner_node is PlotNode)
	
	set_plot_coord((owner_node as PlotNode).get_plot_coord())
		
	for child in content_container.get_children():
		if(child is InfoBox):
			components.append(child)
		if(child.has_method("set_plot_coord")):
			child.set_plot_coord(plot_coord)
	
	update_display()

func update_display():
	if(plot_coord == null):
		return
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	if(!plot.is_owned() && !plot.is_available()):
		display_name = "Uknown"
		plot_type = "Uknown"
	elif(!plot.is_owned() && plot.is_available()):
		display_name = "Border Plot"
		plot_type = "Purchasable"
	elif(plot.get_object_key()):
		display_name = str(plot.get_object_type()[Const.DISPLAY_NAME])
		plot_type = str(plot.get_object_key())
		if(plot.level > 1):
			display_name += " " + str(plot.level)
	else:
		display_name = "Empty"
		plot_type = "Empty Plot"
		
	if(title_label != null):
		title_label.text = display_name
	
	if(type_label != null):
		type_label.text = plot_type
	
	if(coord_label != null):
		coord_label.text = str(plot_coord)
	
	for child in content_container.get_children():
		if(child.has_method("update_display")):
			child.update_display()

func set_plot_coord(_plot_coord : Vector2):
	if(_plot_coord != null):
		if(GardenManager.get_plot(plot_coord).plot_object_changed.is_connected(_on_plot_object_changed)):
			GardenManager.get_plot(plot_coord).plot_object_changed.disconnect(_on_plot_object_changed)
		plot_coord = _plot_coord
		GardenManager.get_plot(plot_coord).plot_object_changed.connect(_on_plot_object_changed)

func _on_tooltip_open():
	update_display()

func _on_tooltip_close():
	pass

func _on_plot_object_changed():
	update_display()

