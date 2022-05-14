extends Node

signal upgrades_status_updated()
signal selected_upgrade_changed()

var selected_upgrade_key : String

# setup initial state of upgrades
func initialize():
	SignalBus.locked_status_changed.connect(_on_locked_status_changed)
	selected_upgrade_key = ""
	
# get keys of all upgrades that are available for purchase
func get_available_upgrade_keys() -> Array:
	var available_keys = []
	for key in Database.get_keys(Const.UPGRADE):
		if(PurchaseUtil.is_purchasable(Const.UPGRADE, key)
		&& !is_disabled(key)
		&& !LockUtil.is_locked(Const.UPGRADE, key)):
			available_keys.append(key)
	return available_keys

func refresh_upgrades():
	upgrades_status_updated.emit()

func get_upgrade_type(upgrade_key : String) -> Dictionary:
	return Database.get_entry(Const.UPGRADE, upgrade_key)

func get_upgrade_type_attribute(upgrade_key : String, attribute_key : String, default = null):
	return Database.get_entry_attr(Const.UPGRADE, upgrade_key, attribute_key, default)

func set_selected_upgrade_key(upgrade_key : String):
	selected_upgrade_key = upgrade_key
	selected_upgrade_changed.emit()

func get_selected_upgrade_key() -> String:
	return selected_upgrade_key

# purchase an upgrade, spending the required resources and then applying it
func purchase_upgrade(key : String) -> bool:
	set_selected_upgrade_key(key)
	
	if(!PurchaseUtil.make_purchase(Const.UPGRADE, key)):
		return false
		
	apply_upgrade(key)
	return true

func disable_upgrade(key : String):
	Database.set_entry_attr(Const.UPGRADE, key, Const.DISABLED, true)
	refresh_upgrades()

# apply the selected upgrade
func apply_upgrade(key : String):
	var level = Database.get_entry_attr(Const.UPGRADE, key, Const.LEVEL, 0)
	Database.set_entry_attr(Const.UPGRADE, key, Const.LEVEL, level + 1)
	
	var upgrade_type : Dictionary = Database.get_entry(Const.UPGRADE, key)
	
	#apply upgrade unlocks
	if(upgrade_type.has(Const.UNLOCK)):
		for unlock in upgrade_type[Const.UNLOCK]:
			LockUtil.set_locked(unlock[Const.UNLOCK_TYPE], unlock[Const.UNLOCK_KEY], false)
	
	#setup upgrade supply source attributes (gain and capacity values)
	if(upgrade_type.has(Const.SOURCE)):
		var source : Dictionary = upgrade_type[Const.SOURCE]
		if(source.has(Const.GAIN)):
			var gain = source.get(Const.GAIN)
			for supply_key in gain.keys():
				SupplyManager.get_supply(supply_key).set_gain_source(str(key), gain[supply_key] * upgrade_type[Const.LEVEL])
		if(source.has(Const.CAPACITY)):
			var capacity = source.get(Const.CAPACITY)
			for supply_key in capacity.keys():
				SupplyManager.get_supply(supply_key).set_capacity_source(str(key), capacity[supply_key] * upgrade_type[Const.LEVEL])
	
	#setup upgrade modifier values
	if(upgrade_type.has(Const.MODIFIER)):
		var modifiers : Array = upgrade_type[Const.MODIFIER]
		for mod in modifiers:
			mod[Const.LEVEL] = upgrade_type[Const.LEVEL]
		ModifiersManager.set_modifier_source(key, modifiers)
	
	adjust_upgrade_count(key, 1)
	
	refresh_upgrades()

func set_upgrade_count(key : String, count : int):
	Database.set_entry_attr(Const.UPGRADE, key, Const.COUNT, count)
	refresh_upgrades()

func adjust_upgrade_count(key : String, adj : int):
	var count : int = Database.get_entry_attr(Const.UPGRADE, key, Const.COUNT, 0)
	set_upgrade_count(key, count + adj)

func is_disabled(key : String) -> bool:
	return Database.get_entry_attr(Const.UPGRADE, key, Const.DISABLED, false)

func _on_locked_status_changed(category : String, key : String):
	if(category == Const.UPGRADE):
		refresh_upgrades()
