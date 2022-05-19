extends PlotComponent
class_name CapacityPlotComponent

var base_capacity: Dictionary
var final_capacity : Dictionary
var level : int

func _init(_coord : Vector2, _object_key : String, _level : int = 0):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	coord = _coord
	object_key = _object_key
	level = _level
	recalculate()

func recalculate():
	var mod_prop := {
		Const.MOD_TARGET_CAT : Const.OBJECT,
		Const.MOD_TARGET_KEY : object_key,
		Const.MOD_TYPE : Const.CAPACITY,
		Const.VALUE_PATH : [Const.SOURCE, Const.CAPACITY],
		Const.LEVEL : level
	}
	
	var source : Dictionary = ObjectsManager.get_object_type_attribute(object_key, Const.SOURCE, {}).duplicate()
	base_capacity = source.get(Const.CAPACITY).get(Const.VALUE)
	var local_modifier = PurchaseUtil.get_local_source_modifier(mod_prop)
	for key in base_capacity:
		base_capacity[key] = base_capacity[key] * local_modifier
		
	final_capacity = PurchaseUtil.get_modifed_supply_values(mod_prop)
	
	for supply_key in final_capacity.keys():
		SupplyManager.set_capacity_source(supply_key, "CapacityPlotComponent::"+str(coord), final_capacity[supply_key])	

func get_base_capacity() -> Dictionary:
	return base_capacity

func get_capacity() -> Dictionary:
	return final_capacity

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in final_capacity.keys():
		SupplyManager.remove_capacity_source(supply_key, str(coord))

func _on_modifiers_updated():
	recalculate()
