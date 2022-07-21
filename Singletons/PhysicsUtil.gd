extends Node

var physics_layers = {}

func get_physics_layer_bit(layer_name: String) -> int:
	return physics_layers.get(layer_name, -1)

func get_physics_layer_mask(bits: Array) -> int:
	var mask: int = 0
	for bit in bits:
		mask += pow(2, bit) as int
	return mask

func _ready() -> void:
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/2d_physics/layer_", i))
		if(layer_name == null || !(layer_name is String) || (layer_name as String) == ""):
			layer_name = str("layer_", i)
		physics_layers[layer_name] = i-1
	pass
