extends PlotContent
class_name PassivePlotContent

@export var supply_keys : Array = ["EARTH_ESS", "AIR_ESS", "WATER_ESS", "FIRE_ESS"]

var labels : Array = []
var backgrounds : Array = []

func _ready():
	labels.append($Grid/Control1/Label)
	labels.append($Grid/Control2/Label)
	labels.append($Grid/Control3/Label)
	labels.append($Grid/Control4/Label)
	
	backgrounds.append($Grid/Control1/ColorRect)
	backgrounds.append($Grid/Control2/ColorRect)
	backgrounds.append($Grid/Control3/ColorRect)
	backgrounds.append($Grid/Control4/ColorRect)
	
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	var plot : Plot = GardenManager.get_plot(plot_coord)
	if(!plot):
		return
	
	var passive_component : PassivePlotComponent = plot.get_component("PASSIVE")
	if(!passive_component):
		return
	
	for i in range(labels.size()):
		var key = supply_keys[i]
		
		var gains_quantity = passive_component.get_gains().get(key, null)
		
		if(gains_quantity == null):
			(labels[i] as Label).text = ""
		else:
			(labels[i] as Label).modulate = SupplyManager.get_supply(key).get_display_color(0, (labels[i] as Label).modulate)
			(backgrounds[i] as ColorRect).color = SupplyManager.get_supply(key).get_display_color(1, (backgrounds[i] as ColorRect).color)
			
			if(gains_quantity > 0):
				(labels[i] as Label).text = "+ "
			elif(gains_quantity > 0):
				(labels[i] as Label).text = "- "
			else:
				(labels[i] as Label).text = ""
			
			(labels[i] as Label).text += str(gains_quantity)
