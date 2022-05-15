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
	ObjectsManager.initialize()
	EnhancementManager.initialize()
	GardenManager.initialize()
	
	GardenManager.get_plot(Vector2(0,0)).insert_object("COTTAGE")

func _process(_delta):
	SupplyManager.step(_delta)
	GardenManager.step_plots(_delta)
