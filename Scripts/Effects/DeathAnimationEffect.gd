class_name DeathAnimationEffect
extends Effect

@export var duration : float = 5
@export var fadeout_duration : float = 5
var lifetime : float = 0

func setup_from_attribute_dictionary(_attribute_dict: Dictionary):
	super.setup_from_attribute_dictionary(_attribute_dict)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(lifetime >= duration + fadeout_duration):
		queue_free()
		return
	elif(lifetime >= duration):
		modulate.a = 1.0 - (lifetime - duration)/fadeout_duration
	lifetime += delta
