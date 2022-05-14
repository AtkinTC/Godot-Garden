class_name ObjectData

const COTTAGE := {
		Const.DISPLAY_NAME : "small cottage",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.PURCHASE : {
			Const.PRICE : {
				"RAW_ESS" : 10,
			},
			Const.PURCHASE_LIMIT : 1
		},
		Const.SOURCE : {
			Const.GAIN : {
				"RAW_ESS" : 1,
			},
			Const.CAPACITY : {
				"RAW_ESS" : 10,
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL,
			Const.UPGRADE_LENGTH : 10,
			Const.UPGRADE_COST : {
				"WOOD" : 20
			}
		},
		Const.UNLOCK : [
			{
				Const.UNLOCK_KEY : "FOREST",
				Const.UNLOCK_TYPE : Const.OBJECT
			}
		]
	}
const FOREST := {
		Const.DISPLAY_NAME : "small forest",
		Const.LOCKED : true,
		Const.REMOVABLE : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"RAW_ESS" : 10,
			},
			Const.PRICE_MODIFIER : {
				Const.PRICE_MODIFIER_TARGET : Const.COUNT,
				Const.PRICE_MOD_TYPE : Const.TYPE_LIN
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				"WOOD" : 1,
			},
			Const.CAPACITY : {
				"WOOD" : 10,
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL,
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
	}
const AIR_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "air rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"EARTH_ESS" : 10,
				"AIR_ESS" : 10
			}
		},
		Const.BUILD_LENGTH : 5,
		Const.SOURCE : {
			Const.GAIN : {
				"AIR_ESS" : 1
			},
			Const.CAPACITY : {
				"AIR_ESS" : 10
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
const EARTH_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "earth rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"EARTH_ESS" : 10
			}
		},
		Const.BUILD_LENGTH : 5,
		Const.SOURCE : {
			Const.GAIN : {
				"EARTH_ESS" : 1
			},
			Const.CAPACITY : {
				"EARTH_ESS" : 10
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
const FIRE_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "fire rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"AIR_ESS" : 10,
				"FIRE_ESS" : 10
			}
		},
		Const.BUILD_LENGTH : 5,
		Const.SOURCE : {
			Const.GAIN : {
				"FIRE_ESS" : 1
			},
			Const.CAPACITY : {
				"FIRE_ESS" : 10
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
const WATER_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "water rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"EARTH_ESS" : 10,
				"WATER_ESS" : 10
			}
		},
		Const.BUILD_LENGTH : 5,
		Const.SOURCE : {
			Const.GAIN : {
				"WATER_ESS" : 1
			},
			Const.CAPACITY : {
				"WATER_ESS" : 10
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
const MIND_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "mind rune",
		Const.LOCKED : true,
		Const.PURCHASABLE : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"AIR_ESS" : 10,
				"EARTH_ESS" : 10
			}
		},
		Const.BUILD_LENGTH : 5,
		Const.SOURCE : {
			Const.GAIN : {
				"MIND_ESS" : 1
			},
			Const.CAPACITY : {
				"MIND_ESS" : 10
			},
		},
		Const.UPGRADE : {
			Const.PRICE_MOD_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		}
	}
const FOCUS_BASIC := {
		Const.DISPLAY_NAME : "basic focus",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.SOURCE : {
			Const.GAIN : {
				"AIR_ESS" : 1,
				"EARTH_ESS" : 1,
				"FIRE_ESS" : 1,
				"WATER_ESS" : 1
			}
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
		
	}
const FOCUS_BASIC_LV2 := {
		Const.DISPLAY_NAME : "focus",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.SOURCE : {
			Const.GAIN : {
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
			}
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
	}
const FOCUS_BASIC_LV3 := {
		Const.DISPLAY_NAME : "adv. focus",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.SOURCE : {
			Const.GAIN : {
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
		}
	}

const object_types := {
	"COTTAGE" : COTTAGE,
	"FOREST" : FOREST,
	"FOCUS_BASIC" : FOCUS_BASIC,
	"FOCUS_BASIC_LV2" : FOCUS_BASIC_LV2,
	"FOCUS_BASIC_LV3" : FOCUS_BASIC_LV3,
	"AIR_SOURCE_BASIC" : AIR_SOURCE_BASIC,
	"EARTH_SOURCE_BASIC" : EARTH_SOURCE_BASIC,
	"FIRE_SOURCE_BASIC" : FIRE_SOURCE_BASIC,
	"WATER_SOURCE_BASIC" : WATER_SOURCE_BASIC,
	"MIND_SOURCE_BASIC" : MIND_SOURCE_BASIC
}
