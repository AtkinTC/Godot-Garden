extends StructureDisplayContent
class_name StructureDisplaySupplyChangeContent

@export var gain_display_scene : PackedScene

@export_node_path(Container) var display_container_path : NodePath
@onready var display_container : Container = get_node(display_container_path)

var displays : Dictionary

func _ready():	
	reset_display() 

func _process(_delta):
	update_display()

func reset_display() -> void:
	for child in display_container.get_children():
		child.queue_free()
	
	displays = {}
	
	if(structure == null || !structure.is_active()):
		return
	var gain_component : StructureSupplySourceComponent = structure.get_component(Const.GAIN)
	if(!gain_component):
		return
	
	if(display_container is GridContainer):
		if(gain_component.get_values().size() > 1):
			display_container.set_columns(2)
		else:
			display_container.set_columns(1)
	
	for key in gain_component.get_values().keys():
		add_display(key)
	
	update_display()

func add_display(key):
	var display = gain_display_scene.instantiate() as SmallSupplyDisplay
	display.set_show_sign(true)
	var supply : SupplyVO = SupplyManager.get_supply(key)
	if(supply == null):
		return
	display.set_display_name(supply.get_display_name())
	display.set_display_colors(supply.get_display_colors())
	display_container.add_child(display)
	displays[key] = display
		
func update_display() -> void:
	if(structure == null || !structure.is_active()):
		return
	var gain_component : StructureSupplySourceComponent = structure.get_component(Const.GAIN)
	if(!gain_component):
		return
	
	for key in displays.keys():
		var gain_quantity = gain_component.get_values().get(key, null)
		displays[key].set_quantity(0 if gain_quantity == null else gain_quantity)
