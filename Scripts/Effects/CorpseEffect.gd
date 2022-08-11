class_name CorpseEffect
extends Effect

@export var duration : float = 5
@export var fadeout_duration : float = 5
var lifetime : float = 0

func setup_from_attribute_dictionary(_attribute_dict: Dictionary):
	super.setup_from_attribute_dictionary(_attribute_dict)
	duration = _attribute_dict.get("duration", duration)
	fadeout_duration = _attribute_dict.get("fadeout_duration", fadeout_duration)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(lifetime >= duration + fadeout_duration):
		queue_free()
		return
	elif(lifetime >= duration):
		modulate.a = 1.0 - (lifetime - duration)/fadeout_duration
	lifetime += delta
