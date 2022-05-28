class_name CharactersDisplayList
extends Control

@export var character_display_scene : PackedScene

var char_displays : Dictionary

var needs_update : bool = true

func _ready():
	char_displays = {}
	CharactersManager.characters_changed.connect(_on_characters_changed)
	needs_update = true
	
	for child in get_children():
		child.queue_free()
	
	update_display()

func _process(_delta):
	update_display()

func update_display():
	if(!needs_update):
		return
	needs_update = false
	
	for char_id in char_displays.keys():
		if(CharactersManager.get_character_ids().has(char_id)):
			continue
		char_displays[char_id].queue_free()
		char_displays.erase(char_id)
	
	for char_id in CharactersManager.get_character_ids():
		if(char_displays.has(char_id)):
			continue
		var new_char_display : CharacterSummaryDisplay = character_display_scene.instantiate()
		new_char_display.set_character(CharactersManager.get_character_by_id(char_id))
		char_displays[char_id] = new_char_display
		add_child(new_char_display)

func _on_characters_changed():
	needs_update = true
