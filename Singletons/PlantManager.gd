extends Node

const DISPLAY_NAME := "display_name"
const GROW_CAPACITY := "grow_capacity"
const GROW_SPEED_UNSATISFIED = "grow_speed_unsatisfied"
const GROW_SPEED_SATISFIED = "grow_speed_satisfied"
const WATER_CONSUMPTION = "water_consumption"
const PURCHASE_PRICE = "purchase_price"
const SELL_PRICE = "sell_price"

var plant_types := {
	"TULIP" : {
		"display_name" : "tulip",
		"grow_capacity" : 30,
		"grow_speed_unsatisfied" : 1,
		"grow_speed_satisfied" : 2,
		"water_consumption" : 1,
		"purchase_price" : {
			"MONEY" : 1
		},
		"sell_price" : {
			"MONEY" : 2
		}
	},
	"ROSE" : {
		"display_name" : "rose",
		"grow_capacity" : 90,
		"grow_speed_unsatisfied" : 1,
		"grow_speed_satisfied" : 3,
		"water_consumption" : 1,
		"purchase_price" : {
			"MONEY" : 5
		},
		"sell_price" : {
			"MONEY" : 10
		}
	},
	"ORCHID" : {
		"display_name" : "orchid",
		"grow_capacity" : 120,
		"grow_speed_unsatisfied" : 0,
		"grow_speed_satisfied" : 1,
		"water_consumption" : 3,
		"purchase_price" : {
			"MONEY" : 20
		},
		"sell_price" : {
			"MONEY" : 100
		}
	}
}

var garden_plots := {}

var selected_plant_key : String

func setup_garden_plots(width: int, height: int):
	for y in height:
		for x in width:
			var coord := Vector2(x,y)
			if(!garden_plots.has(coord)):
				var garden_plot : GardenPlot = GardenPlot.new()
				garden_plot.set_coord(coord)
				set_garden_plot(coord, garden_plot)

func step_garden_plots(step_time : float):
	for coord in garden_plots.keys():
		(garden_plots[coord] as GardenPlot).step(step_time)

func get_plant_type_keys() -> Array:
	return plant_types.keys()

func get_plant_type(plant_type_key : String) -> Dictionary:
	return plant_types.get(plant_type_key, {})

func get_plant_type_attribute(plant_type_key : String, attribute_key : String):
	return plant_types.get(plant_type_key, {}).get(attribute_key, null)

func set_garden_plot(coord : Vector2, garden_plot : GardenPlot):
	garden_plots[coord] = garden_plot

func get_garden_plot(coord : Vector2):
	return garden_plots.get(coord)

func set_selected_plant_key(plant_key : String):
	selected_plant_key = plant_key

func get_selected_plant_key() -> String:
	return selected_plant_key
