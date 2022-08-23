class_name SMG
extends GunBase

func _init() -> void:
	super._init()
	clip_size = 20
	projectile_scene_path = "res://Scenes/Effects/BaseProjectile.tscn"
	projectile_speed = 300
	projectile_max_range  = 200
	projectile_damage = 0.5
	scatter_angle_deg  = 10
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
		"rotation" : global_rotation + randf_range(-scatter_angle, scatter_angle),
		"position" : proj_spawn_point.global_position if (proj_spawn_point is Node2D) else global_position
	}
	SignalBus.spawn_effect.emit(projectile_scene_path, effect_attributes)

