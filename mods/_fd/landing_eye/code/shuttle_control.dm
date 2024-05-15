/obj/machinery/computer/shuttle_control/explore
	ui_template = "mods-shuttle_control_console_exploration.tmpl"

	var/eye_type = /mob/observer/eye/landing/
	var/mob/observer/eye/landing/eyeobj = null

	// Manual landing locations.
	var/datum/action/shuttle/finish_landing/finish_landing_action
	var/datum/action/shuttle/end_landing/end_landing_action
	var/mob/current_user

/obj/machinery/computer/shuttle_control/explore/Initialize()
	. = ..()
	finish_landing_action = new(src)
	end_landing_action = new(src)

/obj/machinery/computer/shuttle_control/explore/Destroy()
	end_landing()
	current_user = null
	QDEL_NULL(finish_landing_action)
	QDEL_NULL(end_landing_action)
	. = ..()

/obj/machinery/computer/shuttle_control/explore/handle_topic_href(datum/shuttle/autodock/overmap/shuttle, list/href_list, mob/user)
	. = ..()
	shuttle.operator_skill = user.get_skill_value(SKILL_PILOT)

	if(href_list["manual_landing"])
		if(user.skill_check(SKILL_PILOT, SKILL_TRAINED))
			if(current_user && current_user != user)
				to_chat(user, SPAN_WARNING("Someone is already performing a landing maneuver!"))
				return TOPIC_REFRESH
			if(eyeobj)
				end_landing()
			else
				start_landing(user, shuttle)
			return TOPIC_REFRESH
		to_chat(usr, SPAN_WARNING("The manual controls look hopelessly complex to you!"))

/obj/machinery/computer/shuttle_control/explore/CouldNotUseTopic(mob/user)
	if(user == current_user)
		end_landing()
	..()

/obj/machinery/computer/shuttle_control/explore/proc/start_landing(mob/living/user, datum/shuttle/autodock/overmap/shuttle)
	var/obj/overmap/visitable/current_sector = map_sectors["[z]"]
	var/obj/overmap/visitable/target_sector

	if(current_sector && istype(current_sector))
		var/list/available_sectors = list()
		for(var/obj/overmap/visitable/S in range(get_turf(current_sector), shuttle.range))
			if(S.free_landing)
				available_sectors += S

		if(LAZYLEN(available_sectors))
			target_sector = input("Choose sector to land in.", "Sectors") as null|anything in available_sectors

	if(target_sector && istype(user) && CanInteract(user, GLOB.default_state))
		GLOB.moved_event.register(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)
		GLOB.stat_set_event.register(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)
		GLOB.logged_out_event.register(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)	// Prevents bugs with landing images.

		var/turf/eye_turf = locate(world.maxx/2, world.maxy/2, target_sector.map_z[LAZYLEN(target_sector.map_z)])	// Center of the top z-level of the target sector.

		eyeobj = new eye_type(get_turf(shuttle.current_location), shuttle_tag)

		eyeobj.possess(user)
		eyeobj.setLoc(eye_turf)

		user.update_sight()

		finish_landing_action.Grant(user)
		end_landing_action.Grant(user)
	else
		to_chat(user, SPAN_WARNING("You are unable to land!"))
		return

/obj/machinery/computer/shuttle_control/explore/proc/finish_landing(mob/user)
	if(!eyeobj.check_landing()) // If the eye says we can't land, keep us in the landing view.
		return
	var/turf/lz_turf = get_turf(eyeobj)

	var/obj/overmap/visitable/sector = map_sectors["[lz_turf.z]"]
	if(!sector.free_landing)	// Additional safety check to ensure the sector is permits landing.
		to_chat(user, SPAN_WARNING("Invalid landing zone!"))
		end_landing()
		return
	var/datum/shuttle/autodock/overmap/shuttle = SSshuttle.shuttles[shuttle_tag]
	var/obj/shuttle_landmark/temporary/lz = new(lz_turf)
	if(lz.is_valid(shuttle))	// Preliminary check that the shuttle fits.
		shuttle.set_destination(lz)
	else
		qdel(lz)
		to_chat(user, SPAN_WARNING("Invalid landing zone!"))
	end_landing()

/obj/machinery/computer/shuttle_control/explore/proc/end_landing(mob/user)
	GLOB.moved_event.unregister(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)
	GLOB.stat_set_event.unregister(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)
	GLOB.logged_out_event.unregister(user, src, /obj/machinery/computer/shuttle_control/explore/proc/end_landing)
	if(current_user)
		finish_landing_action.Remove(current_user)
		end_landing_action.Remove(current_user)
	QDEL_NULL(eyeobj)
	current_user = null

/obj/machinery/computer/shuttle_control/explore/power_change()
	. = ..()
	if(. && current_user && (stat & (MACHINE_STAT_NOPOWER|MACHINE_BROKEN_GENERIC)))
		end_landing(current_user)

/datum/action/shuttle
	action_type = AB_GENERIC
	check_flags = AB_CHECK_STUNNED|AB_CHECK_LYING
	button_icon = 'mods/_fd/landing_eye/icons/actions.dmi'

/datum/action/shuttle/CheckRemoval(mob/living/user)
	if(!user.eyeobj || !istype(user.eyeobj, /mob/observer/eye/landing))
		return TRUE

/datum/action/shuttle/finish_landing
	name = "Set landing location"
	procname = "finish_landing"
	button_icon_state = "shuttle_land"

/datum/action/shuttle/end_landing
	name = "Exit landing mode"
	procname = "end_landing"
	button_icon_state = "shuttle_cancel"
