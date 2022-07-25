class_name AdvancedFlowMapNavigation
extends FlowMapNavigation

func get_flow_direction_local(startv: Vector2i, flow_map_2d: Array2D):
	if(flow_map_2d == null):
		return Vector2.ZERO
	return flow_map_2d.get_from_v(startv).normalized()

# processes a single cell in an in-progress flow map
func process_next_cell_flow_map(flow_map: Array2D, open_set: Array, d_map: Dictionary):
	var c_cell: Vector2i = open_set.pop_front()
	if(!has_cell(c_cell)):
		return
	
	var c_target_cell : Vector2i = ((c_cell as Vector2) + flow_map.get_from_v(c_cell)) as Vector2i
	
	# cardinal directions
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n_cell: Vector2i = c_cell + direction
		
		if(is_cell_navigable(n_cell)):
			# try to leapfrog forward by looking for a direct line of sight to a future cell
			var inters : Array[Vector2i] = Utils.greedy_line_raster(n_cell, c_target_cell)
			
			var direct = true
			for inter_c in inters:
				if(!is_cell_navigable(inter_c)):
					direct = false
					break
			if(direct):
				var vec : Vector2 = ((c_target_cell - n_cell) as Vector2)
				var distance: float = vec.length() + d_map[c_target_cell]
				if(distance <= 0.1):
					pass
				if(!d_map.has(n_cell) || distance < d_map[n_cell]):
					d_map[n_cell] = distance
					# record the direction vector from neighbor cell to the current cell
					flow_map.set_to_v(n_cell, vec)
					open_set.append(n_cell)
					continue
			
			var distance: float = d_map[c_cell] + 1
			if(!d_map.has(n_cell) || distance < d_map[n_cell]):
				d_map[n_cell] = distance
				# record the direction vector from neighbor cell to the current cell
				flow_map.set_to_v(n_cell, ((c_cell-n_cell) as Vector2))
				open_set.append(n_cell)
