class_name AreaVO
extends Resource

var area_id : int
var area_name : String
var area_icon_name : String
var area_rank : int
var area_level : int
var area_level_progress : float

## area_id ##
func set_area_id(_area_id : int) -> void:
	if(area_id != _area_id):
		area_id = _area_id
		changed.emit()

func get_area_id() -> int:
	return area_id

## area_name ##
func set_area_name(_area_name : String) -> void:
	if(area_name != _area_name):
		area_name = _area_name
		changed.emit()

func get_area_name() -> String:
	return area_name

## area_icon_name ##
func set_area_icon_name(_area_icon_name : String) -> void:
	if(area_icon_name != _area_icon_name):
		area_icon_name = _area_icon_name
		changed.emit()

func get_area_icon_name() -> String:
	return area_icon_name

## area_rank ##
func set_area_rank(_area_rank : int) -> void:
	if(area_rank != _area_rank):
		area_rank = _area_rank
		changed.emit()

func get_area_rank() -> int:
	return area_rank

## area_level ##
func set_area_level(_area_level : int) -> void:
	if(area_level != _area_level):
		area_level = _area_level
		changed.emit()

func get_area_level() -> int:
	return area_level

## area_level_progress ##
func set_area_level_progress(_area_level_progress : float) -> void:
	if(area_level_progress != _area_level_progress):
		area_level_progress = _area_level_progress
		changed.emit()

func get_area_level_progress() -> float:
	return area_level_progress
