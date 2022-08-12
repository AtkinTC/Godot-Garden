class_name World
extends Node2D

signal selected_cell(cell : Vector2i)

var highlighted : bool = false
var highlighted_cell : Vector2i

var nav_controller : NavigationController

var target_pos := Vector2.ZERO

@export var font : Font

@onready var spawn_areas : Array[RectNode2D] = []
@onready var goal_areas : Array[RectNode2D] = []
@onready var tile_map : TileMapCust = get_node_or_null("TileMap")
@onready var enemies_node: EnemiesNode = get_node_or_null("EnemiesNode")

func _ready():
	tile_map.show_behind_parent = true
	
	var spawn_areas_node = get_node_or_null("%SpawnAreas")
	if(spawn_areas_node):
		for child in spawn_areas_node.get_children():
			if(child is RectNode2D):
				spawn_areas.append(child)
	
	var goal_areas_node = get_node_or_null("%GoalAreas")
	if(goal_areas_node):
		for child in goal_areas_node.get_children():
			if(child is RectNode2D):
				goal_areas.append(child)
	
	self.set_as_top_level(true)
	var goal_cells : Array[Vector2i] = []
	for goal_area in goal_areas:
		goal_cells.append_array(rect_to_map_cells(goal_area.get_rect()))
	nav_controller = NavigationController.new(tile_map, goal_cells)
	
	if(spawn_areas.size() > 0):
		var spawn_rect : Rect2i = spawn_areas[0].get_rect()
		
		var enemy_scene1 : PackedScene = preload("res://Scenes/GameEntities/Enemies/test_zombie.tscn")
		for i in range(500):
			var params = {}
			params["nav_controller"] = nav_controller
			params["position"] = spawn_rect.position + Vector2i(randi()%spawn_rect.size.x, randi()%spawn_rect.size.y)
			params["facing_rotation"] = randf_range(0, TAU)
			
			enemies_node.create_enemy(enemy_scene1, params)
			await(get_tree().create_timer(0.5).timeout)

func _process(_delta):
	pass

func get_world_center() -> Vector2:
	var center := tile_map.get_used_rect().get_center()
	return map_to_world(center)

func _physics_process(_delta: float) -> void:
	nav_controller.process_maps_segmented(0, 1)
	update()

var hold_p : Vector2

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var target_cell := screen_to_map(event.position)
		print("-----------------")
		print(str("event.position =", event.position))
		print(str("target_cell =", target_cell))
		print(str("tile_def = ", tile_map.get_tile_identifier_for_cell(target_cell)))
		
		hold_p = screen_to_world(event.position)
	
	if(event.is_action_released("mouse_left")):
		var p = screen_to_world(event.position)
		var d = (p - hold_p).length()
		var r = (p - hold_p).angle()
		var effect_scene_path := "res://Scenes/Effects/BaseProjectile.tscn"
		var mask : int = PhysicsUtil.get_physics_layer_mask_from_names(["enemy"])
		var effect_attributes := {
			"source" : null,
			"collision_mask" : mask,
			"speed" : d,
			"rotation" : r,
			"position" : p
		}
		
		SignalBus.spawn_effect.emit(effect_scene_path, effect_attributes)

# convert map cell to local world coordinate
func map_to_world(map_coord : Vector2i) -> Vector2:
	return tile_map.map_to_world(map_coord)

# convert local world coordinate to map cell
func world_to_map(world_coord : Vector2) -> Vector2i:
	return tile_map.world_to_map(world_coord)

func rect_to_map_cells(rect : Rect2) -> Array[Vector2i]:
	var p1 : Vector2i = world_to_map(rect.position)
	var p2 : Vector2i = world_to_map(rect.end-Vector2(1,1))
	
	var cells : Array[Vector2i] = []
	for x in range(p1.x, p2.x+1):
		for y in range(p1.y, p2.y+1):
			cells.append(Vector2i(x,y))
	return cells

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
	return tile_map.get_tile_size()

func _draw() -> void:
	#nav_controller.draw_goal_flow(self, 1)
	#nav_controller.draw_cell_widths(self, font)
	pass
