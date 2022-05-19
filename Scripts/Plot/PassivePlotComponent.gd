extends PlotComponent
class_name PassivePlotComponent

var base_gains : Dictionary
var level : int

func _init(_coord : Vector2, _object_key : String, _level : int = 1):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	coord = _coord
	object_key = _object_key
	level = _level
	recalculate()

func recalculate():
	# multiply gains values by level
	var source : Dictionary = ObjectsManager.get_object_type_attribute(object_key, Const.SOURCE, {}).duplicate()
	base_gains = source.get(Const.GAIN).get(Const.VALUE)
	for key in base_gains:
		base_gains[key] = base_gains[key] * level
	
	for supply_key in base_gains.keys():
		SupplyManager.set_change_source(supply_key, "PlotComponent::"+str(coord), base_gains[supply_key])

func get_gains() -> Dictionary:
	return base_gains

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in base_gains.keys():
		SupplyManager.remove_change_source(supply_key, str(coord))

func _on_modifiers_updated():
	recalculate()
