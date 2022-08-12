class_name DirectionalCorpseEffect
extends CorpseEffect

var death_angle : float = 0
@onready var animation_player : AnimationPlayer = %AnimationPlayer

func setup_from_attribute_dictionary(_attribute_dict: Dictionary):
	super.setup_from_attribute_dictionary(_attribute_dict)
	death_angle = _attribute_dict.get("effect_angle", death_angle)

func _ready() -> void:
	var angles = {}
	if(animation_player.has_animation("front")):
		angles["front"] = 0
	if(animation_player.has_animation("left")):
		angles["left"] = PI/2
	if(animation_player.has_animation("back")):
		angles["back"] = PI
	if(animation_player.has_animation("right")):
		angles["right"] = 3*(PI/2)
	
	var min_angle : float = 9999
	var closest_key = "front"
	for key in angles.keys():
		var angle = angles[key]
		var dif = abs(angle - death_angle)
		if(dif > PI):
			dif = TAU - dif
		if(dif < min_angle):
			min_angle = dif
			closest_key = key
	
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play(closest_key)

func _on_animation_finished(anim_name : String):
	animation_player.queue_free()
