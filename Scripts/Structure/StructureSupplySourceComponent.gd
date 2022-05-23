extends StructureComponenet
class_name StructureSupplySourceComponent

var source_key : String
var base_values : Dictionary
var final_values : Dictionary
var level : int

func _init(_world_coord : Vector2, _structure_key : String, _source_key : String, _level : int = 0):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	world_coord = _world_coord
	structure_key = _structure_key
	source_key = _source_key
	level = _level
	recalculate()

func recalculate():
	cleanup_before_delete()
	
	var mod_prop := {
		Const.MOD_TARGET_CAT : Const.OBJECT,
		Const.MOD_TARGET_KEY : structure_key,
		Const.MOD_TYPE : source_key,
		Const.VALUE_PATH : [Const.SOURCE, source_key],
		Const.LEVEL : level
	}
	
	var source : Dictionary = StructuresManager.get_structure_type_attribute(structure_key, Const.SOURCE, {}).duplicate()
	base_values = source.get(source_key).get(Const.VALUE)
	var local_modifier = PurchaseUtil.get_local_source_modifier(mod_prop)
	for key in base_values:
		base_values[key] = base_values[key] * local_modifier
	
	final_values = PurchaseUtil.get_modifed_supply_values(mod_prop)
	
	for supply_key in final_values.keys():
		SupplyManager.set_source(source_key, supply_key, "StructureSupplySourceComponent::"+str(world_coord), final_values[supply_key])

func get_base_values() -> Dictionary:
	return base_values

func get_values() -> Dictionary:
	return final_values

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in final_values.keys():
		SupplyManager.remove_source(source_key, supply_key, str(world_coord))

func _on_modifiers_updated():
	recalculate()
