extends Control
class_name SimpleSupplyDisplay

@onready var background : ColorRect = $ColorRect
@onready var label : Label = $Label

var change_value : bool = false
var quantity : float
var fore_color : Color
var back_color : Color

var needs_update : bool = true

func _ready():
	update_display()

func _process(_delta):
	update_display()

func update_display():
	if(!needs_update):
		return
	
	label.modulate = fore_color
	background.color = back_color
	
	if(quantity == null || is_equal_approx(quantity, 0)):
		label.text = ""
	else:
		if(!change_value):
			label.text = "%.2f" % quantity
		else:
			if(quantity > 0):
				label.text = "+ "
			elif(quantity < 0):
				label.text = "- "
			label.text += "%.2f" % quantity
	
	needs_update = false

func set_fore_color(_fore_color : Color):
	fore_color = _fore_color
	needs_update = true

func set_back_color(_back_color : Color):
	back_color = _back_color
	needs_update = true

func set_gain_quantity(_quantity : float):
	if(quantity == _quantity):
		return
	quantity = _quantity
	needs_update = true

func set_is_change_value(_change_value : bool):
	change_value = _change_value
	needs_update = true
