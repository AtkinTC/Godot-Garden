extends PlotContent
class_name AvailablePlotContent

@export var price_display_scene : PackedScene

@export_node_path(Control) var display_container_path : NodePath
@onready var display_container : Control = get_node(display_container_path)
var displays : Dictionary

func _ready():
	reset_display()

func _process(_delta):
	update_display()

func reset_display() -> void:
	for child in display_container.get_children():
		child.queue_free()
	
	displays = {}
	
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var price_dict : Dictionary = GardenManager.get_plot_purchase_price(plot_coord)
	if(display_container is GridContainer):
		if(price_dict.size() > 1):
			display_container.set_columns(2)
		else:
			display_container.set_columns(1)
	
	for key in price_dict.keys():
		add_display(key)
	
	update_display()

func add_display(key):
	var display = price_display_scene.instantiate() as SimpleSupplyDisplay
	var fore_color = SupplyManager.get_supply(key).get_display_color(0)
	if(fore_color != null):
		display.set_fore_color(fore_color)
	var back_color = SupplyManager.get_supply(key).get_display_color(1)
	if(back_color != null):
		display.set_back_color(back_color)
	display_container.add_child(display)
	displays[key] = display

func update_display() -> void:
	var price := GardenManager.get_plot_purchase_price(plot_coord)
	for key in displays.keys():
		var price_quantity = price.get(key, 0)
		displays[key].set_gain_quantity(0 if price_quantity == null else price_quantity)
