class_name ActionData

const action_types := {
	"PURCHASE_PLOT" : {
		Const.DISPLAY_NAME : "Purchase",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "purchase_plot"
	},
	"PURCHASE_PLOT_STRUCTURE" : {
		Const.DISPLAY_NAME : "Build",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "purchase_structure",
		Const.DISPLAY : true
	},
	"UPGRADE_PLOT_STRUCTURE" : {
		Const.DISPLAY_NAME : "Upgrade",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "upgrade_structure",
		Const.DISPLAY : true
	},
	"REMOVE_PLOT_STRUCTURE" : {
		Const.DISPLAY_NAME : "Remove",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "remove_structure",
		Const.DISPLAY : true
	},
	"PAUSE_PLOT_OBJECT" : {
		Const.DISPLAY_NAME : "Pause/Unpause",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "toggle_pause",
		Const.DISPLAY : true
	},
	"EXPLORE_PLOT" : {
		Const.DISPLAY_NAME : "Explore",
		Const.TARGET_TYPE : "PlotVO",
		Const.FUNC_NAME : "explore",
		Const.DISPLAY : true
	}
}
