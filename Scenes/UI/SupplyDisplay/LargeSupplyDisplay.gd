class_name LargeSupplyDisplay
extends SmartSupplyDisplay

@export_node_path(TextureProgressBar) var progress_bar_path
@export_node_path(Label) var name_label_path
@export_node_path(Label) var quantity_label_path
@export_node_path(Label) var capacity_label_path
@export_node_path(Label) var change_label_path

@onready var progress_bar : TextureProgressBar = get_node(progress_bar_path) if progress_bar_path else null
@onready var name_label : Label = get_node(name_label_path) if name_label_path else null
@onready var quantity_label : Label = get_node(quantity_label_path) if quantity_label_path else null
@onready var capacity_label : Label = get_node(capacity_label_path) if capacity_label_path else null
@onready var change_label : Label = get_node(change_label_path) if change_label_path else null

func _ready():
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
			progress_bar.tint_progress = Color.BLACK
	
	# display name
	if(name_label):
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
	
	needs_update = false
