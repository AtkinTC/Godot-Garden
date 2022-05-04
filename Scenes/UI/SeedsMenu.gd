extends ItemList
class_name SeedsMenu

var plant_list_indexes := {}

func _ready():
	clear()
	
	var index := 0
	for plant_key in PlantManager.get_plant_type_keys():
		var plant_type : Dictionary = PlantManager.get_plant_type(plant_key)
		add_item(str(plant_type[PlantManager.DISPLAY_NAME]) + " : " + str(plant_type[PlantManager.PURCHASE_PRICE].get("MONEY")))
		plant_list_indexes[index] = plant_key
		
		if(index == 0):
			PlantManager.set_selected_plant_key(plant_key)
			select(0)
		
		index += 1

func _on_seeds_menu_item_selected(index):
	PlantManager.set_selected_plant_key(plant_list_indexes[index])
