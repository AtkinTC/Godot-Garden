extends PlotComponent
class_name PassivePlotComponent

var base_gains : Dictionary

func _init(_coord : Vector2, _object_key : String):
	coord = _coord
	object_key = _object_key
	base_gains = ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.PASSIVE_GAIN, {})

func step(_delta : float):
	for key in base_gains.keys():
		SupplyManager.get_supply(key).change_quantity(base_gains[key] * _delta)

func get_gains() -> Dictionary:
	return base_gains

