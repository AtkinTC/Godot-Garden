extends Control
class_name LargeSupplyDisplay

@export_node_path(TextureProgressBar) var progress_bar_path
@onready var progress_bar : TextureProgressBar = get_node(progress_bar_path) if progress_bar_path else null

@export_node_path(Label) var name_label_path
@onready var name_label : Label = get_node(name_label_path) if name_label_path else null

@export_node_path(Label) var quantity_label_path
@onready var quantity_label : Label = get_node(quantity_label_path) if quantity_label_path else null

@export_node_path(Label) var capacity_label_path
@onready var capacity_label : Label = get_node(capacity_label_path) if capacity_label_path else null

@export_node_path(Label) var change_label_path
@onready var change_label : Label = get_node(change_label_path) if change_label_path else null

var key : String

var quantity : float = 0.00
var capacity : float = -1.0
var change : float = 0.00

var display_name : String = ""
var display_quantity : String = ""
var display_capacity : String = ""
var display_change : String = ""

var need_update : bool = true

func _ready():
	setup()
	update_display()

# setup initial display settings
func setup():
	
	SupplyManager.supply_capacity_updated.connect(_on_supply_capacity_updated)
	SupplyManager.supply_change_updated.connect(_on_supply_change_updated)
	SupplyManager.supply_quantity_updated.connect(_on_supply_quantity_updated)
	
	need_update = true

func _process(_delta):
	if(need_update):
		update_display()

# update the display based on current values
func update_display():
	need_update = false
	var supply : SupplyVO
	if(key == null || key == ""):
		supply = SupplyVO.new()
	else:
		supply = SupplyManager.get_supply(key)
	
	set_display_name(supply.get_display_name())
	set_quantity(supply.get_quantity())
	set_capacity(supply.get_capacity())
	set_change(supply.get_change())
	
	if(progress_bar):
		progress_bar.tint_progress = supply.get_display_color(0, progress_bar.tint_progress)
		progress_bar.tint_under = supply.get_display_color(1, progress_bar.tint_under)
	
	name_label.text = display_name
	
	if(quantity_label):
		set_display_quantity(Utils.format_comma_seperated("%.1f" % quantity))
		quantity_label.text = display_quantity
	
	if(capacity_label):
		if(capacity > 0):
			set_display_capacity("/ " + Utils.format_comma_seperated("%.0f" % capacity))
		else:
			set_display_capacity("")
		capacity_label.text = display_capacity
	
	if(change_label):
		if(change == 0):
			set_display_change("")
		else:
			set_display_change("(" + ("+" if change > 0 else "-") + Utils.format_comma_seperated("%.1f" % change) + ")")
		change_label.text = display_change
	
	if(progress_bar):
		progress_bar.max_value = 100.00
		if(capacity > 0):
			progress_bar.value = quantity * 100.0 / capacity
		else:
			progress_bar.value = 0

func set_key(_key):
	key = _key
	need_update = true

func set_display_name(_display_name : String):
	display_name = _display_name

func set_quantity(_quantity : float):
	quantity = _quantity
	
func set_display_quantity(_display_quantity : String):
	display_quantity = _display_quantity

func set_capacity(_capacity : float):
	capacity = _capacity
	
func set_display_capacity(_display_capacity : String):
	display_capacity = _display_capacity

func set_change(_change : float):
	change = _change

func set_display_change(_display_change : String):
	display_change = _display_change

# trigger quantity update and recalculate display when supply updates
func _on_supply_quantity_updated(_key : String):
	if(key == _key):
		need_update = true

# trigger capacity update and recalculate display when supply updates
func _on_supply_capacity_updated(_key : String):
	if(key == _key):
		need_update = true

func _on_supply_change_updated(_key : String):
	if(key == _key):
		need_update = true
