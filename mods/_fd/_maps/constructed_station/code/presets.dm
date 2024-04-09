//SPAWNERS

/obj/spawner/room/cs_station/horizontal
	room_width = 11
	room_height = 5
	room_type = "cs_horizontal"

/obj/spawner/room/cs_station/horizontal_crossroad
	room_width = 11
	room_height = 5
	room_type = "cs_horizontal_cross"

/obj/spawner/room/cs_station/vertical
	room_width = 5
	room_height = 11
	room_type = "cs_vertical"

/obj/spawner/room/cs_station/vertical_crossroad
	room_width = 5
	room_height = 11
	room_type = "cs_vertical_cross"

/obj/spawner/room/cs_station/storage
	room_width = 17
	room_height = 17
	room_type = "cs_storage"

//ROOMS

/datum/map_template/ruin/random_room/cs_station/horizontal
	name = "CS Hydroponics 1"
	template_width = 11
	template_height = 5
	stock = 10
	room_type = "cs_horizontal"
	id = "cs_horizontal_1"
	prefix = "mods/_maps/constructed_station/maps/presets/"
	suffixes = list("module_horizontal_1.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/cargo1
	name = "CS Cargo 1"
	stock = 1
	id = "cs_horizontal_2"
	suffixes = list("module_horizontal_2.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/gym
	name = "CS Gym"
	stock = 1
	id = "cs_horizontal_3"
	suffixes = list("module_horizontal_3.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/garden1
	name = "CS Garden 1"
	stock = 1
	id = "cs_horizontal_4"
	suffixes = list("module_horizontal_4.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/hospital
	name = "CS Hospital"
	stock = 1
	id = "cs_horizontal_5"
	suffixes = list("module_horizontal_5.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/refinery
	name = "CS Refinery"
	stock = 1
	id = "cs_horizontal_6"
	suffixes = list("module_horizontal_6.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/cargo2
	name = "CS Cargo 2"
	stock = 1
	id = "cs_horizontal_7"
	suffixes = list("module_horizontal_7.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/archive
	name = "CS Archive"
	stock = 1
	id = "cs_horizontal_8"
	suffixes = list("module_horizontal_8.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/shower
	name = "CS Shower"
	stock = 1
	id = "cs_horizontal_9"
	suffixes = list("module_horizontal_9.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/cargo3
	name = "CS Cargo 3"
	stock = 1
	id = "cs_horizontal_10"
	suffixes = list("module_horizontal_10.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/water1
	name = "CS Water Supply 1"
	stock = 1
	id = "cs_horizontal_11"
	suffixes = list("module_horizontal_11.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/cryo
	name = "CS Cryo"
	stock = 1
	id = "cs_horizontal_12"
	suffixes = list("module_horizontal_12.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal/abandoned1
	name = "CS Unfinished Room 1"
	stock = 1
	id = "cs_horizontal_13"
	suffixes = list("module_horizontal_13.dmm")

///

/datum/map_template/ruin/random_room/cs_station/horizontal_cross
	name = "CS Hydroponics 2"
	template_width = 11
	template_height = 5
	stock = 2
	room_type = "cs_horizontal_cross"
	id = "cs_horizontal_cross_1"
	prefix = "mods/_fd/_maps/constructed_station/maps/"
	suffixes = list("module_horizontal_cross_1.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal_cross/cargo4
	name = "CS Cargo 4"
	stock = 1
	id = "cs_horizontal_cross_2"
	suffixes = list("module_horizontal_cross_2.dmm")

/datum/map_template/ruin/random_room/cs_station/horizontal_cross/garden2
	name = "CS Garden 2"
	stock = 1
	id = "cs_horizontal_cross_3"
	suffixes = list("module_horizontal_cross_3.dmm")

///

/datum/map_template/ruin/random_room/cs_station/vertical
	name = "CS Cargo 5"
	template_width = 5
	template_height = 11
	stock = 4
	room_type = "cs_vertical"
	id = "cs_vertical_1"
	prefix = "mods/_fd/_maps/constructed_station/maps/"
	suffixes = list("module_vertical_1.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/hydro3
	name = "CS Hydroponics 2"
	stock = 1
	id = "cs_vertical_2"
	suffixes = list("module_vertical_2.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/power
	name = "CS Sub-Station"
	stock = 1
	id = "cs_vertical_3"
	suffixes = list("module_vertical_3.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/rnd
	name = "CS RnD"
	stock = 1
	id = "cs_vertical_4"
	suffixes = list("module_vertical_4.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/server
	name = "CS Servers"
	stock = 1
	id = "cs_vertical_5"
	suffixes = list("module_vertical_5.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/robotics
	name = "CS Robotics"
	stock = 1
	id = "cs_vertical_6"
	suffixes = list("module_vertical_6.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical/abandoned2
	name = "CS Unfinished Room 2"
	stock = 1
	id = "cs_vertical_7"
	suffixes = list("module_vertical_7.dmm")

///

/datum/map_template/ruin/random_room/cs_station/vertical_cross
	name = "CS Cargo 6"
	template_width = 5
	template_height = 11
	stock = 4
	room_type = "cs_vertical_cross"
	id = "cs_vertical_cross_1"
	prefix = "mods/_fd/_maps/constructed_station/maps/"
	suffixes = list("module_vertical_cross_1.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical_cross/bedroom
	name = "CS Bedroom"
	stock = 1
	id = "cs_vertical_cross_2"
	suffixes = list("module_vertical_cross_2.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical_cross/water2
	name = "CS Water Supply 2"
	stock = 1
	id = "cs_vertical_cross_3"
	suffixes = list("module_vertical_cross_3.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical_cross/workingzone
	name = "CS Working Zone"
	stock = 1
	id = "cs_vertical_cross_4"
	suffixes = list("module_vertical_cross_4.dmm")

/datum/map_template/ruin/random_room/cs_station/vertical_cross/abandoned3
	name = "CS Unfinished Room 3"
	stock = 1
	id = "cs_vertical_cross_5"
	suffixes = list("module_vertical_cross_5.dmm")

///

/datum/map_template/ruin/random_room/cs_station/storage
	name = "CS Storage Rich"
	template_width = 17
	template_height = 17
	stock = 1
	room_type = "cs_storage"
	id = "cs_storage_1"
	prefix = "mods/_fd/_maps/constructed_station/maps/"
	suffixes = list("cargo_hold_1.dmm")

/datum/map_template/ruin/random_room/cs_station/storage/low
	name = "CS Storage Low"
	stock = 1
	id = "cs_storage_1"
	suffixes = list("cargo_hold_2.dmm")
