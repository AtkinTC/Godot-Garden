extends PlotComponent
class_name CapacityPlotComponent

var base_capacity: Dictionary

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	base_capacity = ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.CAPACITY, {})
	
	for supply_key in base_capacity.keys():
		SupplyManager.get_supply(supply_key).set_capacity_source(str(coord), base_capacity[supply_key])	
	
func get_capacity() -> Dictionary:
	return base_capacity

func cleanup_before_delete():
	for supply_key in base_capacity.keys():
		SupplyManager.get_supply(supply_key).remove_capacity_source(str(coord))
