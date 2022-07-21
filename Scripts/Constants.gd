class_name Constants


const DIRECTIONS := {
	"N" : Vector2i(0,-1),
	"E" : Vector2i(1,0),
	"S" : Vector2i(0,1),
	"W" : Vector2i(-1,0),
}

const DIRECTIONS_ISO := {
	"N" : Vector2i(-1,0),
	#"NE" : Vector2i(-1,-1),
	"E" : Vector2i(0,-1),
	#"SE" : Vector2i(1,-1),
	"S" : Vector2i(1,0),
	#"SW" : Vector2i(1,1),
	"W" : Vector2i(0,1),
	#"NW" : Vector2i(-1,1)
}

const DIR_OPPOSITE := {
	"N" : "S",
	"NE" : "SW",
	"E" : "W",
	"SE" : "NW",
	"S" : "N",
	"SW" : "NE",
	"W" : "E",
	"NW" : "SE"
}
