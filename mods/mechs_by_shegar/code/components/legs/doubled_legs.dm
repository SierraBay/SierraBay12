/obj/item/mech_component/doubled_legs
	var/R_leg_type = /obj/item/mech_component/propulsion/powerloader
	var/L_leg_type = /obj/item/mech_component/propulsion/powerloader
	var/obj/item/mech_component/propulsion/R_stored_leg
	var/obj/item/mech_component/propulsion/L_stored_leg

/obj/item/mech_component/doubled_legs/Initialize()
	. = ..()
	if(!R_stored_leg)
		R_stored_leg = new R_leg_type(src)
		R_stored_leg.doubled_owner = src
	if(!L_stored_leg)
		L_stored_leg = new L_leg_type(src)
		L_stored_leg.doubled_owner = src

/obj/item/mech_component/doubled_legs/spider
	icon_state = "spiderlegs_both"
	R_leg_type = /obj/item/mech_component/propulsion/spider/right
	L_leg_type = /obj/item/mech_component/propulsion/spider

/obj/item/mech_component/doubled_legs/tracks
	icon_state = "tracks_both"
	R_leg_type = /obj/item/mech_component/propulsion/tracks/right
	L_leg_type = /obj/item/mech_component/propulsion/tracks
