class_name StructureDisplay
extends Control

#@onready var build_display_content : PackedScene = load("res://Scenes/Garden/StructureDisplay/Content/StructureDisplayBuildContent.tscn")
#@onready var gain_display_content : PackedScene = load("res://Scenes/Garden/StructureDisplay/Content/StructureDisplaySupplyChangeContent.tscn")

@export_node_path(Control) var content_container_path : NodePath
@export_node_path(Label) var name_label_path : NodePath

@export var build_display_content : PackedScene
@export var gain_display_content : PackedScene

@onready var content_container : Control = get_node(content_container_path)
@onready var name_label : Label = get_node(name_label_path)

var world_coord : Vector2
var structure : Structure

var structure_display_content : StructureDisplayContent

func _ready():
	if(GardenManager.get_plot(world_coord) == null || !GardenManager.get_plot(world_coord).has_structure()):
		self.queue_free()
		return
	structure = GardenManager.get_plot(world_coord).get_structure()
	structure.structure_updated.connect(_on_structure_updated)
	update_display()

func set_world_coord(_world_coord : Vector2) -> void:
	world_coord = _world_coord

func get_world_coord() -> Vector2:
	return world_coord

func update_display() -> void:
	if(structure == null || !is_instance_valid(structure)):
		self.queue_free()
		return
	
	var display_name_text = structure.get_structure_data().get_display_name()
	if(structure.get_upgrade_level() > 0):
		display_name_text += " lv.%s" % structure.get_upgrade_level()
	name_label.text = display_name_text
	
	if(structure_display_content != null && is_instance_valid(structure_display_content)):
		structure_display_content.queue_free()
		structure_display_content = null
	if(structure.is_building_in_progress()):
		structure_display_content = build_display_content.instantiate()
		structure_display_content.init(structure)
	elif(structure.get_component(Const.GAIN) != null):
		structure_display_content = gain_display_content.instantiate()
		structure_display_content.init(structure)
	if(structure_display_content != null && is_instance_valid(structure_display_content)):
		content_container.add_child(structure_display_content)

func _on_structure_updated(coord : Vector2):
	if(world_coord == coord):
		update_display()
