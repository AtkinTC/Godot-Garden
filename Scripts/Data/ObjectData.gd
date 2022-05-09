class_name ObjectData

const object_types := {
	"FOCUS_BASIC" : {
		Const.DISPLAY_NAME : "focus lv.1",
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 1,
			"EARTH_ESS" : 1,
			"FIRE_ESS" : 1,
			"WATER_ESS" : 1
		},
		Const.UPGRADE_OBJECT : "FOCUS_BASIC_LV2",
		Const.UPGRADE_LENGTH : 10,
		Const.UPGRADE_COST : {
			"AIR_ESS" : 20,
			"EARTH_ESS" : 20,
			"FIRE_ESS" : 20,
			"WATER_ESS" : 20
		},
		
	},
	"FOCUS_BASIC_LV2" : {
		Const.DISPLAY_NAME : "focus lv.2",
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 2,
			"EARTH_ESS" : 2,
			"FIRE_ESS" : 2,
			"WATER_ESS" : 2
		},
		Const.CAPACITY : {
			"AIR_ESS" : 25,
			"EARTH_ESS" : 25,
			"FIRE_ESS" : 25,
			"WATER_ESS" : 25
		}
	},
	"AIR_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "air rune",
		Const.PURCHASABLE : true,
		Const.BUILD_COST : {
			"EARTH_ESS" : 10,
			"AIR_ESS" : 10
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 1
		},
		Const.CAPACITY : {
			"AIR_ESS" : 10
		}
	},
	"EARTH_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "earth rune",
		Const.PURCHASABLE : true,
		Const.BUILD_COST : {
			"EARTH_ESS" : 10,
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"EARTH_ESS" : 1
		},
		Const.CAPACITY : {
			"EARTH_ESS" : 10
		}
	},
	"FIRE_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "fire rune",
		Const.PURCHASABLE : true,
		Const.BUILD_COST : {
			"AIR_ESS" : 10,
			"FIRE_ESS" : 10
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"FIRE_ESS" : 1
		},
		Const.CAPACITY : {
			"FIRE_ESS" : 10
		}
	},
	"WATER_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "water rune",
		Const.PURCHASABLE : true,
		Const.BUILD_COST : {
			"EARTH_ESS" : 10,
			"WATER_ESS" : 10
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"WATER_ESS" : 1
		},
		Const.CAPACITY : {
			"WATER_ESS" : 10
		}
	},
	"MIND_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "mind rune",
		Const.LOCKED : true,
		Const.PURCHASABLE : true,
		Const.BUILD_COST : {
			"EARTH_ESS" : 10,
			"AIR_ESS" : 10
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"MIND_ESS" : 1
		},
		Const.CAPACITY : {
			"MIND_ESS" : 10
		}
	}
}
