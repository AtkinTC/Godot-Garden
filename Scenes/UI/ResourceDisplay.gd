extends Node
class_name ResourceDisplay

@onready var name_label : Label = $NameLabel
@onready var amount_label : Label = $AmountLabel

var resource_key : String
var passive : bool = false

var display_name : String = ""
var display_amount : String = ""
var amount : float = 0.00

func _ready():
	update_values()
	update_display()

func _process(_delta):
	if(!passive):
		update_values()
	update_display()

func update_values():
	if(resource_key):
		set_display_name(ResourceManager.get_resource_attribute(resource_key, ResourceManager.DISPLAY_NAME))
		set_amount(ResourceManager.get_resource_attribute(resource_key, ResourceManager.AMOUNT))

func update_display():
	name_label.text = display_name
	amount_label.text = display_amount

func set_resource_key(_resource_key):
	resource_key = _resource_key

func set_display_name(_display_name : String):
	display_name = _display_name

func set_display_amount(_display_amount : String):
	display_amount = _display_amount

func set_amount(_amount : float):
	amount = _amount
	set_display_amount(format_comma_seperated("%.2f" % amount))
	
func format_comma_seperated(number : String) -> String:
	var number_string = str(number)
	var parts := number_string.split(".")
	
	if(parts.size() == 0):
		return number_string
	
	var pre = parts[0]
	var pos = pre.length() - 3
	while(pos > 0):
		pre = pre.insert(pos, ",")
		pos -= 3
	
	if(parts.size() == 2):
		var post = parts[1]
		return pre + "." + post
		
	return pre
