class_name PlayerCameraTransform
extends RemoteTransform2D

@onready var player : Player = get_parent()

var max_distance := 250

func _ready():
	var cam_node = %Camera
	if(cam_node is Camera2D):
		remote_path = cam_node.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos : Vector2 = (player.get_aim_position()/3).limit_length(max_distance)
	var diff := target_pos-position
	position = Tween.interpolate_value(position, diff, delta, 1.0, Tween.TRANS_QUINT,Tween.EASE_OUT)
