extends Control
class_name GardenExpandPanel

signal expand_panel_pressed(exp_v : Vector2)

@onready var button : Button = $Margin/ExpandButton
@onready var labels_container : Control = $Margin/V/H
@onready var price_labels : Array = [$Margin/V/H/Control]

@export var expand_v : Vector2 = Vector2.ZERO
@export_node_path var garden_path : NodePath
var parent_garden : GardenGrid

func _ready():
	var node = get_node_or_null(garden_path)
	if(node != null && node is GardenGrid):
		parent_garden = node
		expand_panel_pressed.connect(parent_garden._on_expand_panel_pressed)
	
	update_display_price()
	
func _process(_delta):
	update_display_price()

func update_display_price():
	if(parent_garden == null):
		return
	
	var price := GardenManager.get_garden_expansion_price(expand_v)
	
	for i in price.size():
		var key = price.keys()[i]
		if(i >= price_labels.size()):
			price_labels.append((price_labels[0] as Control).duplicate())
			labels_container.add_child(price_labels[i])
			
		var price_label : Label = price_labels[i].get_node("Label")
		var background : ColorRect = price_labels[i].get_node("ColorRect")
		price_label.text = "%.2f" % price[key]
		price_label.modulate = SupplyManager.get_supply(key).get_display_color(0, price_label.modulate)
		background.color = SupplyManager.get_supply(key).get_display_color(1, background.color)

func _on_expand_button_pressed():
	expand_panel_pressed.emit(expand_v)
