extends StructureDisplayContent
class_name StructureDisplayBuildContent

@export_node_path(TextureProgressBar) var build_progress_bar_path : NodePath
@export_node_path(Label) var build_progress_label_path : NodePath

@onready var build_progress_bar : TextureProgressBar = get_node(build_progress_bar_path)
@onready var build_progress_label : Label = get_node(build_progress_label_path)

func _ready():
	build_progress_bar.max_value = 100.00
	build_progress_bar.value = 0.0
	build_progress_label.text = "%.1f%%" % 0.0
	update_display()

func _process(_delta):
	update_display()

func update_display() -> void:
	if(structure == null || !structure.is_building_in_progress()):
		return
	
	build_progress_bar.value = structure.get_work_progress_percent()
	build_progress_label.text = "%.1f%%" % structure.get_work_progress_percent()
