class_name LockUtil

static func is_locked(category : String, key : String) -> bool:
	return Database.get_entry_attr(category, key, Const.LOCKED, false)

static func set_locked(category : String, key : String, locked : bool):
	Database.set_entry_attr(category, key, Const.LOCKED, locked)
	SignalBus.locked_status_changed.emit(category, key)
