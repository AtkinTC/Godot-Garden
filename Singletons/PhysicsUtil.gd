# PhysicsUtil Singleton
# utility functions related to game physics

extends Node

var physics_layers = {}

func _ready() -> void:
	retrieve_physics_layers()

# setup the dictionary of layer names and bit values for easy reference
func retrieve_physics_layers():
	physics_layers = {}
	for i in range(1, 21):
		var layer_name = ProjectSettings.get_setting(str("layer_names/2d_physics/layer_", i))
		if(layer_name == null || !(layer_name is String) || (layer_name as String) == ""):
			layer_name = str("layer_", i)
		physics_layers[layer_name] = i-1

# get the bit (0 to 31) of the layer matching layer_name
# or -1 if no match
func get_physics_layer_bit(layer_name: String) -> int:
	return physics_layers.get(layer_name, -1)

# gets the combined mask value with all provided bit flags enabled
# for bits [a,b ...] returns 2^a + 2^b ...
static func get_physics_layer_mask(bits: Array[int]) -> int:
	var mask: int = 0
	for bit in bits:
		if(bit >= 0):
			mask += pow(2, bit) as int
	return mask

# same as get_physics_layer_mask, but built from provided layer names
func get_physics_layer_mask_from_names(layer_names: Array[String]) -> int:
	var bits : Array[int] = layer_names.map(get_physics_layer_bit)
	return(get_physics_layer_mask(bits))
