class_name SmallTextSupplyDisplay
extends SupplyDisplay

@export_node_path(Label) var name_label_path : NodePath
@export_node_path(Label) var quantity_label_path : NodePath

@onready var name_label : Label = get_node(name_label_path)
@onready var quantity_label : Label = get_node(quantity_label_path)

func _ready() -> void:
	ready()

func update_display():
	if(!needs_update):
		return
	
	# display name
	if(name_label):
		name_label.text = display_name
		if(display_colors != null && display_colors.size() >= 1):
			name_label.modulate = display_colors[0]
		else:
			name_label.modulate = Color.WHITE
	
	if(quantity_label):
		if(quantity < 0 && !allow_negative_quantity):
			set_display_quantity("--")
		else:
			set_display_quantity(format_value(quantity))
		quantity_label.text = display_quantity
	
	needs_update = false
