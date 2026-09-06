// Contains experiment data tracking and science scan handling
// server list moved into research subsystem

/datum/experiment_data
	var/list/saved_tech_levels = list() // list("materials" = list(1, 4, ...), ...)

/datum/experiment_data/proc/init_known_tech()
	return

/datum/experiment_data/proc/do_research_object(obj/item/I)
	var/list/temp_tech = I.origin_tech

	for(var/T in temp_tech)
		if(!saved_tech_levels[T])
			saved_tech_levels[T] = list()

		if(!(temp_tech[T] in saved_tech_levels[T]))
			saved_tech_levels[T] += temp_tech[T]

/datum/experiment_data/proc/merge_with(datum/experiment_data/O)
	for(var/tech in O.saved_tech_levels)
		if(!saved_tech_levels[tech])
			saved_tech_levels[tech] = list()

		saved_tech_levels[tech] |= O.saved_tech_levels[tech]


// Universal tool to collect science data from reports and samples

/obj/item/paper/anomaly_scan
	var/artifact
	var/my_effect
	var/secondary_effect

/obj/item/paper/plant_report
	var/potency

/obj/item/paper/plant_report/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(istype(tool,/obj/item/pen))
		return
	return ..()


/obj/item/paper/radiocarbon_spectrometer_report

/obj/item/paper/xenofauna_report

// Weather data collection sensor — deployable on exoplanets

/obj/item/device/weather_sensor
	name = "weather data collection sensor"
	desc = "A portable atmospheric and environmental data collection device. Deploy it in various locations to record local weather patterns."
	icon = 'icons/obj/modular_components.dmi'
	icon_state = "power_cell"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 100, MATERIAL_PLASTIC = 50)
	var/deployed = FALSE

/obj/item/device/weather_sensor/attack_self(mob/user)
	if(deployed)
		to_chat(user, SPAN_WARNING("\The [src] has already been deployed and locked!"))
		return

	if(!istype(get_area(src), /area/exoplanet))
		to_chat(user, SPAN_WARNING("\The [src] must be deployed on a planetary surface!"))
		return

	to_chat(user, SPAN_NOTICE("You begin deploying \the [src]..."))
	if(!do_after(user, 3 SECONDS, src))
		return

	deployed = TRUE
	anchored = TRUE
	to_chat(user, SPAN_NOTICE("You deploy and activate \the [src]. It begins recording environmental data."))

	if(deployed)
		to_chat(user, SPAN_NOTICE("The sensor is deployed and actively recording data."))
		var/turf/T = get_turf(src)
		var/area/A = get_area(src)
		if(T && A)
			to_chat(user, SPAN_NOTICE("Location: [A.name] ([T.x], [T.y], [T.z])"))
	else
		to_chat(user, SPAN_NOTICE("The sensor can be deployed on a planetary surface."))
