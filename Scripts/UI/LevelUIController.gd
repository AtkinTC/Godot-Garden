class_name LevelUIController
extends Control

enum STATE {NONE, MOVE}
var state = STATE.NONE

var current_action := {}
var world : World
var draw_surface : RID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.trigger_ui_action.connect(_on_trigger_ui_action, CONNECT_DEFERRED)

	call_deferred("post_ready")

# deferred ready function for additional setup that relies on other nodes being ready
func post_ready() -> void:
	if(world == null):
		world = ResourceRef.get_current_game_world()
	
	draw_surface = world.get_canvas_item()

func _process(_delta: float) -> void:
	match state:
		STATE.NONE:
			pass
		STATE.MOVE:
			process_move()
	update()

func _unhandled_input(event: InputEvent) -> void:
	match state:
		STATE.NONE:
			return
		STATE.MOVE:
			handle_input_move(event)
				
	
func _on_trigger_ui_action(action_def: Dictionary) -> void:
	if(action_def == null):
		return
	
	match action_def.source_type:
		"HeroUnit":
			handle_hero_actions(action_def)
		_:
			print("_on_trigger_ui_action :: unrecognized action source type")

func handle_hero_actions(action_def: Dictionary) -> void:
	var hero : HeroUnit = action_def.source
	if(not hero is HeroUnit):
		print("handle_hero_actions :: invalid source")
		return
	
	match action_def.key:
		"move":
			start_move_state(action_def)
		var key:
			print("handle_hero_actions :: unrecognized action type key : " + str(key))

func start_move_state(action_def : Dictionary):
	var hero : HeroUnit = action_def.source
	var target_cells : Array[Vector2i] = hero.get_possible_move_targets()
	if(!target_cells.is_empty()):
		state = STATE.MOVE
		current_action = action_def.duplicate()
		current_action["target_cells"] = target_cells
		current_action["nav_controller"] = hero.get_navigation_controller()
		var tile_size : Vector2 = hero.get_navigation_controller().get_tile_size()
		var merge : Array = Utils.merge_cells(target_cells)
		var outer_polygons = []
		var inner_polygons = []
		for poly in merge:
			poly = (poly as Array).map(func(v): return v * tile_size)
			if(Geometry2D.is_polygon_clockwise(poly)):
				inner_polygons.append(poly)
			else:
				outer_polygons.append(poly)
		current_action["outer_polygons"] = outer_polygons
		current_action["inner_polygons"] = inner_polygons

func process_move():
	var mouse_p: Vector2 = get_global_mouse_position()
	var mouse_c: Vector2i = world.screen_to_map(mouse_p)
	if(mouse_c in current_action.target_cells):
		current_action["highlight_cell"] = mouse_c
	else:
		current_action["highlight_cell"] = null
		
func handle_input_move(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var screen_pos: Vector2 = event.position
		var map_cell : Vector2i = world.screen_to_map(screen_pos)
		if(map_cell in current_action.target_cells):
			print("valid move target")
			#TODO: send move command to hero unit
		else:
			print("invalid move target")
			state = STATE.NONE
#		get_viewport().set_input_as_handled()
	
func _draw():
	match state:
		STATE.MOVE:
			var nav_controller : NavigationController = current_action.nav_controller
			var tile_size := nav_controller.tile_map.get_tile_size()
			
			var area_fill_color = Color.BLUE
			area_fill_color.a = 0.15
			
			for cell in current_action.target_cells:
				var c : Vector2 = cell * tile_size
				var rect := Rect2(c, tile_size)
				Utils.canvas_draw_rect(draw_surface, rect, area_fill_color, true)
			
			for poly in current_action.outer_polygons:
				Utils.canvas_draw_polygon(draw_surface, poly, Color.BLUE, false, 4.0)
			for poly in current_action.inner_polygons:
				Utils.canvas_draw_polygon(draw_surface, poly, Color.GREEN, false, 4.0)
			
			var highlight_cell = current_action.highlight_cell
			if(highlight_cell is Vector2i):
				var c : Vector2 = highlight_cell * tile_size
				var rect := Rect2(c, tile_size)
				var fill_color = Color.RED
				fill_color.a = 0.33
				var line_color = Color.RED
				line_color.a = 0.66
				Utils.canvas_draw_rect(draw_surface, rect, fill_color, true)
				Utils.canvas_draw_rect(draw_surface, rect, line_color, false, 2.0)
