extends PlotComponent
class_name PassivePlotComponent

var object_key : String

var base_gains : Dictionary

func _init(_object_key : String):
	object_key = _object_key
	base_gains = ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.PASSIVE_GAIN, {})

func get_object_attribute(attr_key : String, default = null) -> Variant:
	var val : Variant = ObjectsManager.get_object_type_attribute(object_key, attr_key)
	if(val == null):
		return default
	return val

func step(_delta : float):
	for key in base_gains.keys():
		SupplyManager.get_supply(key).change_quantity(base_gains[key] * _delta)

func get_gains() -> Dictionary:
	return base_gains

