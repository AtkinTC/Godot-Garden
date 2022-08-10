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
			var cx = Vector2i(x, s*(x - c0.x) + c0.y)
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
			var y1 : int = round(y1_f)
			var y : int = round(s*(x - c0.x) + c0.y)
			var y2_f : float = s*(x+0.5 - c0.x) + c0.y
			var y2 : int = round(y2_f)
			
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
			var x1 : int = round(x1_f)
			var x : int = round(s_i*(y - c0.y) + c0.x)
			var x2_f : float = s_i*(y+0.5 - c0.y) + c0.x
			var x2 : int = round(x2_f)
			
			if(x1 != x):
				cells.append(Vector2i(x1, y))
			elif(is_equal_approx(abs(x1_f - x1), 0.5)):
				var adj_x : int = (1 if x1_f > x else -1)
				var v := Vector2i(x1 + adj_x, x)
				cells.append(Vector2i(x1 + adj_x, y))
			
			cells.append(Vector2i(x, y))
			
			if(x2 != x):
				cells.append(Vector2i(x2, y))
			elif(is_equal_approx(abs(x2_f - x1), 0.5)):
				var adj_x : int = (1 if x2_f > x else -1)
				var v := Vector2i(x1 + adj_x, y)
				cells.append(Vector2i(x2 + adj_x, y))
		return cells

	print_debug("ERROR: unexpected path in method")
	return [c0, c1]
