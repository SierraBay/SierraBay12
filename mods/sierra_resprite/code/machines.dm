/obj/machinery/seed_extractor
	icon = 'mods/sierra_resprite/icons/hydroponic.dmi'
	icon_state = "sextractor"

/obj/machinery/biogenerator
	icon = 'mods/sierra_resprite/icons/hydroponic.dmi'
	icon_state = "biogen"

/obj/machinery/suit_cycler
	icon = 'mods/sierra_resprite/icons/suitcycler.dmi'
	icon_state = "close"

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'mods/sierra_resprite/icons/fax_machine.dmi'
	icon_state = "fax"

/obj/structure/cryofeed
	icon = 'mods/sierra_resprite/icons/cryopod.dmi'
	icon_state = "cryo_rear"

/obj/machinery/cryopod
	icon = 'mods/sierra_resprite/icons/cryopod.dmi'
	icon_state = "cryopod"

/obj/structure/broken_cryo
	icon = 'mods/sierra_resprite/icons/cryopod.dmi'
	icon_state = "broken_cryo"

/obj/machinery/computer/cryopod
	icon = 'mods/sierra_resprite/icons/cryopod.dmi'
	icon_state = "cellconsole"

/obj/machinery/fusion_fuel_compressor
	name = "fuel compressor"
	icon = 'mods/sierra_resprite/icons/fusion_fuel_compressor.dmi'
	icon_state = "fuel_compressor"

/obj/machinery/power/fusion_core
	name = "\improper R-UST Mk. 8 Tokamak core"
	desc = "An enormous solenoid for generating extremely high power electromagnetic fields. It includes a kinetic energy harvester."
	icon = 'mods/sierra_resprite/icons/r-ust.dmi'
	icon_state = "core0"

/obj/machinery/power/fusion_core/Startup()
	if(owned_field)
		return
	owned_field = new(loc, src)
	owned_field.ChangeFieldStrength(field_strength)
	UpdateVisuals()
	update_use_power(POWER_USE_ACTIVE)
	. = 1

/obj/machinery/power/fusion_core/Shutdown(force_rupture)
	if(owned_field)
		ClearOverlays()
		set_light(0)
		if(force_rupture || owned_field.plasma_temperature > 1000)
			owned_field.Rupture()
		else
			owned_field.RadiateAll()
		qdel(owned_field)
		owned_field = null
	update_use_power(POWER_USE_IDLE)

/obj/machinery/power/fusion_core/proc/UpdateVisuals()
	ClearOverlays()
	AddOverlays(list(
		emissive_appearance(icon, "[icon_state]_lights_working"),
		overlay_image(icon, "[icon_state]_lights_working", owned_field.light_color)
	))
	set_light(2, 2, owned_field.light_color)

/obj/fusion_em_field/UpdateVisuals()
	var/radius = ((size-1) / 2) * WORLD_ICON_SIZE

	particles.position = generator("circle", radius - size, radius + size, NORMAL_RAND)

	//Radiation affects drift
	var/radiationfactor = clamp((radiation * 0.001), 0, 0.5) + 0.2
	particles.drift = generator("circle", -radiationfactor, radiationfactor, , NORMAL_RAND)

	particles.spawning = last_reactants * 0.9 + Interpolate(0, 200, clamp(plasma_temperature / 70000, 0, 1))

	owned_core.UpdateVisuals()
