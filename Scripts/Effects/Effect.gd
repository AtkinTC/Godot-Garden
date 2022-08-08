# Effect extends Node2D
#	simple base class for all effects to extend

class_name Effect
extends Node2D

var attribute_dict: Dictionary

func setup_from_attribute_dictionary(_attribute_dict: Dictionary):
	attribute_dict = _attribute_dict
