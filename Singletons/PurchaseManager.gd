extends Node

func can_afford(total_cost : Dictionary) -> bool:
	if(total_cost.size() == 0):
		# no total cost
		return true
	
	for resource_key in total_cost.keys():
		var res_cost = total_cost[resource_key]
		if(!res_cost || res_cost <= 0):
			#no resource cost
			continue
		
		var res_amount = ResourceManager.get_resource_attribute(resource_key, ResourceManager.AMOUNT)
		if(!res_amount || res_amount < res_cost):
			#insufficient resource
			return false
		
	return true

func spend(total_cost : Dictionary):
	for resource_key in total_cost.keys():
		var res_cost = total_cost[resource_key]
		var res_amount = ResourceManager.get_resource_attribute(resource_key, ResourceManager.AMOUNT)
		ResourceManager.set_resource_attribute(resource_key, ResourceManager.AMOUNT, res_amount - res_cost)
