extends InfoBox
class_name PlotUpgradesInfoBox

@export var supply_display_scene : PackedScene
@export_node_path(Control) var supply_container_path : NodePath
@export_node_path(Button) var upgrade_button_path : NodePath

@onready var supply_container : Control = get_node(supply_container_path)
@onready var upgrade_button : Button = get_node(upgrade_button_path)

var plot_coord : Vector2
var price_displays : Dictionary

func _ready():
	price_displays = {}
	for child in supply_container.get_children():
		child.queue_free()
	
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)

func update_display():
	if(plot_coord == null):
		visible = false
		return
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(plot == null || !plot.is_ready_for_upgrade()):
		visible = false
		return
	var purchase_properties := {Const.MOD_TYPE : Const.UPGRADE, Const.LEVEL : plot.level}
	if(!PurchaseUtil.is_purchasable(Const.OBJECT, plot.get_object_key(), purchase_properties)):
		visible = false
		return
	visible = true
	
	var price : Dictionary = PurchaseUtil.get_modified_purchase_price(Const.OBJECT, plot.get_object_key(), purchase_properties)
	
	for supply in price.keys():
		if(!price_displays.has(supply)):
			var new_display : Control = supply_display_scene.instantiate()
			new_display.set_supply_name(Database.get_entry_attr(Const.SUPPLY, supply, Const.DISPLAY_NAME))
			new_display.set_quantity(price[supply])
			price_displays[supply] = new_display
			supply_container.add_child(new_display)
		else:
			price_displays[supply].set_quantity(price[supply])
	
	for supply in price_displays.keys():
		if(!price.has(supply)):
			price_displays[supply].queue_free()
			price_displays.erase(supply)

func set_plot_coord(_plot_coord : Vector2):
	plot_coord = _plot_coord
	update_display()

func _on_upgrade_button_pressed():
	if(plot_coord != null):
		ActionManager.apply_action_to_plot("UPGRADE_PLOT_OBJECT", plot_coord)
