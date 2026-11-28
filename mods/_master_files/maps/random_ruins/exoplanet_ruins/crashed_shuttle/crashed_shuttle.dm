// mods/_maps/general_maps (maps/crashed_shuttle, code/crashed_shuttle.dm).

/datum/shuttle/autodock/overmap/graysontug
	dock_target = "graysontugrear_shuttle"
	logging_home_tag = "nav_graysontug_start"

/obj/shuttle_landmark/graysontug/start
	movable_flags = FLAGS_OFF

/obj/shuttle_landmark/graysontug/start/Initialize()
	. = ..()
	var/obj/overmap/visitable/sector = map_sectors["[z]"]
	if(sector)
		sector.add_landmark(src, "GM Tug")
