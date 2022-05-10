class_name ActionData

const action_types := {
	"PURCHASE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Build",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "purchase_object"
	},
	"UPGRADE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Upgrade",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "upgrade_object"
	},
	"REMOVE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Remove",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "remove_object"
	},
	"PAUSE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Pause/Unpause",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "toggle_pause"
	}
}
