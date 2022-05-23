extends Control
class_name PlotDisplayContent

# # # # #
# Base class for Plot Display Content elements
# Does nothing on its own, just an interface class for inheritance 
# # # # #

var world_coord : Vector2

func init(_world_coord : Vector2) -> void:
	world_coord = _world_coord
