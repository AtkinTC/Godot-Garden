class_name PurchaseUtil

static func is_purchasable(props : Dictionary = {}) -> bool:
	var source_category = props.get(Const.MOD_TARGET_CAT)
	var source_key = props.get(Const.MOD_TARGET_KEY)
	var purchase_type = props.get(Const.MOD_TYPE)
	if(Database.get_entry_attr(source_category, source_key, purchase_type, null) == null):
		return false
	var limit : int = Database.get_entry_attr(source_category, source_key, purchase_type, {}).get(Const.LIMIT, -1)
	if(limit == 0):
		return false
	if(limit == -1):
		return true
	return limit > Database.get_entry_attr(source_category, source_key, Const.COUNT, 0)

# make_purchase(props : Dictionary)
#	subtracts the calculated purchase cost (spend) from applicable supplies
#	only subtracts the cost if can afford the full cost
static func make_purchase(props : Dictionary) -> bool:
	assert(props.get(Const.MOD_TARGET_CAT))
	assert(props.get(Const.MOD_TARGET_KEY))
	assert(props.get(Const.MOD_TYPE))

	if(!is_purchasable(props)):
		return false
	
	var total_price = get_modifed_supply_values(props)
	if(!can_afford_purchase_internal(total_price)):
		return false
	
	for supply_key in total_price.keys():
		var price = total_price[supply_key]
		SupplyManager.change_supply_quantity(supply_key, -price)
	return true

static func can_afford_purchase(props : Dictionary) -> bool:
	assert(props.get(Const.MOD_TARGET_CAT))
	assert(props.get(Const.MOD_TARGET_KEY))
	assert(props.get(Const.MOD_TYPE))
	
	var total_price = get_modifed_supply_values(props)
	return can_afford_purchase_internal(total_price)

static func can_afford_purchase_internal(total_price : Dictionary) -> bool:
	if(total_price.size() == 0):
		return true
	for supply_key in total_price.keys():
		var price = total_price[supply_key]
		if(!price || price <= 0):
			#no cost
			continue
		
		var quantity = SupplyManager.get_supply(supply_key).get_quantity()
		if(!quantity || quantity < (price)):
			#insufficient supply
			return false
	return true

# applies all relevent modifiers to a supply value object (dictionary of supply keys and quantities)
static func get_modifed_supply_values(props : Dictionary):
	var source_category = props.get(Const.MOD_TARGET_CAT)
	var source_key = props.get(Const.MOD_TARGET_KEY)
	var value_type = props.get(Const.MOD_TYPE)
	
	var attr : Dictionary
	if(props.has(Const.VALUE_PATH)):
		attr = Database.get_entry(source_category, source_key)
		for key in props.get(Const.VALUE_PATH):
			attr = attr.get(key, {})
	else:
		attr = Database.get_entry_attr(source_category, source_key, value_type, {})
			
	var base_value = attr.get(Const.VALUE, {})
	return modify_supply_values(base_value, props)

# applies all relevent modifiers to a supply value object (dictionary of supply keys and quantities)
# 	Global Mods : global value modifiers that affect the defined MOD_TARGET and MOD_TYPE
#	Local Mods : local modifiers defined inside source[LOCAL_MODIFIERS] data
#	Supply Mods : global value modifiers that affect a specific Supply type making up part of the supply value
static func modify_supply_values(supply_value : Dictionary, props : Dictionary):
	assert(props.get(Const.MOD_TARGET_CAT))
	assert(props.get(Const.MOD_TARGET_KEY))
	assert(props.get(Const.MOD_TYPE))
	
	var debug_props = [props.get(Const.MOD_TARGET_CAT, ""), props.get(Const.MOD_TARGET_KEY, ""), Time.get_time_string_from_system()]#DEBUG
	print("get_modifed_supply_values(%s, %s) @ %s" % debug_props)#DEBUG
	
	var source_global_mod : float = ModifiersManager.get_modifier_scale(props)
	var source_local_mod : float = get_local_source_modifier(props)
	
	if(source_global_mod != 1.0):
		print("\tglobal_mod: %s" % str(source_global_mod))#DEBUG
	if(source_local_mod != 1.0):
		print("\tlocal_mod: %s" % str(source_local_mod))#DEBUG
	
	var modified_supply_value = {}
	for supply_key in supply_value.keys():
		var supply_quantity = supply_value.get(supply_key, 0.0)
		
		var supply_prop := {
			Const.MOD_TARGET_CAT : Const.SUPPLY,
			Const.MOD_TARGET_KEY : supply_key,
			Const.MOD_TYPE : props.get(Const.MOD_TYPE)
		}
		var supply_mod = ModifiersManager.get_modifier_scale(supply_prop)
		modified_supply_value[supply_key] = supply_quantity * supply_mod * source_local_mod * source_global_mod
		if(supply_mod != 1.0):
			print("\t\tsupply_key: %s, supply_mod: %s" % [str(supply_key), str(supply_mod)])#DEBUG
		
	return modified_supply_value

# calculate the local modifier based on the local SOURCE[LOCAL_MODIFIERS] entry
static func get_local_source_modifier(props : Dictionary):
	assert(props.get(Const.MOD_TARGET_CAT))
	assert(props.get(Const.MOD_TARGET_KEY))
	assert(props.get(Const.MOD_TYPE))
	
	var source_category = props.get(Const.MOD_TARGET_CAT, "")
	var source_key = props.get(Const.MOD_TARGET_KEY, "")
	var source_type = props.get(Const.MOD_TYPE, "")
	var modifiers : Array = Database.get_entry_attr(source_category, source_key, source_type, {}).get(Const.LOCAL_MODIFIERS, [])
	
	if(modifiers == null || modifiers.size() == 0):
		return 1.0
	
	var mod_applied : bool = false
	var local_mod_scale := 1.0
	for modifier in modifiers:
		if(!modifier.has(Const.LOCAL_MOD_TARGET) || !modifier.has(Const.LOCAL_MOD_TYPE)):
			print("get_local_source_modifier() : malformed local modifier dictionary")#DEBUG
			continue
		var target_scale = 0.0
		var target : String = modifier.get(Const.LOCAL_MOD_TARGET)
		if(props.has(target)):
			target_scale = props.get(target)
		
		var type : String = modifier.get(Const.LOCAL_MOD_TYPE)
		if(type == Const.TYPE_LIN):
			local_mod_scale *= (target_scale + 1)
			mod_applied = true
		#TODO: add logic for other modifier types
	
	if(mod_applied):
		print("get_local_source_modifier(%s, %s) : %s @ %s" % [source_category, source_key, local_mod_scale, Time.get_time_string_from_system()])#DEBUG
	return local_mod_scale

static func can_afford(total_cost : Dictionary, cost_modifier : float = 1.0) -> bool:
	if(total_cost.size() == 0):
		# no total cost
		return true

	for key in total_cost.keys():
		var cost = total_cost[key]
		if(!cost || cost <= 0):
			#no cost
			continue

		var quantity = SupplyManager.get_supply(key).get_quantity()
		if(!quantity || quantity < (cost*cost_modifier)):
			#insufficient supply
			return false

	return true

static func spend(total_cost : Dictionary, cost_modifier : float = 1.0):
	for key in total_cost.keys():
		var cost = total_cost[key]
		SupplyManager.change_quantity(key, -cost * cost_modifier)
