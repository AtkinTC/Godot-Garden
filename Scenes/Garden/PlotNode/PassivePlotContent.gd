extends PlotContent
class_name PassivePlotContent

@export var gain_display_scene : PackedScene

@onready var display_container : Container = $DisplayContainer
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
	var passive_component : PassivePlotComponent = plot.get_component("PASSIVE")
	if(!passive_component):
		return
	
	if(display_container is GridContainer):
		if(passive_component.get_gains().size() > 1):
			display_container.set_columns(2)
		else:
			display_container.set_columns(1)
	
	for key in passive_component.get_gains().keys():
		add_display(key)
	
	update_display()

func add_display(key):
	var display = gain_display_scene.instantiate() as SimpleSupplyDisplay
	display.set_is_change_value(true)
	var fore_color = SupplyManager.get_supply(key).get_display_color(0)
	if(fore_color != null):
		display.set_fore_color(fore_color)
	var back_color = SupplyManager.get_supply(key).get_display_color(1)
	if(back_color != null):
		display.set_back_color(back_color)
	display_container.add_child(display)
	displays[key] = display
		
func update_display() -> void:
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var passive_component : PassivePlotComponent = plot.get_component("PASSIVE")
	if(!passive_component):
		return
	
	for key in displays.keys():
		var gain_quantity = passive_component.get_gains().get(key, null)
		displays[key].set_gain_quantity(0 if gain_quantity == null else gain_quantity)
