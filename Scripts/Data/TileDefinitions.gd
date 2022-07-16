class_name TileDefinitions

const neighbors_road_n := ["road_NS", "road_SE", "road_SW", "road_SEW", "road_NSE", "road_NSW", "river_bridge_EW", "road_NSEW"]
const neighbors_road_s := ["road_NS", "road_NE", "road_NW", "road_NEW", "road_NSE", "road_NSW", "river_bridge_EW", "road_NSEW"]
const neighbors_road_e := ["road_EW", "road_SW", "road_NW", "road_NEW", "road_SEW", "road_NSW", "river_bridge_NS", "road_NSEW"]
const neighbors_road_w := ["road_EW", "road_NE", "road_SE", "road_NEW", "road_SEW", "road_NSE", "river_bridge_NS", "road_NSEW"]
const neighbors_river_n := ["river_S", "river_NS", "river_SE", "river_SW", "river_SEW", "river_NSE", "river_NSW", "river_bridge_NS", "river_NSEW"]
const neighbors_river_s := ["river_N", "river_NS", "river_NE", "river_NW", "river_NEW", "river_NSE", "river_NSW", "river_bridge_NS", "river_NSEW"]
const neighbors_river_e := ["river_W", "river_EW", "river_NW", "river_SW", "river_NEW", "river_SEW", "river_NSW", "river_bridge_EW", "river_NSEW"]
const neighbors_river_w := ["river_E", "river_EW", "river_NE", "river_SE", "river_NEW", "river_SEW", "river_NSE", "river_bridge_EW", "river_NSEW"]

const cell_defs := {
	"empty" : {},
	"field" : {},
	"forest" : {},
	"swamp" : {},
	"cave" : {},
	"road_N" : {
		"N" : neighbors_road_n
	},
	"road_S" : {
		"S" : neighbors_road_s
	},
	"road_E" : {
		"E" : neighbors_road_e
	},
	"road_W" : {
		"W" : neighbors_road_w
	},
	"road_NS" : {
		"N" : neighbors_road_n,
		"S" : neighbors_road_s
	},
	"road_EW" : {
		"E" : neighbors_road_e,
		"W" : neighbors_road_w
	},
	"road_NE" : {
		"N" : neighbors_road_n,
		"E" : neighbors_road_e
	},
	"road_SE" : {
		"S" : neighbors_road_s,
		"E" : neighbors_road_e
	},
	"road_SW" : {
		"S" : neighbors_road_s,
		"W" : neighbors_road_w
	},
	"road_NW" : {
		"N" : neighbors_road_n,
		"W" : neighbors_road_w
	},
	"road_NEW" : {
		"N" : neighbors_road_n,
		"E" : neighbors_road_e,
		"W" : neighbors_road_w
	},
	"road_NSE" : {
		"N" : neighbors_road_n,
		"S" : neighbors_road_s,
		"E" : neighbors_road_e
	},
	"road_SEW" : {
		"S" : neighbors_road_s,
		"E" : neighbors_road_e,
		"W" : neighbors_road_w
	},
	"road_NSW" : {
		"N" : neighbors_road_n,
		"S" : neighbors_road_s,
		"W" : neighbors_road_w
	},
	"road_NSEW" : {
		"N" : neighbors_road_n,
		"S" : neighbors_road_s,
		"E" : neighbors_road_e,
		"W" : neighbors_road_w
	},
	"river" : {},
	"river_N" : {
		"N" : neighbors_river_n
	},
	"river_S" : {
		"S" : neighbors_river_s
	},
	"river_E" : {
		"E" : neighbors_river_e
	},
	"river_W" : {
		"W" : neighbors_river_w
	},
	"river_NS" : {
		"N" : neighbors_river_n,
		"S" : neighbors_river_s
	},
	"river_EW" : {
		"E" : neighbors_river_e,
		"W" : neighbors_river_w
	},
	"river_NE" : {
		"N" : neighbors_river_n,
		"E" : neighbors_river_e
	},
	"river_SE" : {
		"S" : neighbors_river_s,
		"E" : neighbors_river_e
	},
	"river_SW" : {
		"S" : neighbors_river_s,
		"W" : neighbors_river_w
	},
	"river_NW" : {
		"N" : neighbors_river_n,
		"W" : neighbors_river_w
	},
	"river_NEW" : {
		"N" : neighbors_river_n,
		"E" : neighbors_river_e,
		"W" : neighbors_river_w
	},
	"river_NSE" : {
		"N" : neighbors_river_n,
		"S" : neighbors_river_s,
		"E" : neighbors_river_e
	},
	"river_SEW" : {
		"S" : neighbors_river_s,
		"E" : neighbors_river_e,
		"W" : neighbors_river_w
	},
	"river_NSW" : {
		"N" : neighbors_river_n,
		"S" : neighbors_river_s,
		"W" : neighbors_river_w
	},
	"river_bridge_NS" : {
		"N" : neighbors_river_n,
		"S" : neighbors_river_s,
		"E" : neighbors_road_e,
		"W" : neighbors_road_w
	},
	"river_bridge_EW" : {
		"N" : neighbors_road_n,
		"S" : neighbors_road_s,
		"E" : neighbors_river_e,
		"W" : neighbors_river_w
	},
	"river_NSEW" : {
		"N" : neighbors_river_n,
		"S" : neighbors_river_s,
		"E" : neighbors_river_e,
		"W" : neighbors_river_w
	},
	"lake_inner" : {
		"N" : ["lake_N", "lake_river_N", "lake_inner"],
		"S" : ["lake_S", "lake_river_S", "lake_inner"],
		"E" : ["lake_E", "lake_river_E", "lake_inner"],
		"W" : ["lake_W", "lake_river_W", "lake_inner"]
	},
	"lake_N" : {
		"S" : ["lake_S", "lake_river_S", "lake_inner"],
		"E" : ["lake_N", "lake_river_N", "lake_NE"],
		"W" : ["lake_N", "lake_river_N", "lake_NW"],
	},
	"lake_S" : {
		"N" : ["lake_N", "lake_river_N", "lake_inner"],
		"E" : ["lake_S", "lake_river_S", "lake_SE"],
		"W" : ["lake_S", "lake_river_S", "lake_SW"]
	},
	"lake_E" : {
		"N" : ["lake_E", "lake_river_E", "lake_NE"],
		"S" : ["lake_E", "lake_river_E", "lake_SE"],
		"W" : ["lake_W", "lake_river_W", "lake_inner"]
	},
	"lake_W" : {
		"N" : ["lake_W", "lake_river_W", "lake_NW"],
		"S" : ["lake_W", "lake_river_W", "lake_SW"],
		"E" : ["lake_E", "lake_river_E", "lake_inner"]
	},
	"lake_NE" : {
		"S" : ["lake_E", "lake_river_E", "lake_SE"],
		"W" : ["lake_N", "lake_river_N", "lake_NW"]
	},
	"lake_SE" : {
		"N" : ["lake_E", "lake_river_E", "lake_NE"],
		"W" : ["lake_S", "lake_river_S", "lake_SW"]
	},
	"lake_SW" : {
		"N" : ["lake_W", "lake_river_W", "lake_NW"],
		"E" : ["lake_S", "lake_river_S", "lake_SE"]
	},
	"lake_NW" : {
		"S" : ["lake_W", "lake_river_W", "lake_SW"],
		"E" : ["lake_N", "lake_river_N", "lake_NE"]
	},
	"lake_river_N" : {
		"N" : neighbors_river_n,
		"S" : ["lake_S", "lake_inner"],
		"E" : ["lake_N", "lake_NE"],
		"W" : ["lake_N", "lake_NW"],
	},
	"lake_river_S" : {
		"S" : neighbors_river_s,
		"N" : ["lake_N", "lake_inner"],
		"E" : ["lake_S", "lake_SE"],
		"W" : ["lake_S", "lake_SW"]
	},
	"lake_river_E" : {
		"E" : neighbors_river_e,
		"N" : ["lake_E", "lake_NE"],
		"S" : ["lake_E", "lake_SE"],
		"W" : ["lake_W", "lake_inner"]
	},
	"lake_river_W" : {
		"W" : neighbors_river_w,
		"N" : ["lake_W", "lake_NW"],
		"S" : ["lake_W", "lake_SW"],
		"E" : ["lake_E", "lake_inner"]
	},
}
