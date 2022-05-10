extends ItemList
class_name UpgradeMenu

var upgrade_list_indexes := {}

func _ready():
	UpgradeManager.upgrades_status_updated.connect(_on_upgrades_updated)
	reset_menu()
	
func reset_menu():
	clear()
	deselect_all()
	
	upgrade_list_indexes = {}
	var index := 0
	for key in UpgradeManager.get_available_upgrade_keys():
		var upgrade_type : Dictionary = UpgradeManager.get_upgrade_type(key)
		var display_name = str(upgrade_type[Const.DISPLAY_NAME])
		if(upgrade_type[Const.LEVEL] > 0):
			display_name += " Lv." + str(upgrade_type[Const.LEVEL]+1)
		add_item(display_name)
		upgrade_list_indexes[index] = key
		
		index += 1

func _on_upgrade_menu_item_selected(index):
	UpgradeManager.purchase_upgrade(upgrade_list_indexes[index])

# rebuild the menu content whenever overall update status changes
func _on_upgrades_updated():
	reset_menu()
