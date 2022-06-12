extends Node2D

signal selected_cell(cell : Vector2i)
signal highlight_cell_changed(cell : Vector2i)
signal highlight_cleared()

@onready var map : TileMap = $PlotsBaseTileMap
@onready var highlightsMap : HighlightsTileMap = $HighlightsTileMap

var highlighted : bool = false
var highlighted_cell : Vector2i

func _ready():
	get_viewport().warp_mouse(Vector2(640,320))
	
	highlight_cell_changed.connect(highlightsMap._on_highlight_cell_changed)
	highlight_cleared.connect(highlightsMap._on_highlight_cleared)

func _process(delta):
	pass

func _unhandled_input(event : InputEvent):
	if(event.is_action_pressed("mouse_left")):
		var target_cell = screen_to_map(event.position)
		select_cell(target_cell)

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
	return map.get_tileset().get_tile_size()

func select_cell(_cell : Vector2i):
	if(_cell as Vector2 in GardenManager.get_used_plots()):
		ActionManager.apply_current_action_to_plot(_cell)
		selected_cell.emit(_cell)
		set_highlighted_cell(_cell)
	else:
		clear_highlight()

func set_highlighted_cell(_cell : Vector2i):
	if(!highlighted || _cell != highlighted_cell):
		highlighted = true
		highlighted_cell = _cell
		highlight_cell_changed.emit(_cell)

func clear_highlight():
	if(highlighted):
		highlighted = false
		highlight_cleared.emit()


