class_name DataValidator

const object_valid_keys := [Const.DISPLAY_NAME, Const.LOCKED, Const.REMOVABLE, Const.PURCHASE]

enum {OPTIONAL = 1, REQUIRED = 2, DICTIONARY = 4, ARRAY = 8, ARRAY_OF_DICTIONARY = 16}

const templates := {
	Const.ACTION : {
		Const.DISPLAY_NAME : REQUIRED,
		Const.TARGET_TYPE : REQUIRED,
		Const.FUNC_NAME : REQUIRED,
		Const.DISPLAY : OPTIONAL
	},
	Const.OBJECT : {
		Const.DISPLAY_NAME : REQUIRED,
		Const.LOCKED : OPTIONAL,
		Const.DISABLED : OPTIONAL,
		Const.REMOVABLE : OPTIONAL,
		Const.PURCHASE : OPTIONAL + DICTIONARY,
		Const.BUILD : OPTIONAL + DICTIONARY,
		Const.SOURCE : OPTIONAL + DICTIONARY,
		Const.UPGRADE : OPTIONAL + DICTIONARY,
		Const.UNLOCKS  : OPTIONAL + ARRAY_OF_DICTIONARY
	},
	Const.SUPPLY : {
		Const.DISPLAY_NAME : REQUIRED,
		Const.LOCKED : OPTIONAL,
		Const.DISPLAY_COLORS : OPTIONAL
	},
	Const.ENHANCEMENT : {
		Const.DISPLAY_NAME : REQUIRED,
		Const.LOCKED : OPTIONAL,
		Const.DISABLED : OPTIONAL,
		Const.AUTO : OPTIONAL,
		Const.PURCHASE : OPTIONAL + DICTIONARY,
		Const.SOURCE : OPTIONAL + DICTIONARY,
		Const.UNLOCKS : OPTIONAL + ARRAY_OF_DICTIONARY,
		Const.MODIFIERS : OPTIONAL + ARRAY_OF_DICTIONARY
	},
	Const.PURCHASE : {
		Const.PRICE : REQUIRED,
		Const.LIMIT : OPTIONAL,
		Const.PRICE_MODIFIERS : OPTIONAL + ARRAY_OF_DICTIONARY
	},
	Const.BUILD : {
		Const.LENGTH : OPTIONAL
	},
	Const.PRICE_MODIFIERS : {
		Const.PRICE_MODIFIER_TARGET : REQUIRED,
		Const.PRICE_MOD_TYPE : REQUIRED
	},
	Const.SOURCE : {
		Const.GAIN : OPTIONAL,
		Const.CAPACITY : OPTIONAL
	},
	Const.UPGRADE : {
		Const.PRICE : REQUIRED,
		Const.LENGTH : OPTIONAL,
		Const.LIMIT : OPTIONAL,
		Const.PRICE_MODIFIERS : OPTIONAL + ARRAY_OF_DICTIONARY
	},
	Const.UNLOCKS : {
		Const.UNLOCK_KEY : REQUIRED,
		Const.UNLOCK_TYPE : REQUIRED
	},
	Const.MODIFIERS : {
		Const.MOD_TARGET_CAT : REQUIRED,
		Const.MOD_TARGET_KEY : REQUIRED + ARRAY,
		Const.MOD_EFFECT : REQUIRED + ARRAY_OF_DICTIONARY
	},
	Const.MOD_EFFECT : {
		Const.MOD_TYPE : REQUIRED,
		Const.MOD_SCALE : REQUIRED,
		Const.MOD_COMPOUNDING : OPTIONAL
	}
}

static func validate_data_entry(key : String, entry : Dictionary, _sequence : Array = []) -> Dictionary:
	var sequence : Array = _sequence + [key]
	var indent = ""
	for i in sequence.size():
		indent += "\t"
	var errors := 0
	var warnings := 0
	
	var entry_keys := entry.keys()
	var template_entry : Dictionary = templates[key]
	var template_keys := template_entry.keys()
	
	for attr_key in template_keys:
		var attr_flags : int = template_entry[attr_key]
		if(!entry_keys.has(attr_key)):
			#attr not found, handle error if required and then continue to next attribute
			if(attr_flags & REQUIRED):
				print("\tERROR:\t\t%s : %s" % [sequence, "Missing required attribute '%s'" % attr_key])#DEBUG
				errors += 1
			continue
		
		entry_keys.erase(attr_key)
		
		if(attr_flags & DICTIONARY):
			if(entry[attr_key] is Dictionary):
				var stats := validate_data_entry(attr_key, entry[attr_key], sequence)
				errors += stats.get("errors", 0) as int
				warnings += stats.get("warnings", 0) as int
			else:
				print("\tERROR:\t\t%s : %s" % [sequence, "Wrong type for attribute '%s', expected Dictionary" % attr_key])#DEBUG
				errors += 1
				continue
		
		if(attr_flags & ARRAY || attr_flags & ARRAY_OF_DICTIONARY):
			if(!(entry[attr_key] is Array)):
				print("\tERROR:\t\t%s : %s" % [sequence, "Wrong type for attribute '%s', expected Array" % attr_key])#DEBUG
				errors += 1
				continue
			elif((entry[attr_key] as Array).size() == 0):
				print("\tWARNING:\t\t%s : %s" % [sequence, "Empty Array for attribute '%s'" % attr_key])#DEBUG
				warnings += 1
		
		if(attr_flags & ARRAY_OF_DICTIONARY):
			for sub_entry in entry[attr_key]:
				var stats := validate_data_entry(attr_key, sub_entry, sequence)
				errors += stats.get("errors", 0) as int
				warnings += stats.get("warnings", 0) as int
	
	for attr_key in entry_keys:
		print("\tWARNING:\t%s : %s" % [sequence, "Contains unexpected attribute '%s'" % attr_key])#DEBUG
		warnings += 1
	
	return {"errors" : errors, "warnings" : warnings}

static func validate_category_data(category : String):
	var category_data : Dictionary = Database.get_category(category)
	print("validate_category_data(%s) @ %s" % [category, Time.get_time_string_from_system()])#DEBUG
	var errors := 0
	var warnings := 0
	
	for entry_key in category_data.keys():
		var stats := validate_data_entry(category, category_data[entry_key], [entry_key])
		errors += stats.get("errors", 0) as int
		warnings += stats.get("warnings", 0) as int
	
	print("\tErrors : %s" % errors)#DEBUG
	print("\tWarnings : %s" % warnings)#DEBUG
