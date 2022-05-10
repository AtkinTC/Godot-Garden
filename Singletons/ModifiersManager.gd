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
			assert(mod.has(Const.MODIFIER_TARGET_CATEGORY))
			assert(mod.has(Const.MODIFIER_TARGET_KEY) || mod.has(Const.MODIFIER_TARGET_KEYS))
			assert(mod.has(Const.MODIFIER_TYPE) || mod.has(Const.MODIFIER))
			
			var level : int = mod.get(Const.LEVEL, 1)
			
			var target_cat : String = mod.get(Const.MODIFIER_TARGET_CATEGORY)
			var cat_dict = modifier_combined.get(target_cat, {})
			
			var target_keys := []
			if(mod.has(Const.MODIFIER_TARGET_KEY)):
				target_keys.append(mod.get(Const.MODIFIER_TARGET_KEY))
			elif(mod.has(Const.MODIFIER_TARGET_KEYS)):
				target_keys = mod.get(Const.MODIFIER_TARGET_KEYS)
			
			# apply modifier attributes to all target_keys
			for target_key in target_keys:
				var target_dict = cat_dict.get(target_key, {})
				
				# modify single attribute
				if(mod.has(Const.MODIFIER_TYPE)):
					var mod_type : String = mod.get(Const.MODIFIER_TYPE)
					var type_dict = target_dict.get(mod_type, {})
					type_dict[Const.MODIFIER_SCALE] = type_dict.get(Const.MODIFIER_SCALE, 1.0) + mod.get(Const.MODIFIER_SCALE, 0) * level
					target_dict[mod_type] = type_dict
				
				# modify multiple attributes
				if(mod.has(Const.MODIFIER)):
					for attr in mod.get(Const.MODIFIER):
						var mod_type : String = attr.get(Const.MODIFIER_TYPE)
						var type_dict = target_dict.get(mod_type, {})
						type_dict[Const.MODIFIER_SCALE] = type_dict.get(Const.MODIFIER_SCALE, 1.0) + attr.get(Const.MODIFIER_SCALE, 0) * level
						target_dict[mod_type] = type_dict
				
				cat_dict[target_key] = target_dict
				
			modifier_combined[target_cat] = cat_dict
	modifiers_updated.emit()
	
func set_modifier_source(_key : String, _modifiers: Array):
	modifier_source[_key] = _modifiers
	recalculate_modifiers()

func apply_modifier(unmodified_value : float, properties : Dictionary) -> float:
	assert(properties.has(Const.MODIFIER_TARGET_CATEGORY))
	assert(properties.has(Const.MODIFIER_TARGET_KEY))
	assert(properties.has(Const.MODIFIER_TYPE))
	
	var target_cat : String = properties.get(Const.MODIFIER_TARGET_CATEGORY)
	var target_key : String = properties.get(Const.MODIFIER_TARGET_KEY)
	var mod_type : String = properties.get(Const.MODIFIER_TYPE)
	
	var mod_scale = modifier_combined.get(target_cat, {}).get(target_key, {}).get(mod_type, {}).get(Const.MODIFIER_SCALE, 1.0)
	
	var modified_value = unmodified_value * mod_scale
	
	return modified_value
	
