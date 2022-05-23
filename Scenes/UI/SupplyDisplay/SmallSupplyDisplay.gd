class_name SmallSupplyDisplay
extends SupplyDisplay

@export_node_path(ColorRect) var background_path : NodePath
@export_node_path(Label) var quantity_label_path : NodePath

@onready var background : ColorRect = get_node(background_path)
@onready var quantity_label : Label = get_node(quantity_label_path)

func _ready() -> void:
	ready()

func update_display():
	if(!needs_update):
		return
	needs_update = false
	
	# display colors
	if(display_colors != null && display_colors.size() >= 1):
		quantity_label.modulate = display_colors[0]
	if(display_colors != null && display_colors.size() >= 2):
		background.color = display_colors[1]
	
	# display quantity
	display_quantity = ""
	if(quantity != null):
		if(show_sign):
			if(quantity > 0):
				display_quantity = "+ "
			elif(quantity < 0):
				display_quantity = "- "
		display_quantity += "%.2f" % quantity
	quantity_label.text = display_quantity
