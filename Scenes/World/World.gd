extends Node2D

@onready var map : TileMap = $PlotsBaseTileMap
#@onready var camera : Camera2D = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().warp_mouse(Vector2(640,320))

func _process(delta):
	pass

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		print("----------")
		print(event.position)
		print(screen_to_map(event.position))
		var screen_mouse = event.position
		var local_mouse = get_local_mouse_position()
		print(str(local_mouse) + ", " + str(world_to_map(local_mouse)))
		print(str(screen_mouse) + ", " + str(screen_to_map(screen_mouse)))

func map_to_world(map_coord : Vector2i) -> Vector2:
	return map.map_to_world(map_coord)

func world_to_map(world_coord : Vector2) -> Vector2i:
	return map.world_to_map(world_coord)

func global_to_world(global_coord : Vector2) -> Vector2:
	return global_coord - self.position

func screen_to_world(world_coord : Vector2) -> Vector2:
	var viewport : Viewport = get_viewport()
	var camera : Camera2D = viewport.get_camera_2d()
	var coord := get_viewport().canvas_transform.affine_inverse().basis_xform(world_coord - (viewport.get_size() as Vector2)/2) + camera.get_position()
	return coord

func screen_to_map(global_coord : Vector2) -> Vector2i:
	return world_to_map(screen_to_world(global_coord))

func get_tile_size() -> Vector2i:
	return map.get_tileset().get_tile_size()
