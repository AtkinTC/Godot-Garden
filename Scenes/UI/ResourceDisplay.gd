extends Control
class_name ResourceDisplay

@onready var progress_bar : TextureProgressBar = $ProgressBar
@onready var name_label : Label = $H/NameLabel
@onready var amount_label : Label = $H/AmountLabel

var resource_key : String

@onready var progress_bar_tint := progress_bar.tint_progress
@onready var progress_bar_tint_back := progress_bar.tint_under

var display_name : String = ""
var display_amount : String = ""
var amount : float = 0.00
var capacity : float = -1.0

func _ready():
	ResourceManager.resource_quantity_changed.connect(_on_resource_quantity_changed)
	setup()
	update_display()

# setup initial display settings
# settings which are not expected to change often
func setup():
	if(resource_key == null || resource_key == ""):
		return
		
	set_display_name(ResourceManager.get_resource_attribute(resource_key, ResourceManager.DISPLAY_NAME))
	set_amount(ResourceManager.get_resource_attribute(resource_key, ResourceManager.QUANTITY))
	set_capacity(ResourceManager.get_resource_attribute(resource_key, ResourceManager.CAPACITY))
	
	var display_colors = ResourceManager.get_resource_attribute(resource_key, ResourceManager.DISPLAY_COLORS, [])
	if(display_colors.size() > 0):
		progress_bar_tint = display_colors[0] as Color
	if(display_colors.size() > 1):
		progress_bar_tint_back = display_colors[1] as Color
	progress_bar.tint_progress = progress_bar_tint
	progress_bar.tint_under = progress_bar_tint_back

# update the display based on current values
func update_display():
	name_label.text = display_name
	
	set_display_amount(Utils.format_comma_seperated("%.2f" % amount))
	amount_label.text = display_amount
	
	if(resource_key):
		progress_bar.max_value = 100.00
		if(capacity > 0):
			progress_bar.value = amount * 100.0 / capacity
		else:
			progress_bar.value = 0

func set_resource_key(_resource_key):
	resource_key = _resource_key

func set_display_name(_display_name : String):
	display_name = _display_name

func set_display_amount(_display_amount : String):
	display_amount = _display_amount

func set_amount(_amount : float):
	amount = _amount

func set_capacity(_capacity : float):
	capacity = _capacity

# trigger amount update and recalculate display when resource updates
func _on_resource_quantity_changed(_resource_key : String, _old_quantity : float, _new_quantity : float):
	if(resource_key == _resource_key):
		set_amount(_new_quantity)
		update_display()
