/datum/map_template/ruin/random_room/facility
	name = "Facility Random Room Framework" // The SSmapping random_room_template list is ordered by the name
	prefix = "mods/_maps/facility/maps/presets/"

/obj/spawner/room/facility
	name = "facility room spawner"
	icon_state = "closet-red"
	dir = NORTH




/obj/spawner/room/facility/hallway
	name = "facility hallway spawner"
	icon_state = "out-blue"
	room_width = 10
	room_height = 10

/datum/map_template/ruin/random_room/facility/hallways
	name = "Facility Hallways"
	template_width = 10
	template_height = 10

//	HORIZONTAL HALLWAYS

/obj/spawner/room/facility/hallway/horisontal
	name = "facility horisontal hallway spawner"
	icon_state = "horisontal"
	room_type = "facility_hallway_hor"

/datum/map_template/ruin/random_room/facility/hallways/horisontal
	name = "Facility Hallways Horisontal 1"
	room_type = "facility_hallway_hor"
	id = "facility_hallway_hor_1"
	suffixes = list("hallway_2.dmm")
	stock = 50

/datum/map_template/ruin/random_room/facility/hallways/horisontal/two
	name = "Facility Hallways Horisontal 2"
	id = "facility_hallway_hor_2"
	suffixes = list("hallway_2-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/horisontal/three
	name = "Facility Hallways Horisontal 3"
	id = "facility_hallway_hor_3"
	suffixes = list("hallway_2-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/horisontal/four
	name = "Facility Hallways Horisontal 4"
	id = "facility_hallway_hor_4"
	suffixes = list("hallway_2-3.dmm")
	stock = 20

/datum/map_template/ruin/random_room/facility/hallways/horisontal/five
	name = "Facility Hallways Horisontal 5"
	id = "facility_hallway_hor_5"
	suffixes = list("hallway_2-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/horisontal/six
	name = "Facility Hallways Horisontal 6"
	id = "facility_hallway_hor_6"
	suffixes = list("hallway_2-5.dmm")

//	VERTICAL HALLWAYS

/obj/spawner/room/facility/hallway/vertical
	name = "facility vertical hallway spawner"
	icon_state = "vertical"
	room_type = "facility_hallway_ver"

/datum/map_template/ruin/random_room/facility/hallways/vertical
	name = "Facility Hallways Vertical 1"
	room_type = "facility_hallway_ver"
	id = "facility_hallway_ver_1"
	suffixes = list("hallway_1.dmm")
	stock = 50

/datum/map_template/ruin/random_room/facility/hallways/vertical/two
	name = "Facility Hallways Vertical 2"
	id = "facility_hallway_ver_2"
	suffixes = list("hallway_1-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/vertical/three
	name = "Facility Hallways Vertical 3"
	id = "facility_hallway_ver_3"
	suffixes = list("hallway_1-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/vertical/four
	name = "Facility Hallways Vertical 4"
	id = "facility_hallway_ver_4"
	suffixes = list("hallway_1-3.dmm")
	stock = 20

//	CROSS HALLWAYS

/obj/spawner/room/facility/hallway/cross
	name = "facility cross hallway spawner"
	icon_state = "cross"
	room_type = "facility_hallway_cross"

/datum/map_template/ruin/random_room/facility/hallways/cross
	name = "Facility Hallways cross 1"
	room_type = "facility_hallway_cross"
	id = "facility_hallway_cross_1"
	suffixes = list("cross_1.dmm")
	stock = 90

/datum/map_template/ruin/random_room/facility/hallways/cross/two
	name = "Facility Hallways cross 2"
	id = "facility_hallway_cross_2"
	suffixes = list("cross_1-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/cross/three
	name = "Facility Hallways cross 3"
	id = "facility_hallway_cross_3"
	suffixes = list("cross_1-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/cross/four
	name = "Facility Hallways cross 4"
	id = "facility_hallway_cross_4"
	suffixes = list("cross_1-3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/cross/five
	name = "Facility Hallways cross 5"
	id = "facility_hallway_cross_5"
	suffixes = list("cross_1-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/cross/six
	name = "Facility Hallways cross 6"
	id = "facility_hallway_cross_6"
	suffixes = list("cross_1-5.dmm")

// HALLWAYS ROOMS

/obj/spawner/room/facility/hallway/room
	name = "facility horisontal hallway room spawner"
	icon_state = "radnomstuff-orange"
	room_type = "facility_hallway_room"
	room_width = 10
	room_height = 13

/datum/map_template/ruin/random_room/facility/hallways/room
	name = "Facility Hallways Room 1"
	room_type = "facility_hallway_room"
	id = "facility_hallway_room_1"
	suffixes = list("hallway_room1.dmm")
	stock = 20
	template_width = 10
	template_height = 13

/datum/map_template/ruin/random_room/facility/hallways/room/two
	name = "Facility Hallways Room 2"
	id = "facility_hallway_room_2"
	suffixes = list("hallway_room2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/room/three
	name = "Facility Hallways Room 3"
	id = "facility_hallway_room_3"
	suffixes = list("hallway_room3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/room/four
	name = "Facility Hallways Room 4"
	id = "facility_hallway_room_4"
	suffixes = list("hallway_room4.dmm")

// HALLWAYS DEAD-END ROOMS

/obj/spawner/room/facility/hallway/end
	name = "facility end room spawner"
	icon_state = "radnomstuff-orange"
	room_type = "facility_dead-end_room"
	room_width = 10
	room_height = 10


/obj/spawner/room/facility/hallway/end/east
	name = "facility east end room spawner"
	icon_state = "right-blue"
	room_type = "facility_dead-end_room_east"

/obj/spawner/room/facility/hallway/end/north
	name = "facility north end room spawner"
	icon_state = "out-blue"
	room_type = "facility_dead-end_room_north"

/obj/spawner/room/facility/hallway/end/south
	name = "facility south end room spawner"
	icon_state = "in-blue"
	room_type = "facility_dead-end_room_south"

/obj/spawner/room/facility/hallway/end/west
	name = "facility west end room spawner"
	icon_state = "left-blue"
	room_type = "facility_dead-end_room_west"


/datum/map_template/ruin/random_room/facility/hallways/end
	name = "Facility Hallways End Room"
	room_type = "facility_dead-end_room"
	id = "facility_hallway_end_"
	suffixes = list("room_10.dmm")
	stock = 50
	template_width = 10
	template_height = 10

// EAST

/datum/map_template/ruin/random_room/facility/hallways/end/east1
	name = "Facility East End Room 1"
	room_type = "facility_dead-end_room_east"
	id = "facility_hallway_end_east1"
	suffixes = list("room_10_east-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/east2
	name = "Facility East End Room 2"
	room_type = "facility_dead-end_room_east"
	id = "facility_hallway_end_east2"
	suffixes = list("room_10_east-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/east3
	name = "Facility East End Room 3"
	room_type = "facility_dead-end_room_east"
	id = "facility_hallway_end_east3"
	suffixes = list("room_10_east-3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/east4
	name = "Facility East End Room 4"
	room_type = "facility_dead-end_room_east"
	id = "facility_hallway_end_east4"
	suffixes = list("room_10_east-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/east5
	name = "Facility East End Room 5"
	room_type = "facility_dead-end_room_east"
	id = "facility_hallway_end_east5"
	suffixes = list("room_10_east-5.dmm")

// NORTH

/datum/map_template/ruin/random_room/facility/hallways/end/north1
	name = "Facility North End Room 1"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north1"
	suffixes = list("room_10_north-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/north2
	name = "Facility North End Room 2"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north2"
	suffixes = list("room_10_north-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/north3
	name = "Facility North End Room 3"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north3"
	suffixes = list("room_10_north-3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/north4
	name = "Facility North End Room 4"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north4"
	suffixes = list("room_10_north-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/north5
	name = "Facility North End Room 5"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north5"
	suffixes = list("room_10_north-5.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/north6
	name = "Facility North End Room 6"
	room_type = "facility_dead-end_room_north"
	id = "facility_hallway_end_north6"
	suffixes = list("room_10_north-6.dmm")

// WEST

/datum/map_template/ruin/random_room/facility/hallways/end/west1
	name = "Facility West End Room 1"
	room_type = "facility_dead-end_room_west"
	id = "facility_hallway_end_west1"
	suffixes = list("room_10_west-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/west2
	name = "Facility West End Room 2"
	room_type = "facility_dead-end_room_west"
	id = "facility_hallway_end_west2"
	suffixes = list("room_10_west-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/west3
	name = "Facility West End Room 3"
	room_type = "facility_dead-end_room_west"
	id = "facility_hallway_end_west3"
	suffixes = list("room_10_west-3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/west4
	name = "Facility West End Room 4"
	room_type = "facility_dead-end_room_west"
	id = "facility_hallway_end_west4"
	suffixes = list("room_10_west-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/west5
	name = "Facility West End Room 5"
	room_type = "facility_dead-end_room_west"
	id = "facility_hallway_end_west5"
	suffixes = list("room_10_west-5.dmm")

// SOUTH

/datum/map_template/ruin/random_room/facility/hallways/end/south1
	name = "Facility South End Room 1"
	room_type = "facility_dead-end_room_south"
	id = "facility_hallway_end_south1"
	suffixes = list("room_10_south-1.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/south2
	name = "Facility South End Room 2"
	room_type = "facility_dead-end_room_south"
	id = "facility_hallway_end_south2"
	suffixes = list("room_10_south-2.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/south3
	name = "Facility South End Room 3"
	room_type = "facility_dead-end_room_south"
	id = "facility_hallway_end_south3"
	suffixes = list("room_10_south-3.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/south4
	name = "Facility South End Room 4"
	room_type = "facility_dead-end_room_south"
	id = "facility_hallway_end_south4"
	suffixes = list("room_10_south-4.dmm")

/datum/map_template/ruin/random_room/facility/hallways/end/south5
	name = "Facility South End Room 5"
	room_type = "facility_dead-end_room_south"
	id = "facility_hallway_end_south5"
	suffixes = list("room_10_south-5.dmm")



// 20 x 20 ROOMS

/obj/spawner/room/facility/room20
	name = "facility 20 x 20 room spawner"
	icon_state = "square"
	room_type = "facility_20_room"
	room_width = 20
	room_height = 20

/datum/map_template/ruin/random_room/facility/room20
	name = "Facility Mess Hall Room"
	room_type = "facility_20_room"
	id = "facility_20room_mess"
	suffixes = list("room_20-mess.dmm")
	stock = 1
	template_width = 20
	template_height = 20

/datum/map_template/ruin/random_room/facility/room20/ending
	name = "Facility Ending Room"
	id = "facility_20room_end"
	suffixes = list("room_20-ending.dmm")

/datum/map_template/ruin/random_room/facility/room20/lab
	name = "Facility Lab Room"
	id = "facility_20room_lab"
	suffixes = list("room_20-lab.dmm")

/datum/map_template/ruin/random_room/facility/room20/living
	name = "Facility Living Room"
	id = "facility_20room_living"
	suffixes = list("room_20-living.dmm")

/datum/map_template/ruin/random_room/facility/room20/medbay
	name = "Facility Medbay Room"
	id = "facility_20room_medbay"
	suffixes = list("room_20-medbay.dmm")

/datum/map_template/ruin/random_room/facility/room20/security
	name = "Facility Security Room"
	id = "facility_20room_security"
	suffixes = list("room_20-security.dmm")

/datum/map_template/ruin/random_room/facility/room20/start
	name = "Facility Start Room"
	id = "facility_20room_start"
	suffixes = list("room_20-start.dmm")
