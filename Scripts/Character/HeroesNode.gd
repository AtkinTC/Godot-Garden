class_name HeroesNode
extends Node2D

func get_reserved_cells() -> Array[Vector2i]:
	var reserved_cells : Array[Vector2i] = []
	for child in get_children():
		if(child.has_method("get_reserved_cells")):
			reserved_cells.append_array(child.get_reserved_cells())
	return reserved_cells
