extends PlotContent
class_name PassivePlotContent

@export var resource_keys : Array = ["AIR_ESS", "EARTH_ESS", "FIRE_ESS", "WATER_ESS"]

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
	
	var passive_resource_gains = passive_component.get_passive_resource_gains()
	
	for i in range(labels.size()):
		var resource_key = resource_keys[i]
		
		var gains_amount = passive_component.get_passive_resource_gains().get(resource_key, null)
		
		if(gains_amount == null):
			(labels[i] as Label).text = ""
		else:
			var display_colors = ResourceManager.get_resource_attribute(resource_key, ResourceManager.DISPLAY_COLORS, [])
			if(display_colors.size() > 0):
				(labels[i] as Label).modulate = display_colors[0] as Color
			if(display_colors.size() > 1):
				(backgrounds[i] as ColorRect).color = display_colors[1] as Color
			if(gains_amount > 0):
				(labels[i] as Label).text = "+ "
			elif(gains_amount > 0):
				(labels[i] as Label).text = "- "
			else:
				(labels[i] as Label).text = ""
			
			(labels[i] as Label).text += str(gains_amount)
