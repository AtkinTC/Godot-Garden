extends Node

signal garden_resized()
signal garden_state_changed()
signal garden_plot_updated(coord : Vector2)

var plots : Array2D
var garden_rect := Rect2(-1, -1, 3, 3)

var plot_base_price : float = 5.0
var min_garden_size : int 

var owned_plots : int = 0

# setup initial state of the garden
func initialize():
	min_garden_size = int(garden_rect.size.x * garden_rect.size.y)
	setup_plots(true)
	add_available_plots()

# rebuild garden plots array based on current sizing
func setup_plots(owned : bool = false):
	var old := plots
	plots = Array2D.new(garden_rect.size, garden_rect.position)
	
	# insert existing plots into new garden
	if(old != null):
		plots.insert(old)
	
	# create new plots to fill in the garden
	for x in plots.range_x():
		for y in plots.range_y():
			var coord := Vector2(x,y)
			if(old == null || !(x in old.range_x()) || !(y in old.range_y())):
				var plot : Plot = Plot.new()
				plot.set_coord(coord)
				if(owned):
					plot.set_owned(owned)
				plot.plot_updated.connect(_on_plot_updated)
				set_plot(coord, plot)
	
	
	for x in plots.range_x():
		for y in plots.range_y():
			update_plot_visibility_outgoing(Vector2(x,y))
			# update plot availability based on neighbors
			for coord in [Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
				var neighbor = plots.get_at(Vector2(x,y) + coord)
				if(neighbor != null && neighbor.is_owned()):
					plots.get_at(Vector2(x,y)).set_available(true)
					break
	
	count_owned_plots()

# increase garden size if any outer edge plots are owned to allow further expansion
func add_available_plots():
	var exp_n := false
	var exp_s := false
	var exp_e := false
	var exp_w := false
	
	for x in plots.range_x():
		if(plots.get_at(Vector2(x, plots.min_y())).is_owned()):
			exp_n = true
		if(plots.get_at(Vector2(x, plots.max_y())).is_owned()):
			exp_s = true
		if(exp_n && exp_s):
			break
	
	for y in plots.range_y():
		if(plots.get_at(Vector2(plots.min_x(), y)).is_owned()):
			exp_w = true
		if(plots.get_at(Vector2(plots.max_x(), y)).is_owned()):
			exp_e = true
		if(exp_w && exp_e):
			break
			
	var position : Vector2 = garden_rect.position + Vector2(-int(exp_w), -int(exp_n))
	var size : Vector2 = garden_rect.size + Vector2(int(exp_w) + int(exp_e), int(exp_n) + int(exp_s))
	
	if(position != garden_rect.position || size != garden_rect.size):
		set_garden_rect(Rect2(position, size))

# count all owned plots in the garden
func count_owned_plots():
	owned_plots = 0
	for x in plots.range_x():
		for y in plots.range_y():
			owned_plots += int(plots.get_at(Vector2(x,y)).is_owned())

# process step time for all garden plots
func step_plots(step_time : float):
	for x in plots.range_x():
		for y in plots.range_y():
			(plots.get_at(Vector2(x,y)) as Plot).step(step_time)

# calculate price of purchasing a single garden plot
func get_plot_purchase_price(coord : Vector2) -> Dictionary:
	var alignment := get_direction_alignment(coord.normalized())
	
	var price_dict := {}
	for key in alignment.keys():
		price_dict[key] = alignment[key] * plot_base_price * (owned_plots - min_garden_size + 1)
		price_dict[key] *= coord.length_squared()
	
	return price_dict

# expand the size of the garden based on a provided expansion vector
# only expands, negative value will expand in the negative direction
func expand_garden(exp_v : Vector2):
	var _offset : Vector2 = garden_rect.position + Vector2(min(exp_v.x, 0), min(exp_v.y, 0))
	var _size : Vector2 = garden_rect.size + abs(exp_v)
	
	set_garden_rect(Rect2(_offset, _size))

# set the rectangle size of the garden
func set_garden_rect(_garden_rect : Rect2):
	garden_rect = _garden_rect
	setup_plots()
	garden_resized.emit()

func get_garden_rect() -> Rect2:
	return garden_rect

func set_plot(coord : Vector2, plot : Plot):
	plots.set_at(coord, plot)

func get_plot(coord : Vector2) -> Plot:
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

func _on_plot_updated(coord : Vector2):
	var updated_plot : Plot = plots.get_at(coord)
	
	if(updated_plot == null):
		return false
	
	update_plot_visibility_outgoing(coord)
	
	count_owned_plots()

func update_plot_visibility_outgoing(coord : Vector2):
	var updated_plot : Plot = plots.get_at(coord)
	
	if(updated_plot == null):
		return false
	
	if(updated_plot.is_owned() || coord.is_equal_approx(Vector2.ZERO)):
		updated_plot.set_visible(true)
	
	if(updated_plot.is_owned() && updated_plot.has_structure()):
		var r : int = updated_plot.get_structure().get_structure_data().get_vision_distance()
		var x_range = range(-r, r+1)
		for x in x_range:
			var ry = (r-(abs(x)))
			var y_range = range(-ry, ry+1)
			for y in y_range:
				if(x == 0 && y == 0):
					continue
				var vis_plot : Plot = plots.get_at(coord + Vector2(x,y))
				if(vis_plot != null):
					vis_plot.set_visible(true)
