class_name CellDefinition
extends Resource

@export var key := ""
@export var N := []
@export var S := []
@export var E := []
@export var W := []

func _to_string() -> String:
	return  "\"" + str(key) + "\" : {\n\t\"N\":" + str(N) + ",\n\t\"S\":" + str(S) + ",\n\t\"E\":" + str(E) + ",\n\t\"W\":" + str(W) + "}"

func to_dictionary() -> Dictionary:
	return {"key":key,"N":N,"S":S,"E":E,"W":W}
