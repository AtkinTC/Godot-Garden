class_name SmartSupplyDisplay
extends SupplyDisplay

var supply_key: String

func _ready():
	ready()

func ready():
	needs_update = true
	SupplyManager.supply_updated.connect(_on_supply_updated)
	pull_values()
	update_display()

func _process(_delta):
	pull_values()
	update_display()

func pull_values():
	if(!needs_update):
		return
	needs_update = false
	
	var supply : SupplyVO
	if(supply_key == null || supply_key == ""):
		supply = SupplyVO.new()
	else:
		supply = SupplyManager.get_supply(supply_key)
	
	set_display_name(supply.get_display_name())
	set_quantity(supply.get_quantity())
	set_capacity(supply.get_capacity())
	set_change(supply.get_change())
	set_display_colors(supply.get_display_colors())

func set_supply_key(_supply_key):
	if(supply_key != _supply_key):
		supply_key = _supply_key
		needs_update = true

func _on_supply_updated(_supply_key : String):
	if(supply_key == _supply_key):
		needs_update = true
