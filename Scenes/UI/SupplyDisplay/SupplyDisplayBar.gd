class_name SupplyDisplayBar
extends SupplyDisplay

@export_node_path(TextureProgressBar) var progress_bar_path
@export_node_path(Label) var name_label_path
@export_node_path(Label) var quantity_label_path
@export_node_path(Label) var capacity_label_path

@onready var progress_bar : TextureProgressBar = get_node(progress_bar_path) if progress_bar_path else null
@onready var name_label : Label = get_node(name_label_path) if name_label_path else null
@onready var quantity_label : Label = get_node(quantity_label_path) if quantity_label_path else null
@onready var capacity_label : Label = get_node(capacity_label_path) if capacity_label_path else null

func _ready() -> void:
	ready()

func update_display():
	if(!needs_update):
		return
	
	# display colors
	if(progress_bar):
		if(display_colors != null && display_colors.size() >= 1):
			progress_bar.tint_progress = display_colors[0]
		else:
			progress_bar.tint_progress = Color.GRAY
		if(display_colors != null && display_colors.size() >= 2):
			progress_bar.tint_under  = display_colors[1]
		else:
			progress_bar.tint_under = Color.BLACK
	
	# display name
	if(name_label):
		name_label.text = display_name
	
	if(quantity_label):
		if(quantity < 0 && !allow_negative_quantity):
			set_display_quantity("--")
		else:
			set_display_quantity(format_value(quantity))
		quantity_label.text = display_quantity
	
	if(capacity_label):
		if(capacity > 0):
			set_display_capacity(format_value(capacity))
		else:
			set_display_capacity("")
		capacity_label.text = display_capacity
	
	if(progress_bar):
		progress_bar.max_value = 100.00
		if(capacity > 0):
			progress_bar.value = max(quantity, 0) * 100.0 / capacity
		else:
			progress_bar.value = 100.00
	
	needs_update = false
