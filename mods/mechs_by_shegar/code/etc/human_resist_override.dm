/mob/living/process_resist()
	.=..()
	if(istype(loc, /obj/item/mech_component/passenger_compartment)) // Если прожал resist пассажир меха
		var/mob/living/exosuit/M = loc.loc
		var/obj/item/mech_component/passenger_compartment/C = loc
		if((src in C.back_passenger) || (src in C.left_back_passenger) || (src in C.right_back_passenger))
			if(M.leave_passenger(src))
				return TRUE

	if(istype(loc, /mob/living/exosuit)) // Если прожал resist пилот меха
		var/mob/living/exosuit/C = loc
		if(C.passengers_ammount > 1)
			var/list/options = list(
				"Левый бок" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "left shoulder"),
				"Спина" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "head"),
				"Правый бок" = mutable_appearance('mods/mechs_by_shegar/icons/radial_menu.dmi', "right shoulder")
				)
			var/choosed_place = show_radial_menu(src, src, options, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
			C.external_leaving_passenger(place = choosed_place)
		else
			C.external_leaving_passenger(mode = MECH_DROP_ANY_PASSENGER )
		return TRUE
