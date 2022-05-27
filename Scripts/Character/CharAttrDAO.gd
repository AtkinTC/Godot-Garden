class_name CharAttrDAO


var char_attr_key : String

func _init(_char_attr_key : String):
	char_attr_key = _char_attr_key

func get_attr_data() -> Dictionary:
	return CharAttrUtil.ATTR_DATA.get(char_attr_key, {})

func get_display_name() -> String:
	return get_attr_data().get(CharAttrUtil.DISPLAY_NAME, "")

func get_display_name_short() -> String:
	return get_attr_data().get(CharAttrUtil.DISPLAY_SHORT, "")

func get_display_colors() -> Array:
	return get_attr_data().get(CharAttrUtil.DISPLAY_COLORS, [])

func get_display_description() -> String:
	return get_attr_data().get(CharAttrUtil.DISPLAY_DESC, "")

func get_default_value() -> float:
	return get_attr_data().get(CharAttrUtil.DEFAULT_VALUE, "")
