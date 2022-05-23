class_name SmallSupplyDisplay
extends SupplyDisplay

@onready var background : ColorRect = $ColorRect
@onready var label : Label = $Label

var needs_update : bool = true

func _ready():
	needs_update = true
	update_display()

func _process(_delta):
	update_display()

func update_display():
	if(!needs_update):
		return
	
	if(display_colors != null && display_colors.size() >= 1):
		label.modulate = display_colors[0]
	if(display_colors != null && display_colors.size() >= 2):
		background.color = display_colors[1]
	
	display_quantity = ""
	if(quantity != null):
		if(show_sign):
			if(quantity > 0):
				display_quantity = "+ "
			elif(quantity < 0):
				display_quantity = "- "
		display_quantity += "%.2f" % quantity
	label.text = display_quantity
	
	needs_update = false

func set_display_colors(_display_colors : Array) -> void:
	super.set_display_colors(_display_colors)
	needs_update = true

func set_quantity(_quantity : float) -> void:
	super.set_quantity(_quantity)
	needs_update = true

func set_show_sign(_show_sign : bool) -> void:
	super.set_show_sign(_show_sign)
	needs_update = true
