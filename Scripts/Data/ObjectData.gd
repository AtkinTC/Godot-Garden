class_name ObjectData

const object_types := {
	"COTTAGE" : {
		Const.DISPLAY_NAME : "small cottage",
		Const.LOCKED : false,
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"RAW_ESS" : 1,
		},
		Const.CAPACITY : {
			"RAW_ESS" : 10,
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL,
			Const.UPGRADE_LENGTH : 10,
			Const.UPGRADE_COST : {
				"WOOD" : 20
			}
		}
	},
	"FOREST" : {
		Const.DISPLAY_NAME : "small forest",
		Const.LOCKED : false,
		Const.PURCHASABLE : true,
		Const.REMOVABLE : true,
		Const.BUILD_COST : {
			"RAW_ESS" : 10,
		},
		Const.BUILD_LENGTH : 5,
		Const.PASSIVE_GAIN : {
			"WOOD" : 1,
		},
		Const.CAPACITY : {
			"WOOD" : 10,
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL,
			Const.UPGRADE_LENGTH : 10,
			Const.UPGRADE_COST : {
				"WOOD" : 20,
				"RAW_ESS" : 20,
			}
		},
		Const.UNLOCK : [
			{
				Const.UNLOCK_KEY : "WOOD",
				Const.UNLOCK_TYPE : Const.SUPPLY
			}
		]
	},
	"FOCUS_BASIC" : {
		Const.DISPLAY_NAME : "basic focus",
		Const.LOCKED : false,
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 1,
			"EARTH_ESS" : 1,
			"FIRE_ESS" : 1,
			"WATER_ESS" : 1
		},
		Const.UPGRADE : {
			Const.UPGRADE_OBJECT : "FOCUS_BASIC_LV2",
			Const.UPGRADE_LENGTH : 10,
			Const.UPGRADE_COST : {
				"AIR_ESS" : 30,
				"EARTH_ESS" : 30,
				"FIRE_ESS" : 30,
				"WATER_ESS" : 30
			}
		}
		
	},
	"FOCUS_BASIC_LV2" : {
		Const.DISPLAY_NAME : "focus",
		Const.LOCKED : false,
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 2,
			"EARTH_ESS" : 2,
			"FIRE_ESS" : 2,
			"WATER_ESS" : 2
		},
		Const.CAPACITY : {
			"AIR_ESS" : 30,
			"EARTH_ESS" : 30,
			"FIRE_ESS" : 30,
			"WATER_ESS" : 30
		},
		Const.UPGRADE : {
			Const.UPGRADE_OBJECT : "FOCUS_BASIC_LV3",
			Const.UPGRADE_LENGTH : 20,
			Const.UPGRADE_COST : {
				"AIR_ESS" : 120,
				"EARTH_ESS" : 120,
				"FIRE_ESS" : 120,
				"WATER_ESS" : 120
			}
		}
	},
	"FOCUS_BASIC_LV3" : {
		Const.DISPLAY_NAME : "adv. focus",
		Const.LOCKED : false,
		Const.PURCHASABLE : false,
		Const.REMOVABLE : false,
		Const.PASSIVE_GAIN : {
			"AIR_ESS" : 4,
			"EARTH_ESS" : 4,
			"FIRE_ESS" : 4,
			"WATER_ESS" : 4
		},
		Const.CAPACITY : {
			"AIR_ESS" : 60,
			"EARTH_ESS" : 60,
			"FIRE_ESS" : 60,
			"WATER_ESS" : 60
		}
	},
	"AIR_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "air rune",
		Const.LOCKED : true,
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
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	},
	"EARTH_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "earth rune",
		Const.LOCKED : true,
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
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	},
	"FIRE_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "fire rune",
		Const.LOCKED : true,
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
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	},
	"WATER_SOURCE_BASIC" : {
		Const.DISPLAY_NAME : "water rune",
		Const.LOCKED : true,
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
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
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
		},
		Const.UPGRADE : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
}
