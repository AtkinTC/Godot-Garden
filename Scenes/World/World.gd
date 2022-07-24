class_name World
extends Node2D

signal selected_cell(cell : Vector2i)

@onready var map : TileMapCust = $WorldTileMap

var highlighted : bool = false
var highlighted_cell : Vector2i

var nav_controller: Navigation

@onready var enemies_node: EnemiesNode = get_node("EnemiesNode")

var target_pos := Vector2.ZERO

func _init():
	nav_controller = Navigation.new()

func _ready():
	#get_viewport().warp_mouse(Vector2(640,320))
	map.show_behind_parent = true
	nav_controller.set_tile_map(map)
	
	var enemy_scene : PackedScene = preload("res://Scenes/test_enemy.tscn")
	for i in range(300):
		var params = {}
		params["nav_controller"] = nav_controller
		params["position"] = Vector2(896 + randi()%128, 448 + randi()%128)
		params["facing_direction"] = Vector2.from_angle(randf_range(0, TAU))
		
		enemies_node.create_enemy(enemy_scene, params)
		await(get_tree().create_timer(0.01).timeout)
		#yield(get_tree().create_timer(0.02), "timeout")
	
	pass

func _process(_delta):
	pass

func get_world_center() -> Vector2:
	var center := map.get_used_rect().get_center()
	return map_to_world(center)

func _physics_process(delta: float) -> void:
	target_pos = get_global_mouse_position()
	var objective_cellv := world_to_map(target_pos)
	if(!nav_controller.is_flow_map_complete(objective_cellv)):
		nav_controller.process_flow_map_segmented(objective_cellv, false, 0, true, 1)
	update()
	
	for enemy in enemies_node.get_enemies():
		if(enemy.has_method("set_target_position")):
			enemy.set_target_position(target_pos)

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var target_cell = screen_to_map(event.position)
		select_cell(target_cell)
		print("-----------------")
		print(str("event.position =", event.position))
		print(str("target_cell =", target_cell))

# convert map cell to local world coordinate
func map_to_world(map_coord : Vector2i) -> Vector2:
	return map.map_to_world(map_coord)

# convert local world coordinate to map cell
func world_to_map(world_coord : Vector2) -> Vector2i:
	return map.world_to_map(world_coord)

# convert global coordinate to local world coordinate
func global_to_world(global_coord : Vector2) -> Vector2:
	return global_coord - self.position

# convert screen coordinate to local world coordinate
# calculated with camera position and zoom
func screen_to_world(world_coord : Vector2) -> Vector2:
	var viewport : Viewport = get_viewport()
	var camera : Camera2D = viewport.get_camera_2d()
	var coord := get_viewport().canvas_transform.affine_inverse().basis_xform(world_coord - (viewport.get_size() as Vector2)/2) + camera.get_position()
	return coord

# convert screen coordinate to map cell
func screen_to_map(global_coord : Vector2) -> Vector2i:
	return world_to_map(screen_to_world(global_coord))

func get_tile_size() -> Vector2i:
	return map.get_tile_size()

func select_cell(_cell : Vector2i):
	if(_cell in GardenManager.get_used_plot_coords()):
		selected_cell.emit(_cell)
		
		#TDOD : remove this test code
		GardenManager.complete_exploration(_cell)
		print(_cell)
		print("base_type : " + str(GardenManager.get_plot(_cell).get_base_type()))
		print("plot_type : " + str(GardenManager.get_plot(_cell).get_plot_type()))

func _draw() -> void:
	#nav_controller.draw(self, target_pos)
	#self.draw_circle(position, 100, Color.BLACK)
	pass
