class_name CharacterSummaryDisplay
extends Control

@export_node_path(Label) var char_name_label_path
@export_node_path var HP_display_path
@export_node_path var SP_display_path
@export_node_path var STR_display_path
@export_node_path var AGI_display_path
@export_node_path var INT_display_path
@export_node_path var char_portrait_path

@onready var char_name_label : Label = get_node(char_name_label_path) if char_name_label_path else null
@onready var supply_display_HP : SupplyDisplay = get_node(HP_display_path) if HP_display_path else null
@onready var supply_display_SP : SupplyDisplay = get_node(SP_display_path) if SP_display_path else null
@onready var supply_display_STR : SupplyDisplay = get_node(STR_display_path) if SP_display_path else null
@onready var supply_display_AGI : SupplyDisplay = get_node(AGI_display_path) if SP_display_path else null
@onready var supply_display_INT : SupplyDisplay = get_node(INT_display_path) if SP_display_path else null
@onready var char_portrait : CharacterPortraitDisplay = get_node(char_portrait_path) if char_portrait_path else null

var character : CharacterVO

var needs_update : bool = true

func _ready() -> void:
	ready()

func ready():
	needs_update = true
	
	# setup attribute display settings
	if(supply_display_HP):
		var HP_DAO = CharAttrDAO.new(CharAttrUtil.ATTR_HP)
		supply_display_HP.set_display_name(HP_DAO.get_display_name_short())
		supply_display_HP.set_display_colors(HP_DAO.get_display_colors())
		supply_display_HP.set_number_format_string("%.0f")
	if(supply_display_SP):
		var SP_DAO = CharAttrDAO.new(CharAttrUtil.ATTR_SP)
		supply_display_SP.set_display_name(SP_DAO.get_display_name_short())
		supply_display_SP.set_display_colors(SP_DAO.get_display_colors())
		supply_display_SP.set_number_format_string("%.0f")
	if(supply_display_STR):
		var STR_DAO = CharAttrDAO.new(CharAttrUtil.ATTR_STR)
		supply_display_STR.set_display_name(STR_DAO.get_display_name_short())
		supply_display_STR.set_number_format_string("%.0f")
	if(supply_display_AGI):
		var AGI_DAO = CharAttrDAO.new(CharAttrUtil.ATTR_AGI)
		supply_display_AGI.set_display_name(AGI_DAO.get_display_name_short())
		supply_display_AGI.set_number_format_string("%.0f")
	if(supply_display_INT):
		var INT_DAO = CharAttrDAO.new(CharAttrUtil.ATTR_INT)
		supply_display_INT.set_display_name(INT_DAO.get_display_name_short())
		supply_display_INT.set_number_format_string("%.0f")
	
	update_display()

func _process(_delta) -> void:
	update_display()

func update_display() -> void:
	if(!needs_update):
		return
	
	if(character == null):
		set_from_default_values()
		return
	
	set_from_character_values()
	
	needs_update = false

func set_from_character_values():
	if(char_name_label):
		char_name_label.text = character.get_character_name()
	if(char_portrait):
		char_portrait.set_portrait_name(character.get_character_portrait_name())
	if(supply_display_HP):
		supply_display_HP.set_quantity(character.get_current_HP())
		supply_display_HP.set_capacity(character.get_attr_HP())
	if(supply_display_SP):
		supply_display_SP.set_quantity(character.get_current_SP())
		supply_display_SP.set_capacity(character.get_attr_SP())
	if(supply_display_STR):
		supply_display_STR.set_quantity(character.get_attr_STR())
	if(supply_display_AGI):
		supply_display_AGI.set_quantity(character.get_attr_AGI())
	if(supply_display_INT):
		supply_display_INT.set_quantity(character.get_attr_INT())

func set_from_default_values():
	if(char_name_label):
		char_name_label.text = "- - -"
	if(char_portrait):
		char_portrait.set_portrait_name("")
	if(supply_display_HP):
		supply_display_HP.set_quantity(-1)
		supply_display_HP.set_capacity(-1)
	if(supply_display_SP):
		supply_display_SP.set_quantity(-1)
		supply_display_SP.set_capacity(-1)
	if(supply_display_STR):
		supply_display_STR.set_quantity(-1)
	if(supply_display_AGI):
		supply_display_AGI.set_quantity(-1)
	if(supply_display_INT):
		supply_display_INT.set_quantity(-1)

func set_character(_character : CharacterVO) -> void:
	if(character != null && character.changed.is_connected(_on_character_changed)):
		character.changed.disconnect(_on_character_changed)
	character = _character
	_character.changed.connect(_on_character_changed)
	needs_update = true

func _on_character_changed():
	needs_update = true
