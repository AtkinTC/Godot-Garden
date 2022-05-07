extends Control
class_name SupplyDisplay

@onready var progress_bar : TextureProgressBar = $ProgressBar
@onready var name_label : Label = $H/NameLabel
@onready var quantity_label : Label = $H/AmountLabel

var key : String

@onready var progress_bar_tint := progress_bar.tint_progress
@onready var progress_bar_tint_back := progress_bar.tint_under

var display_name : String = ""
var display_quantity : String = ""
var quantity : float = 0.00
var capacity : float = -1.0

func _ready():
	setup()
	update_display()

# setup initial display settings
# settings which are not expected to change often
func setup():
	if(key == null || key == ""):
		return
	
	SupplyManager.connect_to_supply_quantity_changed(key, _on_supply_quantity_changed)
	SupplyManager.connect_to_supply_capacity_changed(key, _on_supply_capacity_changed)
	
	var supply : Supply = SupplyManager.get_supply(key)
	
	set_display_name(supply.get_display_name())
	set_quantity(supply.get_quantity())
	set_capacity(supply.get_capacity())
	
	progress_bar.tint_progress = supply.get_display_color(0, progress_bar.tint_progress)
	progress_bar.tint_under = supply.get_display_color(1, progress_bar.tint_under)

# update the display based on current values
func update_display():
	name_label.text = display_name
	
	set_display_quantity(Utils.format_comma_seperated("%.2f" % quantity))
	quantity_label.text = display_quantity
	
	if(key):
		progress_bar.max_value = 100.00
		if(capacity > 0):
			progress_bar.value = quantity * 100.0 / capacity
		else:
			progress_bar.value = 0

func set_key(_key):
	key = _key

func set_display_name(_display_name : String):
	display_name = _display_name

func set_display_quantity(_display_quantity : String):
	display_quantity = _display_quantity

func set_quantity(_quantity : float):
	quantity = _quantity

func set_capacity(_capacity : float):
	capacity = _capacity

# trigger quantity update and recalculate display when supply updates
func _on_supply_quantity_changed(_key : String, _old_quantity : float, _new_quantity : float):
	if(key == _key):
		set_quantity(_new_quantity)
		update_display()

# trigger capacity update and recalculate display when supply updates
func _on_supply_capacity_changed(_key : String, _old_capacity : float, _new_capacity : float):
	if(key == _key):
		set_capacity(_new_capacity)
		update_display()
