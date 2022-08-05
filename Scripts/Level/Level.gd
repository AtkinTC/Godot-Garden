class_name Level
extends Node2D

@onready var tile_map : TileMapCust = get_node_or_null("TileMap")
@onready var spawn_area : RectNode2D = get_node_or_null("SpawnArea")
@onready var goal_area : RectNode2D = get_node_or_null("GoalArea")

func get_tile_map() -> TileMapCust:
	return tile_map

func get_spawn_area() -> RectNode2D:
	return spawn_area

func get_goal_area() -> RectNode2D:
	return goal_area
