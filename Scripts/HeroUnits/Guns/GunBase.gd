class_name GunBase
extends Node2D

var proj_spawn_point : Node2D
var clip_size : int = 0
var remaining_shots : int = 0
var projectile_scene_path : String = ""
var projectile_speed : float = 0
var projectile_max_range : float = 0
var projectile_damage : float = 0
var scatter_angle_deg : float = 0
var scatter_angle : float = 0
var projectile_collision_layers : Array[String] = []
var projectile_collision_mask : int = 0

var shell_emitter : GPUParticles2D

func _init() -> void:
	pass

func _ready() -> void:
	proj_spawn_point = get_node_or_null("%ProjectileSpawnPoint")
	shell_emitter = get_node_or_null("%ShellEmitter")
	
	remaining_shots = clip_size
	
	if(projectile_collision_layers != null):
		projectile_collision_mask = PhysicsUtil.get_physics_layer_mask_from_names(projectile_collision_layers)
	
	if(shell_emitter != null && clip_size > shell_emitter.get_amount()):
		shell_emitter.set_amount(clip_size)

func shoot(source : Node2D) -> void:
	pass

func complete_reload() -> void:
	remaining_shots = clip_size

func needs_reload() -> bool:
	return remaining_shots <= 0

func get_projectile_speed() -> float:
	return projectile_speed

func emit_shell_effect() -> void:
	if(shell_emitter == null):
		return
	#emitter.restart()
	shell_emitter.emit_particle(Transform2D(), Vector2.ZERO, 0, 0, 0)
