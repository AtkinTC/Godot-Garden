extends PlotComponent
class_name PassivePlotComponent

var object_key : String

var base_resource_gains : Dictionary

func _init(_object_key : String):
	object_key = _object_key
	base_resource_gains = ObjectsManager.get_object_type_attribute(object_key, ObjectsManager.PASSIVE_RESOURCE_GAIN, {})

func get_object_attribute(attr_key : String, default = null) -> Variant:
	var val : Variant = ObjectsManager.get_object_type_attribute(object_key, attr_key)
	if(val == null):
		return default
	return val

func step(_delta : float):
	for resource_key in base_resource_gains.keys():
		ResourceManager.change_resource_quantity(resource_key, base_resource_gains[resource_key] * _delta)

func get_passive_resource_gains() -> Dictionary:
	return base_resource_gains

