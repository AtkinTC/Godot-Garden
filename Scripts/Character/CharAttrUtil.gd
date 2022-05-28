class_name CharAttrUtil

const ATTR_HP := "HP"
const ATTR_SP := "SP"
const ATTR_STR := "STR"
const ATTR_AGI := "AGI"
const ATTR_INT := "INT"

const DISPLAY_NAME := "DISPLAY_NAME"
const DISPLAY_SHORT := "DISPLAY_SHORT"
const DISPLAY_COLORS := "DISPLAY_COLORS"
const DISPLAY_DESC := "DESCRIPTION"
const DEFAULT_VALUE := "DEFAULT_VALUE"

const ATTR_DATA := {
	ATTR_HP : {
		DISPLAY_NAME : "health",
		DISPLAY_SHORT : "HP",
		DISPLAY_COLORS : [Color8(225, 0, 0), Color8(100, 0, 0)],
		DISPLAY_DESC : "health description text",
		DEFAULT_VALUE : 10
	},
	ATTR_SP : {
		DISPLAY_NAME : "stamina",
		DISPLAY_SHORT : "SP",
		DISPLAY_COLORS : [Color8(0, 225, 0), Color8(0, 100, 0)],
		DISPLAY_DESC : "stamina description text",
		DEFAULT_VALUE : 10
	},
	ATTR_STR : {
		DISPLAY_NAME : "strength",
		DISPLAY_SHORT : "STR",
		DISPLAY_COLORS : [Color8(255, 0, 0)],
		DISPLAY_DESC : "strength description text",
		DEFAULT_VALUE : 1
	},
	ATTR_AGI : {
		DISPLAY_NAME : "agility",
		DISPLAY_SHORT : "AGI",
		DISPLAY_COLORS : [Color8(0, 255, 0)],
		DISPLAY_DESC : "agility description text",
		DEFAULT_VALUE : 1
	},
	ATTR_INT : {
		DISPLAY_NAME : "intellect",
		DISPLAY_SHORT : "INT",
		DISPLAY_COLORS : [Color8(0, 0, 255)],
		DISPLAY_DESC : "intellect description text",
		DEFAULT_VALUE : 1
	}
}

static func get_char_attr_keys() -> Array:
	return ATTR_DATA.keys()
