extends Node

func can_afford(total_cost : Dictionary) -> bool:
	if(total_cost.size() == 0):
		# no total cost
		return true
	
	for key in total_cost.keys():
		var cost = total_cost[key]
		if(!cost || cost <= 0):
			#no cost
			continue
		
		var quantity = SupplyManager.get_supply(key).get_quantity()
		if(!quantity || quantity < cost):
			#insufficient supply
			return false
		
	return true

func spend(total_cost : Dictionary):
	for key in total_cost.keys():
		var cost = total_cost[key]
		var supply : Supply = SupplyManager.get_supply(key)
		supply.change_quantity(-cost)
