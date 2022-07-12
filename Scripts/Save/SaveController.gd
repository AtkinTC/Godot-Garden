extends Node

const CLASS_NAME = "ProfileNameInput"

var demo_save_directory: String = "res://Saves/"
var demo_save_filename_pre: String = "save_"
var demo_save_filename_post: String = ".tres"

var current_game_save: SaveResource

func reset_game_save():
	current_game_save = null

# create a new game save, set intial values, and trigger save
func create_new_game_save(_profile_name):
	current_game_save = SaveResource.new()
	current_game_save.set(SaveResource.SAVE_VAR_SAVE_NAME, _profile_name)
	current_game_save.set(SaveResource.SAVE_VAR_CREATION_DATE_TIME, Time.get_datetime_dict_from_system())
	save_current_game()

# trigger save to file of the current game save
func save_current_game():
	var METHOD_NAME = "save_current_game"
	var dir = Directory.new()
	if(!dir.dir_exists(demo_save_directory)):
		dir.make_dir_recursive(demo_save_directory)
	
	current_game_save.world_plots = GardenManager.get_used_plots()
	
	current_game_save.set(SaveResource.SAVE_VAR_SAVE_DATE_TIME, Time.get_datetime_dict_from_system())
	var profile_name: String = current_game_save.get(SaveResource.SAVE_VAR_SAVE_NAME)
	var file_name: String = demo_save_filename_pre+profile_name+demo_save_filename_post
	ResourceSaver.save(demo_save_directory+file_name, current_game_save)
	print_debug(CLASS_NAME + " : " + METHOD_NAME +  " : save_game complete for file : " + demo_save_directory+file_name)

# load a game save from a file
func load_game(_file_name: String) -> SaveResource:
	var METHOD_NAME = "load_game"
	var dir = Directory.new()
	if(!dir.file_exists(demo_save_directory+_file_name)):
		print_debug(CLASS_NAME + " : " + METHOD_NAME + " : no file found for profile name")
		return null
		
	var loaded_save: Resource = load(demo_save_directory+_file_name)
	if(loaded_save is SaveResource):
		print_debug(CLASS_NAME + " : " + METHOD_NAME +  " : load complete for file : " + demo_save_directory+_file_name)
		return (loaded_save as SaveResource)
	return null

# load a game save as the current save
func load_as_current_game(_profile_name: String):
	var METHOD_NAME = "load_as_current_game"
	var file_name = demo_save_filename_pre + _profile_name + demo_save_filename_post
	var loaded_game = load_game(file_name)
	if(loaded_game is SaveResource):
		current_game_save = loaded_game
		return true
	return false

# get array of all found game saves in the save directory
func get_all_save_games() -> Array:
	var METHOD_NAME = "get_all_save_games"
	var dir = Directory.new()
	if(!dir.dir_exists(demo_save_directory)):
		print_debug(CLASS_NAME + " : " + METHOD_NAME + " : save directory doesn't exist")
		return []
	
	var saves = []
	
	#loop through all files in the directory
	if(dir.open(demo_save_directory) == OK):
		dir.list_dir_begin()
		var file_name = null
		while file_name != "":
			file_name = dir.get_next()
			if(dir.current_is_dir()):
				#current is a directory
				continue
			if(file_name.begins_with(demo_save_filename_pre) && file_name.ends_with(demo_save_filename_post)):
				#current is a potential save file
				var loaded_file = load_game(file_name)
				if(loaded_file is SaveResource):
					saves.append(loaded_file)
	
	return saves
