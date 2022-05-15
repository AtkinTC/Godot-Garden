class_name Supply

signal supply_quantity_changed(key : String, new_quantity : float)
signal supply_capacity_changed(key : String, new_capacity : float)
signal supply_gain_changed(key : String, new_gain : float)

var key : String

var display_name : String
var quantity : float
var base_capacity : float
var display_colors : Array

var locked : bool

var capacity_sources : Dictionary
var gain_sources : Dictionary

var needs_recalculate : bool = true

var final_capacity : float
var final_gain : float

func _init(_key : String, _supply_def : Dictionary):
	ModifiersManager.modifiers_updated.connect(_on_modifiers_updated)
	key = _key
	display_name = _supply_def.get(Const.DISPLAY_NAME, key)
	quantity = _supply_def.get(Const.QUANTITY_BASE, 0.00)
	base_capacity = _supply_def.get(Const.CAPACITY_BASE, 0.00)
	display_colors = _supply_def.get(Const.DISPLAY_COLORS, [])
	locked = _supply_def.get(Const.LOCKED, false)
	capacity_sources = {}
	gain_sources = {}

func step(_delta : float):
	recalculate()
	change_quantity(get_gain() * _delta)

# trigger recalculation of all supply attributes if needs_recalculate flag has been set
func recalculate():
	if(!needs_recalculate):
		return
	
	recalculate_gain()
	recalculate_capacity()
	
	needs_recalculate = false

# recalculates supply capacity value from all gain sources and applies any modifiers
# emits supply_capacity_changed signal if a change has been made
func recalculate_capacity():
	if(base_capacity < 0):
		return -1.0
	
	var old_capacity := final_capacity
	
	var unmodified_capacity := base_capacity
	for capacity in capacity_sources.values():
		unmodified_capacity += capacity
	
	var mod_prop := {
		Const.MOD_TARGET_CAT : Const.SUPPLY,
		Const.MOD_TARGET_KEY : key,
		Const.MOD_TYPE : Const.CAPACITY
	}
	
	final_capacity = unmodified_capacity * ModifiersManager.get_modifier_scale(mod_prop)
	
	if(final_capacity != old_capacity):
		supply_capacity_changed.emit(key, final_capacity)

# recalculates supply gain value from all gain sources and applies any modifiers
# emits supply_gain_changed signal if a change has been made
func recalculate_gain():
	var old_gain := final_gain
	
	var unmodified_gain := 0.0
	for gain in gain_sources.values():
		unmodified_gain += gain
	
	var mod_prop := {
		Const.MOD_TARGET_CAT : Const.SUPPLY,
		Const.MOD_TARGET_KEY : key,
		Const.MOD_TYPE : Const.GAIN
	}
	
	final_gain = unmodified_gain * ModifiersManager.get_modifier_scale(mod_prop)
	
	if(final_gain != old_gain):
		supply_gain_changed.emit(key, final_gain)

func change_quantity(_change: float):
	set_quantity(quantity + _change)

# set supply quantity value limited by capacity
#	emit supply_quantity_changed signal if the quantity has changed
func set_quantity(_quantity: float):
	if(_quantity != quantity):
		var new_quantity : float = _quantity
		if(get_capacity() >= 0):
			new_quantity = min(new_quantity, get_capacity())
		
		if(new_quantity != quantity):
			quantity = new_quantity
			supply_quantity_changed.emit(key, new_quantity)

# set a supply capacity source, inserting or overwriting if the source already exists
#	sets needs_recalculate flag
func set_capacity_source(_id : String, _capacity : float):
	if(capacity_sources.get(_id) == _capacity):
		return false
	capacity_sources[_id] = _capacity
	needs_recalculate = true

# remove supply capacity source
#	sets needs_recalculate flag
func remove_capacity_source(_id : String):
	if(!capacity_sources.has(_id)):
		return
	capacity_sources.erase(_id)
	needs_recalculate = true

# set a supply gain source, inserting or overwriting if the source already exists
#	sets needs_recalculate flag
func set_gain_source(_id : String, _gain : float):
	if(gain_sources.get(_id) == _gain):
		return false
	gain_sources[_id] = _gain
	needs_recalculate = true

# remove supply gain source
#	sets needs_recalculate flag
func remove_gain_source(_id : String):
	if(!gain_sources.has(_id)):
		return
	gain_sources.erase(_id)
	needs_recalculate = true

func _on_modifiers_updated():
	needs_recalculate = true

func get_display_name() -> String:
	return display_name

func get_capacity() -> float:
	return final_capacity

func get_gain() -> float:
	return final_gain

func get_quantity() -> float:
	return quantity

func get_display_colors() -> Array:
	return display_colors

func get_display_color(index : int, default = null):
	if(index >= display_colors.size()):
		return default
	return display_colors[index]

func is_locked() -> bool:
	return locked

func set_locked(_locked : bool):
	locked = _locked
