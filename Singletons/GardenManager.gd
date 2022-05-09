extends Node

signal garden_resized()

var plots : Array2D
var garden_rect := Rect2(-1, -1, 3, 3)

var plot_base_price : float = (40.0/3)
var min_garden_size : int = 9

# setup initial state of the garden
func initialize():
	setup_plots()

# rebuild garden plots array based on current sizing
func setup_plots():
	var old := plots
	plots = Array2D.new(garden_rect.size, garden_rect.position)
	
	if(old != null):
		plots.insert(old)
	
	for x in plots.range_x():
		for y in plots.range_y():
			var coord := Vector2(x,y)
			if(old == null || !(x in old.range_x()) || !(y in old.range_y())):
				var plot : Plot = Plot.new()
				plot.set_coord(coord)
				set_plot(coord, plot)

# process step time for all garden plots
func step_plots(step_time : float):
	for x in plots.range_x():
		for y in plots.range_y():
			(plots.get_at(Vector2(x,y)) as Plot).step(step_time)

# calculate price for an expansion based on current garden size
func get_garden_expansion_price(exp_v : Vector2) -> Dictionary:
	var new_width : int = plots.get_size().x + abs(exp_v.x)
	var new_height : int = plots.get_size().y + abs(exp_v.y)
	
	var current_plots := plots.get_size().x * plots.get_size().y
	var new_plots := (new_width * new_height) - current_plots
	
	var alignment := get_direction_alignment(exp_v)
	var price_dict := {}
	for key in alignment.keys():
		price_dict[key] = alignment[key] * plot_base_price * new_plots * (current_plots * 1.0 / min_garden_size)
	
	return price_dict

# expend supplies to purchase expansion and apply resize to garden
func purchase_expansion(exp_v : Vector2):
	var total_cost := get_garden_expansion_price(exp_v)
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
	setup_plots()
	garden_resized.emit()

func get_garden_rect() -> Rect2:
	return garden_rect

func set_plot(coord : Vector2, plot : Plot):
	plots.set_at(coord, plot)

func get_plot(coord : Vector2):
	if(plots == null):
		return null
	return plots.get_at(coord)

func connect_garden_resized(reciever_method : Callable):
	garden_resized.connect(reciever_method)

func get_direction_alignment(dir : Vector2) -> Dictionary:
	var alignment := {}
	if(dir.x > 0):
		alignment["AIR_ESS"] = abs(dir.x)
	elif(dir.x < 0):
		alignment["WATER_ESS"] = abs(dir.x)
	if(dir.y > 0):
		alignment["FIRE_ESS"] = abs(dir.y)
	elif(dir.y < 0):
		alignment["EARTH_ESS"] = abs(dir.y)
	return alignment
