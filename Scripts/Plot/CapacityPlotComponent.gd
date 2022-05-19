extends PlotComponent
class_name CapacityPlotComponent

var base_capacity: Dictionary
var level : int

func _init(_coord : Vector2, _object_key : String, _level : int = 1):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	coord = _coord
	object_key = _object_key
	level = _level
	recalculate()

func recalculate():
	# multiply capacity values by level
	var source : Dictionary = ObjectsManager.get_object_type_attribute(object_key, Const.SOURCE, {}).duplicate()
	base_capacity = source.get(Const.CAPACITY).get(Const.VALUE)
	for key in base_capacity:
		base_capacity[key] = base_capacity[key] * level
	
	for supply_key in base_capacity.keys():
		SupplyManager.set_capacity_source(supply_key, str(coord), base_capacity[supply_key])	

func get_capacity() -> Dictionary:
	return base_capacity

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in base_capacity.keys():
		SupplyManager.remove_capacity_source(supply_key, str(coord))

func _on_modifiers_updated():
	recalculate()
