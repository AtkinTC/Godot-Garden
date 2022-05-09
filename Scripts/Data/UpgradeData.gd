class_name UpgradeData

const upgrade_types := {
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
				Const.UNLOCK_TYPE : "SUPPLY"
			},
			{
				Const.UNLOCK_KEY : "MIND_SOURCE_BASIC",
				Const.UNLOCK_TYPE : "OBJECT"
			},
			{
				Const.UNLOCK_KEY : "ENHANCE_MIND_001",
				Const.UNLOCK_TYPE : "UPGRADE"
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
