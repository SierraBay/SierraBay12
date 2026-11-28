// mods/_maps/general_maps (maps/transshipment, code/transshipment.dm).

/datum/shuttle/autodock/overmap/old_snz
	logging_home_tag = "nav_oldsnz_start"

/obj/shuttle_landmark/old_snz/start
	movable_flags = FLAGS_OFF

/obj/shuttle_landmark/old_snz/start/Initialize()
	. = ..()
	var/obj/overmap/visitable/sector = map_sectors["[z]"]
	if(sector)
		sector.add_landmark(src, "SNZ-210 Personnel Carrier")
