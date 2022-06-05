extends Node

signal garden_resized()
signal garden_state_changed()
signal garden_plot_updated(coord : Vector2)

var plot_types := {
	"base" : {
		"forest" : 0.5,
		"road" : 0.5
	},
	"forest" : {
		"forest" : 0.5,
		"deep forest" : 0.5
	},
	"deep forest" : {
		"forest" : 0.25,
		"deep forest" : 0.5,
		"cave" : 0.25
	},
	"road" : {
		"road" : 0.75,
		"cave" : 0.25
	},
	"cave" : {
		"road" : 0.75,
		"cave" : 0.25
	},
}

var plots_dict : Dictionary
var min_x : int
var max_x : int
var min_y : int
var max_y : int

var owned_plots : int = 0

# setup initial state of the garden
func initialize():
	pass

# process step time for all garden plots
func step_plots(step_time : float):
#	for x in plots.range_x():
#		for y in plots.range_y():
#			(plots.get_at(Vector2(x,y)) as Plot).step(step_time)
	for p in plots_dict.values():
		(p as Plot).step(step_time)

func create_plot(coord : Vector2) -> Plot:
	var plot : Plot = Plot.new()
	insert_plot(coord, plot)
	return plot

func insert_plot(coord : Vector2, plot : Plot):
	plot.set_coord(coord)
	plot.plot_updated.connect(_on_plot_updated)
	plots_dict[coord] = plot
	update_extents(coord)
	garden_plot_updated.emit(coord)

func update_extents(coord : Vector2):
	var changed = false
	if(min_x == null || coord.x < min_x):
		min_x = coord.x as int
		changed = true
	if(min_y == null || coord.y < min_y):
		min_y = coord.y as int
		changed = true
	if(max_x == null || coord.x > max_x):
		max_x = coord.x as int
		changed = true
	if(max_y == null || coord.y > max_y):
		max_y = coord.y as int
		changed = true
	if(changed):
		garden_resized.emit()

func get_extents() -> Rect2:
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func get_garden_rect() -> Rect2:
	#return garden_rect
	return get_extents()

func set_plot(coord : Vector2, plot : Plot):
	#plots.set_at(coord, plot)
	insert_plot(coord, plot)

func get_plot(coord : Vector2) -> Plot:
	return plots_dict.get(coord, null)

func connect_garden_resized(reciever_method : Callable):
	garden_resized.connect(reciever_method)

func get_empty_neighbors(coord : Vector2) -> Array:
	var neighbors := []
	for d in [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]:
		var neighbor : Plot = get_plot(coord+d)
		if(neighbor == null):
			neighbors.append(coord+d)
	return neighbors

func _on_plot_updated(coord : Vector2):
	var updated_plot : Plot = get_plot(coord)
	
	if(updated_plot == null):
		return false
	
