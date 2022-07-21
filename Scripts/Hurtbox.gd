class_name Hurtbox
extends Area2D

signal took_hit(source, hit_data)

@export var hurtbox_id: String = "hurtbox"

func connect_hit(hit_func : Callable):
	took_hit.connect(hit_func)

func take_hit(source: Node2D, hit_data: Dictionary = {}):
	took_hit.emit(source, hit_data)
