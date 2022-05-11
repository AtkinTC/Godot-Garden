extends PlotComponent
class_name PassivePlotComponent

var base_gains : Dictionary
var level : int

func _init(_coord : Vector2, _object_key : String, _level : int = 1):
	coord = _coord
	object_key = _object_key
	level = _level
	
	# multiply gains values by level
	base_gains = ObjectsManager.get_object_type_attribute(object_key, Const.PASSIVE_GAIN, {}).duplicate()
	for key in base_gains:
		base_gains[key] = base_gains[key] * level
	
	for supply_key in base_gains.keys():
		SupplyManager.get_supply(supply_key).set_gain_source(str(coord), base_gains[supply_key])
		
func get_gains() -> Dictionary:
	return base_gains

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in base_gains.keys():
		SupplyManager.get_supply(supply_key).remove_gain_source(str(coord))
