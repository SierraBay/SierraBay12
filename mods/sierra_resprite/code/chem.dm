/obj/machinery/reagentgrinder
	icon = 'mods/sierra_resprite/icons/chem.dmi'
	icon_state = "rgrinder"

/obj/machinery/chem_master
	icon = 'mods/sierra_resprite/icons/chem.dmi'
	icon_state = "ch_mixer"

/obj/machinery/chemical_dispenser
	icon = 'mods/sierra_resprite/icons/chem.dmi'
	icon_state = "сh_dispenser"

/obj/machinery/chemical_dispenser/on_update_icon()
	ClearOverlays()
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if(container)
		var/mutable_appearance/beaker_overlay
		beaker_overlay = image('mods/sierra_resprite/icons/chem.dmi', src, "[icon_state]_lil_beaker")
		AddOverlays(beaker_overlay)
