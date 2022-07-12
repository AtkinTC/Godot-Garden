extends Resource
class_name SaveResource

const SAVE_VAR_SAVE_NAME = "save_name"
const SAVE_VAR_CREATION_DATE_TIME = "creation_date_time"
const SAVE_VAR_SAVE_DATE_TIME = "save_date_time"
const SAVE_VAR_LEVEL_COMPLETION_RECORDS = "level_completion_records"

@export var save_name: String

@export var creation_date_time: Dictionary
@export var save_date_time : Dictionary

@export var world_plots : Array
