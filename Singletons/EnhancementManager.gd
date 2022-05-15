extends Node

signal enhancements_status_updated()
signal selected_enhancement_changed()

var selected_enhancement_key : String

# setup initial state of enhancements
func initialize():
	SignalBus.locked_status_changed.connect(_on_locked_status_changed)
	selected_enhancement_key = ""
	
# get keys of all enhancements that are available for purchase
func get_available_enhancement_keys() -> Array:
	var available_keys = []
	for key in Database.get_keys(Const.ENHANCEMENT):
		if(PurchaseUtil.is_purchasable(Const.ENHANCEMENT, key)
		&& !is_disabled(key)
		&& !LockUtil.is_locked(Const.ENHANCEMENT, key)):
			available_keys.append(key)
	return available_keys

func refresh_enhancements():
	enhancements_status_updated.emit()

func get_enhancement_type(enhancement_key : String) -> Dictionary:
	return Database.get_entry(Const.ENHANCEMENT, enhancement_key)

func get_enhancement_type_attribute(enhancement_key : String, attribute_key : String, default = null):
	return Database.get_entry_attr(Const.ENHANCEMENT, enhancement_key, attribute_key, default)

func set_selected_enhancement_key(enhancement_key : String):
	selected_enhancement_key = enhancement_key
	selected_enhancement_changed.emit()

func get_selected_enhancement_key() -> String:
	return selected_enhancement_key

# purchase an enhancement, spending the required resources and then applying it
func purchase_enhancement(key : String) -> bool:
	set_selected_enhancement_key(key)
	
	if(!PurchaseUtil.make_purchase(Const.ENHANCEMENT, key)):
		return false
		
	apply_enhancement(key)
	return true

func disable_enhancement(key : String):
	Database.set_entry_attr(Const.ENHANCEMENT, key, Const.DISABLED, true)
	refresh_enhancements()

# apply the selected enhancement
func apply_enhancement(key : String):
	var level = Database.get_entry_attr(Const.ENHANCEMENT, key, Const.LEVEL, 0)
	Database.set_entry_attr(Const.ENHANCEMENT, key, Const.LEVEL, level + 1)
	
	var enhancement_type : Dictionary = Database.get_entry(Const.ENHANCEMENT, key)
	
	#apply enhancement unlocks
	if(enhancement_type.has(Const.UNLOCKS)):
		for unlock in enhancement_type[Const.UNLOCKS]:
			LockUtil.set_locked(unlock[Const.UNLOCK_TYPE], unlock[Const.UNLOCK_KEY], false)
	
	#setup enhancement supply source attributes (gain and capacity values)
	if(enhancement_type.has(Const.SOURCE)):
		var source : Dictionary = enhancement_type[Const.SOURCE]
		if(source.has(Const.GAIN)):
			var gain = source.get(Const.GAIN)
			for supply_key in gain.keys():
				SupplyManager.get_supply(supply_key).set_gain_source(str(key), gain[supply_key] * enhancement_type[Const.LEVEL])
		if(source.has(Const.CAPACITY)):
			var capacity = source.get(Const.CAPACITY)
			for supply_key in capacity.keys():
				SupplyManager.get_supply(supply_key).set_capacity_source(str(key), capacity[supply_key] * enhancement_type[Const.LEVEL])
	
	#setup enhancement modifier values
	if(enhancement_type.has(Const.MODIFIERS)):
		var modifiers : Array = enhancement_type[Const.MODIFIERS]
		for mod in modifiers:
			mod[Const.LEVEL] = enhancement_type[Const.LEVEL]
		ModifiersManager.set_modifier_source(key, modifiers)
	
	adjust_enhancement_count(key, 1)
	
	refresh_enhancements()

func set_enhancement_count(key : String, count : int):
	Database.set_entry_attr(Const.ENHANCEMENT, key, Const.COUNT, count)
	refresh_enhancements()

func adjust_enhancement_count(key : String, adj : int):
	var count : int = Database.get_entry_attr(Const.ENHANCEMENT, key, Const.COUNT, 0)
	set_enhancement_count(key, count + adj)

func is_disabled(key : String) -> bool:
	return Database.get_entry_attr(Const.ENHANCEMENT, key, Const.DISABLED, false)

func _on_locked_status_changed(category : String, key : String):
	if(category == Const.ENHANCEMENT):
		refresh_enhancements()
