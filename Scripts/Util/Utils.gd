class_name Utils

static func format_comma_seperated(number : String) -> String:
	var number_string = str(number)
	var parts := number_string.split(".")
	
	if(parts.size() == 0):
		return number_string
	
	var pre = parts[0]
	var pos = pre.length() - 3
	while(pos > 0):
		pre = pre.insert(pos, ",")
		pos -= 3
	
	if(parts.size() == 2):
		var post = parts[1]
		return pre + "." + post
		
	return pre

# unwrap_angle(angle : float)
# utility method to convert an angle (in radians) to be in the range (0, TAU)
static func unwrap_angle(angle : float):
	if(angle >= TAU):
		var temp_angle = fmod(angle, TAU)
		return temp_angle
	elif(angle < 0):
		var temp_angle = fmod(-angle, TAU)
		return TAU - temp_angle
	return angle

# calculate a list of points that would make up a rasterized line from point c0 to point c1
# greedy raster finds more than just the minimal thin line, including any points that would be touched by the line
# intended for use in line of sight calculations in a grid space such as a tilemap
static func greedy_line_raster(c0 : Vector2i, c1 : Vector2i) -> Array[Vector2i]:
	if(c0 == c1):
		return [c0]
	
	var cells : Array[Vector2i] = []
	
	var sign_x : int = sign(c1.x - c0.x)
	var sign_y : int = sign(c1.y - c0.y)
	var mod_x : int = 1 if (sign_x >= 0) else -1
	var mod_y : int = 1 if (sign_y >= 0) else -1
	
	if(sign_x == 0):
		# special case : vertical line
		for y in range(c0.y, c1.y+mod_y, mod_y):
			cells.append(Vector2i(c0.x, y))
		return cells
	if(sign_y == 0):
		# special case : horizontal line
		for x in range(c0.x, c1.x+mod_x, mod_x):
			cells.append(Vector2i(x, c0.y))
		return cells
	
	var s : float = (c1.y - c0.y) as float / (c1.x - c0.x) as float
	
	if(abs(s) == 1.0):
		#special case : perfect diagonal
		cells.append(c0)
		cells.append(c0 + Vector2i(0, mod_y))
		for x in range(c0.x+mod_x, c1.x, mod_x):
			var cx := Vector2i(x, int(s*(x - c0.x) + c0.y))
			cells.append(cx - Vector2i(0, mod_y))
			cells.append(cx)
			cells.append(cx + Vector2i(0, mod_y))
		cells.append(c1 - Vector2i(0, mod_y))
		cells.append(c1)
		return cells
		
	if(abs(s) < 1.0):
		# x-dominant slope : calculate once per x
		for x in range(c0.x, c1.x + mod_x, mod_x):
			var y1_f : float = s*(x-0.5 - c0.x) + c0.y
			var y1 : int = round(y1_f) as int
			var y : int = round(s*(x - c0.x) + c0.y) as int
			var y2_f : float = s*(x+0.5 - c0.x) + c0.y
			var y2 : int = round(y2_f) as int
			
			if(y1 != y):
				cells.append(Vector2i(x, y1))
			elif(is_equal_approx(abs(y1_f - y), 0.5)):
				var adj_y : int = (1 if y1_f > y else -1)
				cells.append(Vector2i(x, y1 + adj_y))
			
			cells.append(Vector2i(x, y))
			
			if(y2 != y):
				cells.append(Vector2i(x, y2))
			elif(is_equal_approx(abs(y2_f - y), 0.5)):
				var adj_y : int = (1 if y2_f > y else -1)
				cells.append(Vector2i(x, y2 + adj_y))
		return cells
	
	if(abs(s) > 1.0):
		# y-dominant slope : calculate once per y
		var s_i = 1.0/s
		for y in range(c0.y, c1.y + mod_y, mod_y):
			var x1_f : float = s_i*(y-0.5 - c0.y) + c0.x
			var x1 : int = round(x1_f) as int
			var x : int = round(s_i*(y - c0.y) + c0.x) as int
			var x2_f : float = s_i*(y+0.5 - c0.y) + c0.x
			var x2 : int = round(x2_f) as int
			
			if(x1 != x):
				cells.append(Vector2i(x1, y))
			elif(is_equal_approx(abs(x1_f - x1), 0.5)):
				var adj_x : int = (1 if x1_f > x else -1)
				cells.append(Vector2i(x1 + adj_x, y))
			
			cells.append(Vector2i(x, y))
			
			if(x2 != x):
				cells.append(Vector2i(x2, y))
			elif(is_equal_approx(abs(x2_f - x1), 0.5)):
				var adj_x : int = (1 if x2_f > x else -1)
				cells.append(Vector2i(x2 + adj_x, y))
		return cells

	print_debug("ERROR: unexpected path in method")
	return [c0, c1]

# converts a cell coordinate into a 1-by-1 polygon
static func cell_to_poly(cell : Vector2i):
	return [cell, Vector2i(cell.x+1, cell.y), cell + Vector2i.ONE, Vector2i(cell.x, cell.y+1)]

# returns a list of polygons representing the borders of the space covered by the supplied cells
#	The operation may result in multiple outer polygons (boundary) and multiple inner polygons (holes) produced
#	which could be distinguished by calling is_polygon_clockwise().
#		outer polygon : counter-clockwise
#		inner polygon : clockwuse
static func merge_cells(cells : Array[Vector2i]) -> Array:
	if(cells.size() == 0):
		return []
	if(cells.size() == 1):
		return cell_to_poly(cells[0])
	
	var remaining_set : Array[Vector2i] = cells.duplicate()

	var outer_polys := []
	var inner_polys = []
	
	while(!remaining_set.is_empty()):
		var open_set : Array[Vector2i] = [remaining_set.pop_front()]
		var poly : Array[Vector2] = []
		while(!open_set.is_empty()):
			var cell : Vector2i = open_set.pop_front()
			
			if(poly.is_empty()):
				poly = cell_to_poly(cell)
			else:
				var cell_poly := cell_to_poly(cell)
				
				# merge with existing inner polygons to see if they can be reduced
				var new_inner_polys = []
				for inner in inner_polys:
					# clipping will try and reduce the inner space by the new cell polygon
					# if there is a reduction, the result could be an empty array, a single smaller space, or multiple smaller paces
					var clips := Geometry2D.clip_polygons(inner, cell_poly)
					for clip in clips:
						# clipping a positive from a negative space, so flip all the resulting orientations
						if(!Geometry2D.is_polygon_clockwise(clip)):
							clip.reverse()
							new_inner_polys.append(clip)
				inner_polys = new_inner_polys
				
				var results := Geometry2D.merge_polygons(poly, cell_poly)
				for result in results:
					if(Geometry2D.is_polygon_clockwise(result)):
						inner_polys.append(result)
					else:
						poly = Array(result)
			
			for d in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
				var n_cell = d + cell
				if(remaining_set.has(n_cell) &&  !open_set.has(n_cell)):
					open_set.append(n_cell)
					remaining_set.erase(n_cell)
		outer_polys.append(poly)
	return outer_polys + inner_polys

# tween_to(initial: Variant, final: Variant, rate: float, delta: float, trans_type: TransitionType, ease_type: EaseType)
static func tween_to(initial: Variant, final: Variant, rate: float, delta: float, trans_type := Tween.TRANS_QUINT, ease_type := Tween.EASE_OUT):
	var duration : float = 0
	if(initial is Vector2 || initial is Vector2i):
		duration = (final - initial).length() / rate
	else:
		duration = abs(final - initial) / rate
	if(duration < delta):
		return final
	else:
		return Tween.interpolate_value(initial, final - initial, delta, duration, trans_type, ease_type)

#############
## DRAWING ##
#############

static func canvas_draw_line(canvas_item: RID, p1: Vector2, p2: Vector2, c: Color, w := 1.0, aa := false) -> void:
	RenderingServer.canvas_item_add_line(canvas_item, p1, p2, c, w, aa)

static func canvas_draw_circle(canvas_item: RID, p: Vector2, r: float, c: Color) -> void:
	RenderingServer.canvas_item_add_circle(canvas_item, p, r, c)

static func canvas_draw_rect(canvas_item: RID, r: Rect2, c : Color, f := false, w := 1.0, aa := false) -> void:
	if(f):
		RenderingServer.canvas_item_add_rect(canvas_item, r, c)
	else:
		var points : PackedVector2Array = [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
		var colors : PackedColorArray = [c]
		RenderingServer.canvas_item_add_polyline(canvas_item, points, colors, w, aa)

static func canvas_draw_polygon(canvas_item: RID, p: PackedVector2Array, c : Color, f := false, w := 1.0, aa := false):
	if(f):
		RenderingServer.canvas_item_add_polygon(canvas_item, p, [c])
	else:
		p = polygon_to_polyline(p)
		RenderingServer.canvas_item_add_polyline(canvas_item, p, [c], w, aa)

static func polygon_to_polyline(polygon : PackedVector2Array) -> PackedVector2Array:
	var polyline : PackedVector2Array = polygon.duplicate()
	if(polyline[0] != polyline[polyline.size()-1]):
		polyline.append(polyline[0])
	return polyline
