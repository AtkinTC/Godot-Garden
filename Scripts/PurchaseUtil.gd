class_name PurchaseUtil

static func has_purchase_data(category : String, key : String) -> bool:
	return Database.get_entry_attr(category, key, Const.PURCHASE, null) != null

static func get_purchase_data(category : String, key : String) -> Dictionary:
	return Database.get_entry_attr(category, key, Const.PURCHASE, {})

static func get_purchase_limit(key : String, category : String) -> int:
	return get_purchase_data(category, key).get(Const.PURCHASE_LIMIT, -1)

static func get_purchase_price(category : String, key : String) -> Dictionary:
	return get_purchase_data(category, key).get(Const.PRICE, {})

static func is_purchasable(category : String, key : String):
	if(!has_purchase_data(category, key)):
		return false
	return has_available_purchase_limit(category, key)

# has_available_purchase_limit(category : String, key : String)
#	checks if the target is valid for purchase based on the targets purchase limit and current count
static func has_available_purchase_limit(category : String, key : String) -> bool:
	var purchase : Dictionary = PurchaseUtil.get_purchase_data(category, key)
	if(purchase.get(Const.PURCHASE_LIMIT, -1) == 0):
		return false
	elif(purchase.get(Const.PURCHASE_LIMIT, -1) == -1):
		return true
	return purchase.get(Const.PURCHASE_LIMIT, -1) > Database.get_entry_attr(category, key, Const.COUNT, 0)

# make_purchase(category : String, key : String, _props : Dictionary = {})
#	subtracts the calculated purchase cost (spend) from applicable supplies
#	only subtracts the cost if can afford the full cost
static func make_purchase(category : String, key : String, _props : Dictionary = {}) -> bool:
	if(!is_purchasable(category, key)):
		return false
	
	var total_price = get_modified_purchase_price(category, key, _props)
	if(!can_afford_purchase_internal(total_price)):
		return false
	
	for supply_key in total_price.keys():
		var price = total_price[supply_key]
		var supply : Supply = SupplyManager.get_supply(supply_key)
		supply.change_quantity(-price)
	
	return true

# can_afford_purchase(category : String, key : String, _props : Dictionary = {})
static func can_afford_purchase(category : String, key : String, _props : Dictionary = {}) -> bool:
	var total_price = get_modified_purchase_price(category, key, _props)
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

# gets the purchase price for an item, with all relevent modifiers applied
static func get_modified_purchase_price(category : String, key : String, _props : Dictionary = {}):
	print("get_modified_purchase_price(%s, %s) @ %s" % [str(category), str(key), Time.get_time_string_from_system()])#DEBUG
	var props = {
		Const.MOD_TARGET_CAT : _props.get(Const.MOD_TARGET_CAT, category),
		Const.MOD_TARGET_KEY : _props.get(Const.MOD_TARGET_KEY, key),
		Const.MOD_TYPE : _props.get(Const.MOD_TYPE, Const.PRICE),
		Const.COUNT : _props.get(Const.COUNT, Database.get_entry_attr(category, key, Const.COUNT, 0)),
		Const.LEVEL : _props.get(Const.LEVEL, Database.get_entry_attr(category, key, Const.LEVEL, 0))
	}
	
	var global_mod : float = ModifiersManager.apply_modifier(1.0, props)
	var local_mod : float = get_local_price_modifier(category, key, props)
	print("\tglobal_mod: %s" % str(global_mod))#DEBUG
	print("\tlocal_mod: %s" % str(local_mod))#DEBUG
	
	var base_price = get_purchase_price(category, key)
	var modified_price = {}
	for supply_key in base_price.keys():
		var supply_price = base_price.get(supply_key, 0.0)
		
		var supply_prop := {
			Const.MOD_TARGET_CAT : Const.SUPPLY,
			Const.MOD_TARGET_KEY : supply_key,
			Const.MOD_TYPE : Const.PRICE
		}
		var supply_mod = ModifiersManager.apply_modifier(1.0, supply_prop)
		modified_price[supply_key] = supply_price * supply_mod * local_mod * global_mod
		print("\t\tsupply_key: %s" % str(supply_key))#DEBUG
		print("\t\tsupply_mod: %s" % str(supply_mod))#DEBUG
		print("\t\tmodified_price: %s" % str(modified_price[supply_key]))#DEBUG
		
	return modified_price
	

# calculate the price modifier based on the local PURCHASE[PRICE_MODIFIER] entry
static func get_local_price_modifier(category : String, key : String, props : Dictionary):
	var purchase = get_purchase_data(category, key)
	if(!purchase.has(Const.PRICE_MODIFIER)):
		return 1.0
	var modifier_data = purchase.get(Const.PRICE_MODIFIER)
	
	var modifiers : Array
	if(modifier_data is Dictionary):
		modifiers = [modifier_data]
	elif(modifier_data is Array):
		modifiers = modifier_data
	
	if(modifiers == null || modifiers.size() == 0):
		return 1.0
	
	var price_modifier := 1.0
	for modifier in modifiers:
		if(!modifier.has(Const.PRICE_MODIFIER_TARGET) || !modifier.has(Const.PRICE_MOD_TYPE)):
			print("get_price_modifier() : malformed price modifier dictionary")#DEBUG
			continue
		var target_scale = 0.0
		var target : String = modifier.get(Const.PRICE_MODIFIER_TARGET)
		if(props.has(target)):
			target_scale = props.get(target)
		
		var type : String = modifier.get(Const.PRICE_MOD_TYPE)
		if(type == Const.TYPE_LIN):
			price_modifier *= (target_scale + 1)
		#TODO: add logic for other modifier types
	
	print("get_price_modifier() -> " + str(price_modifier))#DEBUG
	return price_modifier

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
		var supply : Supply = SupplyManager.get_supply(key)
		supply.change_quantity(-cost * cost_modifier)
