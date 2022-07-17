class_name TileDefinitions

const CELL := "cell"
const BORDER := "border"
const RESTRICTED := "restricted"
const MANUAL := "manual"

const border_open := "b_open"
const border_road := "b_road"
const border_river := "b_river"
const border_lake := "b_lake"
const border_coast_1 := "b_coast_1" # N->S E->W
const border_coast_2 := "b_coast_2" # S->N W->E

const restricted_road_end := "r_road_end"
const restricted_road_bend := "r_road_bend"
const restricted_road_parallel := "r_road_parallel"

const restricted_river_end := "r_river_end"
const restricted_river_bend := "r_river_bend"
const restricted_river_parallel := "r_river_parallel"

const restricted_lake_parallel := "r_lake_parallel"

const cell_defs := {
	"empty" : {},
	"base" : {
		"N" : border_road,
		"S" : border_road,
		RESTRICTED : {
			"N" : [restricted_river_parallel, restricted_lake_parallel],
			"S" : [restricted_river_parallel, restricted_lake_parallel],
			"E" : [restricted_river_parallel, restricted_lake_parallel],
			"W" : [restricted_river_parallel, restricted_lake_parallel],
		},
		MANUAL : true
	},
	"field" : {},
	"forest" : {},
	"swamp" : {},
	"cave" : {},
#	"road_N" : {
#		"N" : border_road,
#		RESTRICTED : {
#			"N" : [restricted_road_end],
#			"S" : [restricted_road_parallel],
#			"E" : [restricted_road_parallel],
#			"W" : [restricted_road_parallel],
#		}
#	},
#	"road_S" : {
#		"S" : border_road,
#		RESTRICTED : {
#			"N" : [restricted_road_parallel],
#			"S" : [restricted_road_end],
#			"E" : [restricted_road_parallel],
#			"W" : [restricted_road_parallel],
#		}
#	},
#	"road_E" : {
#		"E" : border_road,
#		RESTRICTED : {
#			"N" : [restricted_road_parallel],
#			"S" : [restricted_road_parallel],
#			"E" : [restricted_road_end],
#			"W" : [restricted_road_parallel],
#		}
#	},
#	"road_W" : {
#		"W" : border_road,
#		RESTRICTED : {
#			"N" : [restricted_road_parallel],
#			"S" : [restricted_road_parallel],
#			"E" : [restricted_road_parallel],
#			"W" : [restricted_road_end],
#		}
#	},
	"road_NS" : {
		"N" : border_road,
		"S" : border_road,
		RESTRICTED : {
			"E" : [restricted_road_parallel],
			"W" : [restricted_road_parallel],
		}
	},
	"road_EW" : {
		"E" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_parallel],
			"S" : [restricted_road_parallel],
		}
	},
	"road_NE" : {
		"N" : border_road,
		"E" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_parallel],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_parallel],
		}
	},
	"road_SE" : {
		"S" : border_road,
		"E" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_parallel],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_parallel],
		}
	},
	"road_SW" : {
		"S" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_parallel],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_parallel],
			"W" : [restricted_road_bend],
		}
	},
	"road_NW" : {
		"N" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_parallel],
			"E" : [restricted_road_parallel],
			"W" : [restricted_road_bend],
		}
	},
	"road_NEW" : {
		"N" : border_road,
		"E" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_parallel],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_bend],
		}
	},
	"road_NSE" : {
		"N" : border_road,
		"S" : border_road,
		"E" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_parallel],
		}
	},
	"road_SEW" : {
		"S" : border_road,
		"E" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_parallel],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_bend],
		}
	},
	"road_NSW" : {
		"N" : border_road,
		"S" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_parallel],
			"W" : [restricted_road_bend],
		}
	},
	"road_NSEW" : {
		"N" : border_road,
		"S" : border_road,
		"E" : border_road,
		"W" : border_road,
		RESTRICTED : {
			"N" : [restricted_road_bend],
			"S" : [restricted_road_bend],
			"E" : [restricted_road_bend],
			"W" : [restricted_road_bend],
		}
	},
#	"river" : {},
#	"river_N" : {
#		"N" : border_river,
#		RESTRICTED :{
#			"N" : [restricted_river_end],
#			"S" : [restricted_river_parallel],
#			"E" : [restricted_river_parallel],
#			"W" : [restricted_river_parallel],
#		}
#	},
#	"river_S" : {
#		"S" : border_river,
#		RESTRICTED :{
#			"N" : [restricted_river_parallel],
#			"S" : [restricted_river_end],
#			"E" : [restricted_river_parallel],
#			"W" : [restricted_river_parallel],
#		}
#	},
#	"river_E" : {
#		"E" : border_river,
#		RESTRICTED :{
#			"N" : [restricted_river_parallel],
#			"S" : [restricted_river_parallel],
#			"E" : [restricted_river_end],
#			"W" : [restricted_river_parallel],
#		}
#	},
#	"river_W" : {
#		"W" : border_river,
#		RESTRICTED :{
#			"N" : [restricted_river_parallel],
#			"S" : [restricted_river_parallel],
#			"E" : [restricted_river_parallel],
#			"W" : [restricted_river_end],
#		}
#	},
	"river_NS" : {
		"N" : border_river,
		"S" : border_river,
		RESTRICTED :{
			"N" : [],
			"S" : [],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_parallel],
		}
	},
	"river_EW" : {
		"E" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_parallel],
			"E" : [],
			"W" : [],
		}
	},
	"river_NE" : {
		"N" : border_river,
		"E" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_end, restricted_river_bend],
			"S" : [restricted_river_parallel],
			"E" : [restricted_river_end, restricted_river_bend],
			"W" : [restricted_river_parallel],
		}
	},
	"river_SE" : {
		"S" : border_river,
		"E" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_end, restricted_river_bend],
			"E" : [restricted_river_end, restricted_river_bend],
			"W" : [restricted_river_parallel],
		}
	},
	"river_SW" : {
		"S" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_end, restricted_river_bend],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_end, restricted_river_bend],
		}
	},
	"river_NW" : {
		"N" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_end, restricted_river_bend],
			"S" : [restricted_river_parallel],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_end, restricted_river_bend],
		}
	},
	"river_NEW" : {
		"N" : border_river,
		"E" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_bend],
			"S" : [restricted_river_parallel],
			"E" : [restricted_river_bend],
			"W" : [restricted_river_bend],
		}
	},
	"river_NSE" : {
		"N" : border_river,
		"S" : border_river,
		"E" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_bend],
			"S" : [restricted_river_bend],
			"E" : [restricted_river_bend],
			"W" : [restricted_river_parallel],
		}
	},
	"river_SEW" : {
		"S" : border_river,
		"E" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_bend],
			"E" : [restricted_river_bend],
			"W" : [restricted_river_bend],
		}
	},
	"river_NSW" : {
		"N" : border_river,
		"S" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_bend],
			"S" : [restricted_river_bend],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_bend],
		}
	},
	"river_bridge_NS" : {
		"N" : border_river,
		"S" : border_river,
		"E" : border_road,
		"W" : border_road,
		RESTRICTED :{
			"N" : [restricted_river_end, restricted_river_bend, restricted_road_parallel],
			"S" : [restricted_river_end, restricted_river_bend, restricted_road_parallel],
			"E" : [restricted_road_end, restricted_river_parallel],
			"W" : [restricted_road_end, restricted_river_parallel],
		}
	},
	"river_bridge_EW" : {
		"N" : border_road,
		"S" : border_road,
		"E" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_road_end, restricted_river_parallel],
			"S" : [restricted_road_end, restricted_river_parallel],
			"E" : [restricted_river_end, restricted_river_bend, restricted_road_parallel],
			"W" : [restricted_river_end, restricted_river_bend, restricted_road_parallel],
		}
	},
	"river_NSEW" : {
		"N" : border_river,
		"S" : border_river,
		"E" : border_river,
		"W" : border_river,
		RESTRICTED :{
			"N" : [restricted_river_bend],
			"S" : [restricted_river_bend],
			"E" : [restricted_river_bend],
			"W" : [restricted_river_bend],
		}
	},
	"lake_inner" : {
		"N" : border_lake,
		"S" : border_lake,
		"E" : border_lake,
		"W" : border_lake,
		RESTRICTED : {
			"N" : [],
			"S" : [],
			"E" : [],
			"W" : [],
		}
	},
	"lake_coast_N" : {
		"S" : border_lake,
		"E" : border_coast_1,
		"W" : border_coast_1,
		RESTRICTED : {
			"N" : [restricted_lake_parallel, restricted_river_parallel],
			"S" : [],
			"E" : [],
			"W" : [],
		}
	},
	"lake_coast_S" : {
		"N" : border_lake,
		"E" : border_coast_2,
		"W" : border_coast_2,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_lake_parallel, restricted_river_parallel],
			"E" : [],
			"W" : [],
		}
	},
	"lake_coast_E" : {
		"N" : border_coast_1,
		"S" : border_coast_1,
		"W" : border_lake,
		RESTRICTED : {
			"N" : [],
			"S" : [],
			"E" : [restricted_lake_parallel, restricted_river_parallel],
			"W" : [],
		}
	},
	"lake_coast_W" : {
		"N" : border_coast_2,
		"S" : border_coast_2,
		"E" : border_lake,
		RESTRICTED : {
			"N" : [],
			"S" : [],
			"E" : [],
			"W" : [restricted_lake_parallel, restricted_river_parallel],
		}
	},
	"lake_coast_outer_NE" : {
		"S" : border_coast_1,
		"W" : border_coast_1,
		RESTRICTED : {
			"N" : [restricted_river_parallel],
			"S" : [],
			"E" : [restricted_river_parallel],
			"W" : [],
		}
	},
	"lake_coast_outer_SE" : {
		"N" : border_coast_1,
		"W" : border_coast_2,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_river_parallel],
			"E" : [restricted_river_parallel],
			"W" : [],
		}
	},
	"lake_coast_outer_SW" : {
		"N" : border_coast_2,
		"E" : border_coast_2,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_river_parallel],
			"E" : [],
			"W" : [restricted_river_parallel],
		}
	},
	"lake_coast_outer_NW" : {
		"S" : border_coast_2,
		"E" : border_coast_1,
		RESTRICTED : {
			"N" : [restricted_river_parallel],
			"S" : [],
			"E" : [],
			"W" : [restricted_river_parallel],
		}
	},
	"lake_coast_inner_NE" : {
		"N" : border_coast_1,
		"S" : border_lake,
		"E" : border_coast_1,
		"W" : border_lake,
		RESTRICTED : {
			"N" : [restricted_river_parallel, restricted_lake_parallel],
			"S" : [],
			"E" : [restricted_river_parallel, restricted_lake_parallel],
			"W" : [],
		}
	},
	"lake_coast_inner_SE" : {
		"N" : border_lake,
		"S" : border_coast_1,
		"E" : border_coast_2,
		"W" : border_lake,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_river_parallel, restricted_lake_parallel],
			"E" : [restricted_river_parallel, restricted_lake_parallel],
			"W" : [],
		}
	},
	"lake_coast_inner_SW" : {
		"N" : border_lake,
		"S" : border_coast_2,
		"E" : border_lake,
		"W" : border_coast_2,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_river_parallel, restricted_lake_parallel],
			"E" : [],
			"W" : [restricted_river_parallel, restricted_lake_parallel],
		}
	},
	"lake_coast_inner_NW" : {
		"N" : border_coast_2,
		"S" : border_lake,
		"E" : border_lake,
		"W" : border_coast_1,
		RESTRICTED : {
			"N" : [restricted_river_parallel, restricted_lake_parallel],
			"S" : [],
			"E" : [],
			"W" : [restricted_river_parallel, restricted_lake_parallel],
		}
	},
	"lake_river_N" : {
		"N" : border_river,
		"S" : border_lake,
		"E" : border_coast_1,
		"W" : border_coast_1,
		RESTRICTED : {
			"N" : [restricted_river_end, restricted_river_bend],
			"S" : [],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_parallel],
		}
	},
	"lake_river_S" : {
		"N" : border_lake,
		"S" : border_river,
		"E" : border_coast_2,
		"W" : border_coast_2,
		RESTRICTED : {
			"N" : [],
			"S" : [restricted_river_end, restricted_river_bend],
			"E" : [restricted_river_parallel],
			"W" : [restricted_river_parallel],
		}
	},
	"lake_river_E" : {
		"N" : border_coast_1,
		"S" : border_coast_1,
		"E" : border_river,
		"W" : border_lake,
		RESTRICTED : {
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_parallel],
			"E" : [restricted_river_end, restricted_river_bend],
			"W" : [],
		}
	},
	"lake_river_W" : {
		"N" : border_coast_2,
		"S" : border_coast_2,
		"E" : border_lake,
		"W" : border_river,
		RESTRICTED : {
			"N" : [restricted_river_parallel],
			"S" : [restricted_river_parallel],
			"E" : [],
			"W" : [restricted_river_end, restricted_river_bend],
		}
	},
}
