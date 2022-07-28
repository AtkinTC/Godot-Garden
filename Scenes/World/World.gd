class_name World
extends Node2D

signal selected_cell(cell : Vector2i)

@onready var map : TileMapCust = $WorldTileMap

var highlighted : bool = false
var highlighted_cell : Vector2i

var nav_controller : NavigationController
#var multi_flow_map : MultiFlowMapNavigation
#var flow_map_nav : FlowMapNavigation

@onready var enemies_node: EnemiesNode = get_node("EnemiesNode")

var target_pos := Vector2.ZERO

var switch : int = 1
var p1 := Vector2.ZERO
var p2 := Vector2.ZERO
var int_cells : Array[Vector2i] = []

@onready var spawn_area : RectNode2D = $SpawnArea
@onready var goal_area : RectNode2D = $GoalArea


func _ready():
	#get_viewport().warp_mouse(Vector2(640,320))
	map.show_behind_parent = true
	
	#multi_flow_map = MultiFlowMapNavigation.new(map)
	
	self.set_as_top_level(true)
	
	var goal_cells := rect_to_map_cells(goal_area.get_rect())
	#flow_map_nav = FlowMapNavigation.new(map, goal_cells)
	
	nav_controller = NavigationController.new(map, goal_cells)
	
	var spawn_rect : Rect2i
	if(spawn_area != null):
		spawn_rect = spawn_area.get_rect()
	else:
		spawn_rect = Rect2i(Vector2i(896, 448), Vector2i(128, 128))
	
	var enemy_scene : PackedScene = preload("res://Scenes/test_enemy.tscn")
	for i in range(500):
		var params = {}
		params["nav_controller"] = nav_controller
		params["position"] = spawn_rect.position + Vector2i(randi()%spawn_rect.size.x, randi()%spawn_rect.size.y)
		params["facing_direction"] = Vector2.from_angle(randf_range(0, TAU))
		
		enemies_node.create_enemy(enemy_scene, params)
		await(get_tree().create_timer(0.05).timeout)
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
	#var objective_cellv = Vector2i(13, 10)
	#target_pos = map_to_world(objective_cellv)
	
	#multi_flow_map.process_flow_map_segmented(objective_cellv, 0, 1)
	#flow_map_nav.process_flow_map_segmented(1, 1)
	nav_controller.process_maps_segmented(0, 1)
	update()
	
	for enemy in enemies_node.get_enemies():
		if(enemy.has_method("set_target_position")):
			enemy.set_target_position(target_pos)

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var target_cell := screen_to_map(event.position)
		select_cell(target_cell)
		print("-----------------")
		print(str("event.position =", event.position))
		print(str("target_cell =", target_cell))
		
		if(switch == 1):
			p1 = target_cell as Vector2 + Vector2(0.5, 0.5)
			int_cells = []
			switch = 2
		elif(switch == 2):
			p2 = target_cell as Vector2 + Vector2(0.5, 0.5)
			switch = 1
			int_cells = Utils.greedy_line_raster(p1.floor(), p2.floor())
			print(str("from: ", p1.floor(), " to: ", p2.floor()))
			print(int_cells)

# convert map cell to local world coordinate
func map_to_world(map_coord : Vector2i) -> Vector2:
	return map.map_to_world(map_coord)

# convert local world coordinate to map cell
func world_to_map(world_coord : Vector2) -> Vector2i:
	return map.world_to_map(world_coord)

func rect_to_map_cells(rect : Rect2) -> Array[Vector2i]:
	var p1 : Vector2i = world_to_map(rect.position)
	var p2 : Vector2i = world_to_map(rect.end)
	
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

func select_cell(_cell : Vector2i):
	if(_cell in GardenManager.get_used_plot_coords()):
		selected_cell.emit(_cell)
		
		#TDOD : remove this test code
		GardenManager.complete_exploration(_cell)
		print(_cell)
		print("base_type : " + str(GardenManager.get_plot(_cell).get_base_type()))
		print("plot_type : " + str(GardenManager.get_plot(_cell).get_plot_type()))

func _draw() -> void:
	#multi_flow_map.draw(self, target_pos)
	nav_controller.draw_goal_flow(self)
	
	for cell in int_cells:
		var p_tl = map_to_world(cell) - (map.get_tile_size() as Vector2)/2
		var p_bl = p_tl + (map.get_tile_size() as Vector2) * Vector2(0, 1)
		var p_br = p_tl + (map.get_tile_size() as Vector2) * Vector2(1, 1)
		var p_tr = p_tl + (map.get_tile_size() as Vector2) * Vector2(1, 0)
		draw_polyline([p_tl, p_tr, p_tr, p_br, p_br, p_bl, p_bl, p_tl], Color.BLACK)
	
	if(switch == 1 && p1 != p2):
		draw_line(p1*(map.get_tile_size() as Vector2), p2*(map.get_tile_size() as Vector2), Color.RED, 3)
	pass
