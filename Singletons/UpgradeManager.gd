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
		if(!LockUtil.is_locked(Const.UPGRADE, key)
		&& !Database.get_entry_attr(Const.UPGRADE, key, Const.DISABLED, false)):
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
	var price_multiplier := 1.0
	
	set_selected_upgrade_key(key)
	
	if(Database.get_entry_attr(Const.UPGRADE, key, Const.LEVEL, 0) > 0):
		# rebuying a multi-level upgrade
		if(Database.get_entry_attr(Const.UPGRADE, key, Const.REBUY, null) == null):
			return false
		var rebuy : Dictionary = Database.get_entry_attr(Const.Upgrade, key, Const.REBUY, {})
		var price_modifier_type : String = rebuy[Const.PRICE_MODIFIER_TYPE]
		if(price_modifier_type == Const.PRICE_MODIFIER_FLAT_LEVEL):
			price_multiplier = Database.get_entry_attr(Const.UPGRADE, key, Const.LEVEL, 0) + 1
	
	if(!PurchaseUtil.can_afford_purchase(Const.UPGRADE, key, price_multiplier)):
		return false
	
	var purchase_cost : Dictionary = Database.get_entry_attr(Const.UPGRADE, key, Const.PURCHASE_COST, {})
	PurchaseUtil.spend(purchase_cost, price_multiplier)
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
	
	if(Database.get_entry_attr(Const.UPGRADE, key, Const.REBUY, null) == null):
		disable_upgrade(key)
	else:
		refresh_upgrades()

func _on_locked_status_changed(category : String, key : String):
	if(category == Const.UPGRADE):
		refresh_upgrades()
