extends PanelContainer
class_name PlotPassivesInfoBox

@export var supply_display_scene : PackedScene
@export_node_path(Control) var supply_container_path : NodePath

@onready var supply_container : Control = get_node(supply_container_path)

var plot_coord : Vector2
var supply_displays : Dictionary

func _ready():
	supply_displays = {}
	for child in supply_container.get_children():
		child.queue_free()

func update_display():
	if(plot_coord == null):
		visible = false
		return
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(plot == null || !plot.components.has(Const.PASSIVE)):
		visible = false
		return
	visible = true
	
	var passive : PassivePlotComponent = plot.components[Const.PASSIVE]
	var gains := passive.get_gains()
	
	for supply in gains.keys():
		if(!supply_displays.has(supply)):
			var new_display : Control = supply_display_scene.instantiate()
			new_display.set_supply_name(Database.get_entry_attr(Const.SUPPLY, supply, Const.DISPLAY_NAME, ""))
			new_display.set_quantity(gains[supply])
			supply_displays[supply] = new_display
			supply_container.add_child(new_display)
		else:
			supply_displays[supply].set_quantity(gains[supply])
	
	for supply in supply_displays.keys():
		if(!gains.has(supply)):
			supply_displays[supply].queue_free()
			supply_displays.erase(supply)

func set_plot_coord(_plot_coord : Vector2):
	plot_coord = _plot_coord
	update_display()
