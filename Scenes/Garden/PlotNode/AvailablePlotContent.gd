extends PlotContent
class_name AvailablePlotContent

@export_node_path(Control) var labels_container_path : NodePath
@export_node_path(Control) var price_label_path : NodePath
@onready var labels_container : Control = get_node(labels_container_path)
@onready var price_labels : Array = [get_node(price_label_path)]

func _ready():
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	var price := GardenManager.get_plot_purchase_price(plot_coord)
	
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
