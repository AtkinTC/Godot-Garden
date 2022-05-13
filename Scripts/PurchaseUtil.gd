class_name PurchaseUtil

static func has_purchase_data(category : String, key : String) -> bool:
	return Database.get_entry_attr(category, key, Const.PURCHASE, null) != null

static func get_purchase_data(category : String, key : String) -> Dictionary:
	return Database.get_entry_attr(category, key, Const.PURCHASE, {})

static func get_purchase_limit(key : String, category : String) -> int:
	return get_purchase_data(category, key).get(Const.PURCHASE_LIMIT, -1)

static func get_purchase_price(key : String, category : String) -> Dictionary:
	return get_purchase_data(category, key).get(Const.PRICE, {})

static func is_purchasable(category : String, key : String):
	if(!has_purchase_data(category, key)):
		return false
	var purchase : Dictionary = get_purchase_data(category, key)
	if(purchase.get(Const.PURCHASE_LIMIT, -1) == 0):
		return false
	elif(purchase.get(Const.PURCHASE_LIMIT, -1) == -1):
		return true
	elif(purchase.get(Const.PURCHASE_LIMIT, -1) > Database.get_entry_attr(category, key, Const.COUNT, 0)):
		return true
	return false

static func can_afford_purchase(category : String, key : String, cost_modifier : float = 1.0) -> bool:
	var base_cost = get_purchase_data(category, key).get(Const.PRICE)
	if(base_cost.size() == 0):
		return true
	
	for supply_key in base_cost.keys():
		var cost = base_cost[supply_key]
		if(!cost || cost <= 0):
			#no cost
			continue
		
		var quantity = SupplyManager.get_supply(supply_key).get_quantity()
		if(!quantity || quantity < (cost*cost_modifier)):
			#insufficient supply
			return false
		
	return true

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
