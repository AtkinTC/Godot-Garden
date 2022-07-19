extends Node2D

func _init():
	Database.initialize()
	
	DataValidator.validate_category_data(Const.ACTION)
	DataValidator.validate_category_data(Const.OBJECT)
	DataValidator.validate_category_data(Const.SUPPLY)
	DataValidator.validate_category_data(Const.ENHANCEMENT)
	
	ModifiersManager.initialize()
	ActionManager.initialize()
	SupplyManager.initialize()
	StructuresManager.initialize()
	EnhancementManager.initialize()
	CharactersManager.initialize()
	GardenManager.initialize()

func _ready():
	var load_success : bool = SaveController.load_as_current_save_file("test")
	
	if(load_success):
		var current_save_file := SaveController.get_current_save_file()
		CharactersManager.setup_from_character_array(current_save_file.characters)
		GardenManager.setup_from_plots_array(current_save_file.world_plots)
		WorldUnitsManager.setup_from_world_units_array(current_save_file.world_units)
	else:
		setup_test_data()
	
	get_tree().create_timer(10).timeout.connect(_autosave)

#TODO: remove this test code
func setup_test_data():
	#example characters for testing purposes
	var new_char : CharacterVO = CharactersManager.create_new_character()
	new_char.set_character_name("Anne")
	new_char.set_portrait_name("portrait_basic_005.png")
	new_char.set_attr_HP(20)
	new_char.set_current_HP(20)
	new_char.set_attr_STR(5)
	
	new_char = CharactersManager.create_new_character()
	new_char.set_character_name("Bob")
	new_char.set_portrait_name("portrait_basic_007.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	
	new_char = CharactersManager.create_new_character()
	new_char.set_character_name("Carl")
	new_char.set_portrait_name("portrait_basic_003.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	new_char.set_attr_INT(3)
	
	new_char = CharactersManager.create_new_character()
	new_char.set_character_name("Dirk")
	new_char.set_portrait_name("portrait_basic_004.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	new_char.set_attr_AGI(2)
	
	#example plot areas for testing purposes
	var center_plot : PlotVO = GardenManager.create_plot(Vector2(0,0), "road", "blank")
	GardenManager.complete_exploration(center_plot.get_coord())
	
	# create dummy world unit for testing
	WorldUnitsManager.create_new_world_unit()
	WorldUnitsManager.create_new_world_unit()
	WorldUnitsManager.create_new_world_unit()
	WorldUnitsManager.create_new_world_unit()

func _process(_delta):
	SupplyManager.step(_delta)
	GardenManager.step_plots(_delta)

func _autosave():
	var current_save : SaveFileResource = SaveController.get_current_save_file()
	if(current_save == null):
		current_save = SaveController.create_new_save_file("test")
		
	current_save.world_plots = GardenManager.get_used_plots()
	current_save.characters = CharactersManager.get_characters()
	current_save.world_units = WorldUnitsManager.get_world_units()
	
	SaveController.save_current_save_file()
	get_tree().create_timer(10).timeout.connect(_autosave)
