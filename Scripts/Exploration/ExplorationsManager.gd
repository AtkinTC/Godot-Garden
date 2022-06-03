extends Node

signal explorations_changed()

var exps_dict : Dictionary = {}
var next_exp_id : int = 0

func initialize() -> void:
	exps_dict = {}
	next_exp_id = 0

func get_exp_ids() -> Array:
	return exps_dict.keys()

func get_exp_by_id(exp_id : int) -> ExplorationVO:
	return exps_dict.get(exp_id)

func create_empty_exp() -> ExplorationVO:
	var new_exp_id = next_exp_id
	next_exp_id += 1
	
	var new_exp = ExplorationVO.new()
	new_exp.set_exp_id(new_exp_id)

	exps_dict[new_exp_id] = new_exp
	new_exp.changed.connect(_on_exp_changed.bind(new_exp_id))
	
	return new_exp

func _on_exp_changed(exp_id : int):
	if(exps_dict.has(exp_id)):
		explorations_changed.emit()
