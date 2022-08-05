class_name World
extends Node2D

signal selected_cell(cell : Vector2i)

var highlighted : bool = false
var highlighted_cell : Vector2i

var nav_controller : NavigationController

@onready var enemies_node: EnemiesNode = get_node("EnemiesNode")

var target_pos := Vector2.ZERO

var switch : int = 1
var p1 := Vector2.ZERO
var p2 := Vector2.ZERO
var int_cells : Array[Vector2i] = []

@export var font : Font

@export var level_scene : PackedScene

@onready var cam : Camera2D = $Camera

var level : Level
var spawn_area : RectNode2D
var goal_area : RectNode2D
var map : TileMapCust

var world_ready : bool = false

func _ready():
	level = get_node("Level")
	
	if(level_scene != null):
		if(level != null):
			level.queue_free()
		level = level_scene.instantiate()
		level.ready.connect(_on_ready)
		add_child(level)
		move_child(level, 0)
	else:
		_on_ready()

func _on_ready():
	map = level.get_tile_map()
	spawn_area = level.get_spawn_area()
	goal_area = level.get_goal_area()
	
	level.show_behind_parent = true
	map.show_behind_parent = true
	
	var center : Vector2 = get_world_center()
	cam.set_position(center)
	
	self.set_as_top_level(true)
	var goal_cells : Array[Vector2i] = []
	if(goal_area):
		goal_cells = rect_to_map_cells(goal_area.get_rect())
	nav_controller = NavigationController.new(map, goal_cells)
	
	world_ready = true
	
	if(spawn_area):
		var spawn_rect : Rect2i
		if(spawn_area != null):
			spawn_rect = spawn_area.get_rect()
		else:
			spawn_rect = Rect2i(Vector2i(896, 448), Vector2i(128, 128))
		
		var enemy_scene1 : PackedScene = preload("res://Scenes/test_enemy.tscn")
		var enemy_scene2 : PackedScene = preload("res://Scenes/test_enemy2.tscn")
		for i in range(10):
			var params = {}
			params["nav_controller"] = nav_controller
			params["position"] = spawn_rect.position + Vector2i(randi()%spawn_rect.size.x, randi()%spawn_rect.size.y)
			params["facing_direction"] = Vector2.from_angle(randf_range(0, TAU))
			
			if(randf() < 0.95):
				enemies_node.create_enemy(enemy_scene1, params)
			else:
				enemies_node.create_enemy(enemy_scene2, params)
			await(get_tree().create_timer(0.05).timeout)

func _process(_delta):
	pass

func get_world_center() -> Vector2:
	var center := map.get_used_rect().get_center()
	return map_to_world(center)

func _physics_process(delta: float) -> void:
	if(!world_ready):
		return
		
	target_pos = get_global_mouse_position()
	var objective_cellv := world_to_map(target_pos)

	nav_controller.process_maps_segmented(0, 1)
	update()
	
	for enemy in enemies_node.get_enemies():
		if(enemy.has_method("set_target_position")):
			enemy.set_target_position(target_pos)

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var target_cell := screen_to_map(event.position)
		print("-----------------")
		print(str("event.position =", event.position))
		print(str("target_cell =", target_cell))
		print(str("tile_def = ", map.get_tile_identifier_for_cell(target_cell)))

# convert map cell to local world coordinate
func map_to_world(map_coord : Vector2i) -> Vector2:
	return map.map_to_world(map_coord)

# convert local world coordinate to map cell
func world_to_map(world_coord : Vector2) -> Vector2i:
	return map.world_to_map(world_coord)

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
	return map.get_tile_size()

func _draw() -> void:
	if(!world_ready):
		return
		
	nav_controller.draw_goal_flow(self, 1)
	#nav_controller.draw_cell_widths(self, font)
