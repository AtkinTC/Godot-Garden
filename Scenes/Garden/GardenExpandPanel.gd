extends Control
class_name GardenExpandPanel

signal expand_panel_pressed(exp_v : Vector2)

@onready var button : Button = $ExpandButton

@export var expand_v : Vector2 = Vector2.ZERO
@export_node_path var garden_path : NodePath
var parent_garden : GardenGrid

func _ready():
	var node = get_node_or_null(garden_path)
	if(node != null && node is GardenGrid):
		parent_garden = node
		expand_panel_pressed.connect(parent_garden._on_expand_panel_pressed)
	
	update_display_price()
	
func _process(delta):
	update_display_price()

func update_display_price():
	if(parent_garden == null):
		return
	
	var price := parent_garden.get_expansion_price(expand_v)
	button.text = "Expand\n($%.2f)" % price

func _on_expand_button_pressed():
	expand_panel_pressed.emit(expand_v)
