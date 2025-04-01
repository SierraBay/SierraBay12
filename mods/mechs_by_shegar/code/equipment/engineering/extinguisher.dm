/obj/item/mech_equipment/mounted_system/extinguisher
	icon_state = "mech_exting"
	heat_generation = 5
	holding_type = /obj/item/extinguisher/mech
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_ENGINEERING)

/obj/item/extinguisher/mech
	max_water = 4000 //Good is gooder
	starting_water = 4000
	icon_state = "mech_exting"

/obj/item/extinguisher/mech/get_hardpoint_maptext()
	return "[reagents.total_volume]/[max_water]"

/obj/item/extinguisher/mech/get_hardpoint_status_value()
	return reagents.total_volume/max_water

