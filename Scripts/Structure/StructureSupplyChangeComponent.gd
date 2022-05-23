extends StructureComponenet
class_name StructureSupplySourceComponent

var base_gains : Dictionary
var final_gains : Dictionary
var level : int

func _init(_world_coord : Vector2, _structure_key : String, _source_key : String, _level : int = 0):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	world_coord = _world_coord
	structure_key = _structure_key
	level = _level
	recalculate()

func recalculate():
	var mod_prop := {
		Const.MOD_TARGET_CAT : Const.OBJECT,
		Const.MOD_TARGET_KEY : structure_key,
		Const.MOD_TYPE : Const.GAIN,
		Const.VALUE_PATH : [Const.SOURCE, Const.GAIN],
		Const.LEVEL : level
	}
	
	var source : Dictionary = StructuresManager.get_structe_type_attribute(structure_key, Const.SOURCE, {}).duplicate()
	base_gains = source.get(Const.GAIN).get(Const.VALUE)
	var local_modifier = PurchaseUtil.get_local_source_modifier(mod_prop)
	for key in base_gains:
		base_gains[key] = base_gains[key] * local_modifier
	
	final_gains = PurchaseUtil.get_modifed_supply_values(mod_prop)
	
	for supply_key in final_gains.keys():
		SupplyManager.set_change_source(supply_key, "StructureSupplyChangeComponent::"+str(world_coord), final_gains[supply_key])

func get_base_gains() -> Dictionary:
	return base_gains

func get_gains() -> Dictionary:
	return final_gains

# perform needed cleanup, to be called before this component would be deleted
func cleanup_before_delete():
	for supply_key in final_gains.keys():
		SupplyManager.remove_change_source(supply_key, str(world_coord))

func _on_modifiers_updated():
	recalculate()
