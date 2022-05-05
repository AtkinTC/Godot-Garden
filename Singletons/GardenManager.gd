extends Node

signal garden_resized()

var garden_plots : Array2D
var garden_rect := Rect2(-1, -1, 3, 3)

var plot_base_price : float = (100.0/3)
var min_garden_size : int = 9

func _ready():
	setup_garden_plots()

# rebuild garden plots array based on current sizing
func setup_garden_plots():
	var old := garden_plots
	garden_plots = Array2D.new(garden_rect.size, garden_rect.position)
	
	if(old != null):
		garden_plots.insert(old)
	
	for x in garden_plots.range_x():
		for y in garden_plots.range_y():
			var coord := Vector2(x,y)
			if(old == null || !(x in old.range_x()) || !(y in old.range_y())):
				var garden_plot : GardenPlot = GardenPlot.new()
				garden_plot.set_coord(coord)
				set_garden_plot(coord, garden_plot)

# process step time for all garden plots
func step_garden_plots(step_time : float):
	for x in garden_plots.range_x():
		for y in garden_plots.range_y():
			(garden_plots.get_at(Vector2(x,y)) as GardenPlot).step(step_time)

# calculate price for an expansion based on current garden size
func get_garden_expansion_price(exp_v : Vector2) -> float:
	var new_width : int = garden_plots.get_size().x + abs(exp_v.x)
	var new_height : int = garden_plots.get_size().y + abs(exp_v.y)
	
	var current_plots := garden_plots.get_size().x * garden_plots.get_size().y
	var new_plots := (new_width * new_height) - current_plots
	
	return plot_base_price * new_plots * (current_plots * 1.0 / min_garden_size)

# expend resources to purchase expansion and apply resize to garden
func purchase_expansion(exp_v : Vector2):
	var total_cost := {"MONEY": get_garden_expansion_price(exp_v)}
	if(!PurchaseManager.can_afford(total_cost)):
		return
		
	PurchaseManager.spend(total_cost)
	expand_garden(exp_v)

# expand the size of the garden based on a provided expansion vector
# only expands, negative value will expand in the negative direction
func expand_garden(exp_v : Vector2):
	var _offset : Vector2 = garden_rect.position + Vector2(min(exp_v.x, 0), min(exp_v.y, 0))
	var _size : Vector2 = garden_rect.size + abs(exp_v)
	
	set_garden_rect(Rect2(_offset, _size))

func set_garden_rect(_garden_rect : Rect2):
	garden_rect = _garden_rect
	setup_garden_plots()
	garden_resized.emit()

func get_garden_rect() -> Rect2:
	return garden_rect

func set_garden_plot(coord : Vector2, garden_plot : GardenPlot):
	garden_plots.set_at(coord, garden_plot)

func get_garden_plot(coord : Vector2):
	if(garden_plots == null):
		return null
	return garden_plots.get_at(coord)

func connect_garden_resized(reciever_method : Callable):
	garden_resized.connect(reciever_method)
