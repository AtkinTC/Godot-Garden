class_name UpgradeData

const upgrade_types := {
	"ENHANCE_ELEMENTS" : {
		Const.DISPLAY_NAME : "elemental focus",
		Const.PURCHASE_COST : {
			"AIR_ESS" : 15,
			"EARTH_ESS" : 15,
			"FIRE_ESS" : 15,
			"WATER_ESS" : 15
		},
		Const.REBUY : {
			Const.PRICE_MODIFIER_TYPE : Const.PRICE_MODIFIER_FLAT_LEVEL
		},
		Const.MODIFIER : [
			{
				Const.MODIFIER_TARGET_CATEGORY : Const.SUPPLY,
				Const.MODIFIER_TARGET_KEYS : ["AIR_ESS", "EARTH_ESS", "FIRE_ESS", "WATER_ESS"],
				Const.MODIFIER : [
					{
						Const.MODIFIER_TYPE : Const.GAIN,
						Const.MODIFIER_SCALE : 0.1
					},
					{
						Const.MODIFIER_TYPE : Const.CAPACITY,
						Const.MODIFIER_SCALE : 0.1
					}
				]
			}
		]
	},
	"UNLOCK_MIND" : {
		Const.DISPLAY_NAME : "path of the mind",
		Const.PURCHASE_COST : {
			"AIR_ESS" : 10,
			"EARTH_ESS" : 10,
			"FIRE_ESS" : 10,
			"WATER_ESS" : 10
		},
		Const.UNLOCK : [
			{
				Const.UNLOCK_KEY : "MIND_ESS",
				Const.UNLOCK_TYPE : Const.SUPPLY
			},
			{
				Const.UNLOCK_KEY : "MIND_SOURCE_BASIC",
				Const.UNLOCK_TYPE : Const.OBJECT
			},
			{
				Const.UNLOCK_KEY : "ENHANCE_MIND_001",
				Const.UNLOCK_TYPE : Const.UPGRADE
			}
		]
	},
	"ENHANCE_MIND_001" : {
		Const.DISPLAY_NAME : "enhance mind",
		Const.LOCKED : true,
		Const.PURCHASE_COST : {
			"AIR_ESS" : 10,
			"EARTH_ESS" : 10,
			"FIRE_ESS" : 10,
			"WATER_ESS" : 10
		}
	}
}
