class_name ActionData

const action_types := {
	"PURCHASE_PLOT" : {
		Const.DISPLAY_NAME : "Purchase",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "purchase_plot"
	},
	"PURCHASE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Build",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "purchase_object",
		Const.DISPLAY : true
	},
	"UPGRADE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Upgrade",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "upgrade_object",
		Const.DISPLAY : true
	},
	"REMOVE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Remove",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "remove_object",
		Const.DISPLAY : true
	},
	"PAUSE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Pause/Unpause",
		Const.TARGET_TYPE : "Plot",
		Const.FUNC_NAME : "toggle_pause",
		Const.DISPLAY : true
	}
}
