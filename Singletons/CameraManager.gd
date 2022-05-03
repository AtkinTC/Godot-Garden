extends Node

var camera : CustCamera2D

func connect_camera(_camera):
	camera = _camera

func get_camera_zoom_level():
	if(!camera):
		return -1
	
	return camera.get_zoom_level()
