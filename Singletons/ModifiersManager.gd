extends Node

signal modifiers_updated()

var modifier_source := {}
var modifier_combined := {}

func initialize():
	recalculate_modifiers()

func recalculate_modifiers():
	modifier_combined = {}
	for source_key in modifier_source.keys():
		var source : Array = modifier_source[source_key]
		for mod in source:
			assert(mod.has(Const.MOD_TARGET_CAT))
			assert(mod.has(Const.MOD_TARGET_KEY))
			assert(mod.has(Const.MODIFIER))
			
			var level : int = mod.get(Const.LEVEL, 1)
			
			var target_cat : String = mod.get(Const.MOD_TARGET_CAT)
			var cat_dict = modifier_combined.get(target_cat, {})
			
			# TARGET_KEY value can contain either one key or an array of keys
			var target_keys : Array
			if(mod.get(Const.MOD_TARGET_KEY) is Array):
				target_keys = mod.get(Const.MOD_TARGET_KEY)
			else:
				target_keys = [mod.get(Const.MOD_TARGET_KEY)]
			
			# apply modifier attributes to all target_keys
			for target_key in target_keys:
				var target_dict = cat_dict.get(target_key, {})
				
				# MODIFIER value can contain either one modifer or an array of modifiers
				var modifiers : Array
				if(mod.get(Const.MODIFIER) is Array):
					modifiers = mod.get(Const.MODIFIER)
				else:
					modifiers = [mod.get(Const.MODIFIER)]
				
				for attr in modifiers:
					var mod_type : String = attr.get(Const.MOD_TYPE)
					var type_dict = target_dict.get(mod_type, {})
					if(attr.get(Const.MOD_COMPOUNDING, false)):
						#multiply compounding values together
						type_dict[Const.MOD_COMPOUNDING] = type_dict.get(Const.MOD_COMPOUNDING, 1.0) * pow(1 + attr.get(Const.MOD_SCALE, 0), level)
					else:
						#add non-compounding values together
						type_dict[Const.MOD_NONCOMPOUNDING] = type_dict.get(Const.MOD_NONCOMPOUNDING, 1.0) + attr.get(Const.MOD_SCALE, 0) * level
					
					type_dict[Const.MOD_SCALE] = type_dict.get(Const.MOD_COMPOUNDING, 1.0) * type_dict.get(Const.MOD_NONCOMPOUNDING, 1.0)
					target_dict[mod_type] = type_dict
				
				cat_dict[target_key] = target_dict
				
			modifier_combined[target_cat] = cat_dict
	modifiers_updated.emit()
	
func set_modifier_source(_key : String, _modifiers: Array):
	modifier_source[_key] = _modifiers
	recalculate_modifiers()

func apply_modifier(unmodified_value : float, properties : Dictionary) -> float:
	assert(properties.has(Const.MOD_TARGET_CAT))
	assert(properties.has(Const.MOD_TARGET_KEY))
	assert(properties.has(Const.MOD_TYPE))
	
	var target_cat : String = properties.get(Const.MOD_TARGET_CAT)
	var target_key : String = properties.get(Const.MOD_TARGET_KEY)
	var mod_type : String = properties.get(Const.MOD_TYPE)
	
	var mod_scale = modifier_combined.get(target_cat, {}).get(target_key, {}).get(mod_type, {}).get(Const.MOD_SCALE, 1.0)
	
	var modified_value = unmodified_value * mod_scale
	
	return modified_value
	
