class_name ObjectData

const STARTER := {
		Const.DISPLAY_NAME : "small hearth",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.BUILD : {
			Const.VALUE : {
				"RAW_MEMORY" : 5
			},
			Const.LIMIT : 1
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"RAW_ESS" : 1
				},
				Const.LOCAL_MODIFIERS : [{
					Const.LOCAL_MOD_TARGET : Const.LEVEL,
					Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
				}]
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"RAW_ESS" : 10
				}
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 1
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		},
		Const.UNLOCKS : [
			{
				Const.UNLOCK_KEY : "RAW_ESS",
				Const.UNLOCK_TYPE : Const.SUPPLY
			},
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
		Const.BUILD : {
			Const.VALUE : {
				"RAW_ESS" : 1
			},
			Const.LENGTH : 5,
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.COUNT,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN
			}]
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"WOOD" : 1
				},
				Const.LOCAL_MODIFIERS : [{
					Const.LOCAL_MOD_TARGET : Const.LEVEL,
					Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
				}]
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"WOOD" : 10
				},
				Const.LOCAL_MODIFIERS : [{
					Const.LOCAL_MOD_TARGET : Const.LEVEL,
					Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
				}]
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 10,
			Const.VALUE : {
				"WOOD" : 1,
				"RAW_ESS" : 1,
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		},
		Const.UNLOCKS : [
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
			Const.VALUE : {
				"RAW_ESS" : 10
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"AIR_ESS" : 1
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"AIR_ESS" : 10
				}
			}
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 5
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		}
	}
const EARTH_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "earth rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.VALUE : {
				"RAW_ESS" : 10
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"EARTH_ESS" : 1
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"EARTH_ESS" : 10
				}
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 5
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		}
	}
const FIRE_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "fire rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.VALUE : {
				"RAW_ESS" : 10
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"FIRE_ESS" : 1
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"FIRE_ESS" : 10
				}
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 5
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		}
	}
const WATER_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "water rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.VALUE : {
				"RAW_ESS" : 10
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"WATER_ESS" : 1
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"WATER_ESS" : 10
				}
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 5
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		}
	}
const MIND_SOURCE_BASIC := {
		Const.DISPLAY_NAME : "mind rune",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.VALUE : {
				"AIR_ESS" : 10,
				"EARTH_ESS" : 10
			}
		},
		Const.BUILD : {
			Const.LENGTH : 5,
		},
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"MIND_ESS" : 1
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"MIND_ESS" : 10
				}
			},
		},
		Const.UPGRADE : {
			Const.LENGTH : 1,
			Const.LIMIT : 5,
			Const.VALUE : {
				"RAW_ESS" : 5
			},
			Const.LOCAL_MODIFIERS : [{
				Const.LOCAL_MOD_TARGET : Const.LEVEL,
				Const.LOCAL_MOD_TYPE : Const.TYPE_LIN,
			}]
		}
	}
const FOCUS_BASIC := {
		Const.DISPLAY_NAME : "basic focus",
		Const.LOCKED : false,
		Const.REMOVABLE : false,
		Const.SOURCE : {
			Const.GAIN : {
				Const.VALUE : {
					"AIR_ESS" : 1,
					"EARTH_ESS" : 1,
					"FIRE_ESS" : 1,
					"WATER_ESS" : 1
				}
			}
		},
		Const.UPGRADE : {
			Const.UPGRADE_OBJECT : "FOCUS_BASIC_LV2",
			Const.LENGTH : 10,
			Const.VALUE : {
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
				Const.VALUE : {
					"AIR_ESS" : 2,
					"EARTH_ESS" : 2,
					"FIRE_ESS" : 2,
					"WATER_ESS" : 2
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"AIR_ESS" : 30,
					"EARTH_ESS" : 30,
					"FIRE_ESS" : 30,
					"WATER_ESS" : 30
				}
			}
		},
		Const.UPGRADE : {
			Const.UPGRADE_OBJECT : "FOCUS_BASIC_LV3",
			Const.LENGTH : 20,
			Const.VALUE : {
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
				Const.VALUE : {
					"AIR_ESS" : 4,
					"EARTH_ESS" : 4,
					"FIRE_ESS" : 4,
					"WATER_ESS" : 4
				}
			},
			Const.CAPACITY : {
				Const.VALUE : {
					"AIR_ESS" : 60,
					"EARTH_ESS" : 60,
					"FIRE_ESS" : 60,
					"WATER_ESS" : 60
				}
			}
		}
	}

const object_types := {
	"STARTER" : STARTER,
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
