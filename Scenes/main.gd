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
	#TODO: remove this test code
	#example characters for testing purposes
	var new_char : CharacterVO = CharactersManager.create_empty_character()
	new_char.set_character_name("Anne")
	new_char.set_character_portrait_name("portrait_basic_005.png")
	new_char.set_attr_HP(20)
	new_char.set_current_HP(20)
	new_char.set_attr_STR(5)
	
	new_char = CharactersManager.create_empty_character()
	new_char.set_character_name("Bob")
	new_char.set_character_portrait_name("portrait_basic_007.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	
	new_char = CharactersManager.create_empty_character()
	new_char.set_character_name("Carl")
	new_char.set_character_portrait_name("portrait_basic_003.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	new_char.set_attr_INT(3)
	
	new_char = CharactersManager.create_empty_character()
	new_char.set_character_name("Dirk")
	new_char.set_character_portrait_name("portrait_basic_004.png")
	new_char.set_attr_HP(10)
	new_char.set_current_HP(10)
	new_char.set_attr_AGI(2)
	
	var center_plot : Plot = GardenManager.create_plot(Vector2(0,0))
	center_plot.insert_structure("STARTER")
	center_plot.set_display_name("base")
	center_plot.set_explored(true)
	center_plot.plot_type = "empty"
	center_plot.base_type = "blank"
	
	#TODO: remove this test code
	#example plot areas for testing purposes
	var plot = GardenManager.create_plot(Vector2(1,0))
	var plot_type = GardenManager.select_plot_type_neighbor("base")
	plot.set_display_name(plot_type)
	plot.plot_type = plot_type
	plot.base_type = "grass"
	
	plot = GardenManager.create_plot(Vector2(0,1))
	plot_type = GardenManager.select_plot_type_neighbor("base")
	plot.set_display_name(plot_type)
	plot.plot_type = plot_type
	plot.base_type = "grass"
	
	plot = GardenManager.create_plot(Vector2(-1,0))
	plot_type = GardenManager.select_plot_type_neighbor("base")
	plot.set_display_name(plot_type)
	plot.plot_type = plot_type
	plot.base_type = "grass"
	
	plot = GardenManager.create_plot(Vector2(0,-1))
	plot_type = GardenManager.select_plot_type_neighbor("base")
	plot.set_display_name(plot_type)
	plot.plot_type = plot_type
	plot.base_type = "grass"
	
	#TODO: remove this test code
	# create dummy world unit for testing
	var world_units : WorldUnitsManager = $World/WorldUnitsManager
	world_units.add_new_world_unit(Vector2i(0,0))
	world_units.add_new_world_unit(Vector2i(0,0))
	world_units.add_new_world_unit(Vector2i(0,0))
	world_units.add_new_world_unit(Vector2i(0,0))


func _process(_delta):
	SupplyManager.step(_delta)
	GardenManager.step_plots(_delta)
