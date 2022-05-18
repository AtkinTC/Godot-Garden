extends Control
class_name SupplyLineDisplay

@export_node_path(Label) var supply_name_label_path : NodePath
@export_node_path(Label) var quantity_label_path : NodePath

@onready var supply_name_label : Label = get_node_or_null(supply_name_label_path)
@onready var quantity_label : Label = get_node_or_null(quantity_label_path)

var supply_name : String
var quantity : float

var needs_update : bool = true

func _ready():
	update_display()

func _process(_delta):
	update_display()

func update_display():
	if(!needs_update):
		return
	
	if(supply_name == null):
		supply_name_label.text = ""
	else:
		supply_name_label.text = supply_name
	
	if(quantity == null || is_equal_approx(quantity, 0)):
		quantity_label.text = ""
	else:
		quantity_label.text = "%.2f" % quantity
	
	needs_update = false

func set_supply_name(_supply_name : String):
	if(supply_name == _supply_name):
		return
	supply_name = _supply_name
	needs_update = true

func set_quantity(_quantity : float):
	if(quantity == _quantity):
		return
	quantity = _quantity
	needs_update = true
