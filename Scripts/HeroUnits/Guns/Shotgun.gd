class_name Shotgun
extends GunBase

func _init() -> void:
	super._init()
	clip_size = 2
	projectile_scene_path = "res://Scenes/Effects/BaseProjectile.tscn"
	projectile_speed = 300
	projectile_max_range  = 125
	projectile_damage = 0.5
	scatter_angle_deg  = 15
	scatter_angle = deg2rad(scatter_angle_deg)
	projectile_collision_layers = ["enemy", "wall"]
	
func shoot(source : Node2D) -> void:
	remaining_shots -= 1
	var effect_attributes := {
		"source" : source,
		"collision_mask" : projectile_collision_mask,
		"speed" : projectile_speed,
		"max_range" : projectile_max_range,
		"damage" : projectile_damage,
		"force" : 30,
		"position" : proj_spawn_point.global_position if (proj_spawn_point is Node2D) else global_position
	}
	for i in 3:
		effect_attributes.rotation = global_rotation + randf_range(0, scatter_angle)
		SignalBus.spawn_effect.emit(projectile_scene_path, effect_attributes)
	for i in 3:
		effect_attributes.rotation = global_rotation + randf_range(-scatter_angle, 0)
		SignalBus.spawn_effect.emit(projectile_scene_path, effect_attributes)
