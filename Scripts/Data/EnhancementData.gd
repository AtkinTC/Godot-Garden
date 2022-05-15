class_name EnhancementData

const BASE_STAT := {
		Const.DISPLAY_NAME : "base stats",
		Const.LOCKED : false,
		Const.DISABLED : true,
		Const.SOURCE : {
			Const.GAIN : {
				"RAW_MEMORY" : 1,
				"RAW_ESS" : 1
			},
			Const.CAPACITY : {
				"RAW_MEMORY" : 100,
				"RAW_ESS" : 10
			}
		},
	}
const FOREST_BUFF := {
		Const.DISPLAY_NAME : "forest buff test",
		Const.LOCKED : false,
		Const.PURCHASE : {
			Const.PRICE : {
				"RAW_ESS" : 10
			},
			Const.PRICE_MODIFIERS : [{
				Const.PRICE_MODIFIER_TARGET : Const.COUNT,
				Const.PRICE_MOD_TYPE : Const.TYPE_LIN
			}]
		},
		Const.MODIFIERS : [
			{
				Const.MOD_TARGET_CAT : Const.OBJECT,
				Const.MOD_TARGET_KEY : ["FOREST"],
				Const.MOD_EFFECT : [
					{
						Const.MOD_TYPE : Const.PRICE,
						Const.MOD_SCALE : -0.1,
						Const.MOD_COMPOUNDING : true
					},
				]
			}
		]
	}
const UNLOCK_AIR := {
		Const.DISPLAY_NAME : "path of the air",
		Const.LOCKED : false,
		Const.PURCHASE : {
			Const.PRICE : {
				"RAW_ESS" : 5
			}
		},
		Const.SOURCE : {
			Const.GAIN : {
				"AIR_ESS" : 0.1
			},
			Const.CAPACITY : {
				"AIR_ESS" : 100
			}
		},
		Const.UNLOCKS : [
			{
				Const.UNLOCK_KEY : "AIR_ESS",
				Const.UNLOCK_TYPE : Const.SUPPLY
			},
			{
				Const.UNLOCK_KEY : "AIR_SOURCE_BASIC",
				Const.UNLOCK_TYPE : Const.OBJECT
			},
			{
				Const.UNLOCK_KEY : "ENHANCE_ELEMENTS",
				Const.UNLOCK_TYPE : Const.UPGRADE
			}
		]
	}
const ENHANCE_ELEMENTS := {
		Const.DISPLAY_NAME : "elemental focus",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"AIR_ESS" : 15,
				"EARTH_ESS" : 15,
				"FIRE_ESS" : 15,
				"WATER_ESS" : 15
			},
			Const.PRICE_MODIFIERS : [{
				Const.PRICE_MODIFIER_TARGET : Const.COUNT,
				Const.PRICE_MOD_TYPE : Const.TYPE_LIN
			}]
		},
		Const.MODIFIERS : [
			{
				Const.MOD_TARGET_CAT : Const.SUPPLY,
				Const.MOD_TARGET_KEY : ["AIR_ESS", "EARTH_ESS", "FIRE_ESS", "WATER_ESS"],
				Const.MOD_EFFECT : [
					{
						Const.MOD_TYPE : Const.GAIN,
						Const.MOD_SCALE : 0.1
					},
					{
						Const.MOD_TYPE : Const.CAPACITY,
						Const.MOD_SCALE : 0.1
					}
				]
			}
		]
	}
const UNLOCK_MIND := {
		Const.DISPLAY_NAME : "path of the mind",
		Const.LOCKED : false,
		Const.PURCHASE : {
			Const.PRICE : {
				"AIR_ESS" : 10,
				"EARTH_ESS" : 10,
				"FIRE_ESS" : 10,
				"WATER_ESS" : 10
			},
			Const.LIMIT : 1
		},
		Const.SOURCE : {
			Const.GAIN : {
				"MIND_ESS" : 0.1
			},
			Const.CAPACITY : {
				"MIND_ESS" : 100
			}
		},
		Const.UNLOCKS : [
			{
				Const.UNLOCK_KEY : "MIND_ESS",
				Const.UNLOCK_TYPE : Const.SUPPLY
			},
			{
				Const.UNLOCK_KEY : "MIND_SOURCE_BASIC",
				Const.UNLOCK_TYPE : Const.OBJECT
			},
			{
				Const.UNLOCK_KEY : "ENHANCE_MIND",
				Const.UNLOCK_TYPE : Const.UPGRADE
			}
		]
	}
const ENHANCE_MIND := {
		Const.DISPLAY_NAME : "enhance mind",
		Const.LOCKED : true,
		Const.PURCHASE : {
			Const.PRICE : {
				"AIR_ESS" : 10,
				"EARTH_ESS" : 10,
				"FIRE_ESS" : 10,
				"WATER_ESS" : 10
			},
			Const.PRICE_MODIFIERS : [{
				Const.PRICE_MODIFIER_TARGET : Const.COUNT,
				Const.PRICE_MOD_TYPE : Const.TYPE_LIN
			}]
		},
		Const.SOURCE : {
			Const.GAIN : {
				"MIND_ESS" : 0.1
			}
		},
		Const.MODIFIERS : [
			{
				Const.MOD_TARGET_CAT : Const.SUPPLY,
				Const.MOD_TARGET_KEY : ["MIND_ESS"],
				Const.MOD_EFFECT : [
					{
						Const.MOD_TYPE : Const.GAIN,
						Const.MOD_SCALE : 0.1
					},
					{
						Const.MOD_TYPE : Const.CAPACITY,
						Const.MOD_SCALE : 0.1
					}
				]
			}
		]
	}

const upgrade_types := {
	"BASE_STAT" : BASE_STAT,
	"FOREST_BUFF" : FOREST_BUFF,
	"UNLOCK_AIR" : UNLOCK_AIR,
	"ENHANCE_ELEMENTS" : ENHANCE_ELEMENTS,
	"UNLOCK_MIND" : UNLOCK_MIND,
	"ENHANCE_MIND" : ENHANCE_MIND
}
