extends PlotComponent
class_name PassivePlotComponent

var base_gains : Dictionary

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	base_gains = ObjectsManager.get_object_type_attribute(object_key, Const.PASSIVE_GAIN, {})
	
	for supply_key in base_gains.keys():
		SupplyManager.get_supply(supply_key).set_gain_source(str(coord), base_gains[supply_key])	
		
func get_gains() -> Dictionary:
	return base_gains

func cleanup_before_delete():
	for supply_key in base_gains.keys():
		SupplyManager.get_supply(supply_key).remove_gain_source(str(coord))
