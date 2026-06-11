GLOBAL_LIST_AS(active_vr_areas , list())
GLOBAL_LIST_AS(vr_areas, list(
	"Courtroom" = /area/virtual_reality/courtroom,
	"Meeting Hall" = /area/virtual_reality/meeting_hall,
	"Theatre" = /area/virtual_reality/theatre,
	"Summer Cafe" = /area/virtual_reality/cafe,
	"Boxing Ring" = /area/virtual_reality/boxing_ring,
	"Empty Court" = /area/virtual_reality/empty_court,
	"Volleyball Court" = /area/virtual_reality/volleyball_court,
	"Basketball Court" = /area/virtual_reality/basketball_court,
	"Thunderdome" = /area/virtual_reality/thunderdome,
	"Beach" = /area/virtual_reality/beach,
	"Snowy Field" = /area/virtual_reality/snowfield,
	"Wild West Desert" = /area/virtual_reality/desert,
	"Space" = /area/virtual_reality/space,
	"Infirmary" = /area/virtual_reality/infirmary
))
GLOBAL_LIST_AS(emagged_vr_areas, list(
	"Shady Room" = /area/virtual_reality/shady_room,
	"Night Jungle" = /area/virtual_reality/jungle,
//	"Netspace" = /area/virtual_reality/netspace
))


/// Keeps tabs on every client currently in VR, as well as every occupant and very virtual mob.
/// If an occupant is no longer valid in VR (i.e. pod depowered), it will yank them out and put them into their original mob.
SUBSYSTEM_DEF(virtual_reality)
	name = "VR"
	priority = 75
	init_order = SS_INIT_DEFAULT
	wait = 0.5 SECONDS

	var/list/virtual_mobs_to_occupants = list()		// Associative list of /mob/living => /mob/living. Each virtual mob is tied to its occupant.
	var/list/virtual_occupants_to_mobs = list()		// Reverse of previous list, in case one is missing but not the other.
	var/list/virtual_clients = list()				// Associative list of /client => /mob/living. Each client is linked to its virtual mob.
	var/list/was_warned = list()					// A list of clients that have already received the disclaimer message when entering VR.

	var/list/loading_tracker = list()
	var/list/special_zones = list(
		"Thunderdome"
	) // special, unchangable zones
	var/list/zone_current_area = list()
	var/static/list/vr_blacklist = list(
		/obj/item/disk/nuclear,
		/obj/item/clothing/accessory/bs_silk,
		/obj/item/device/uplink_service,
		/obj/item/bluespace_crystal,
		/obj/item/stack/telecrystal,
		/obj/item/stock_parts/circuitboard,
		/obj/item/implanter,
		/obj/item/implant,
		/obj/item/device/syndietele,
		/obj/item/device/syndiejaunter,
		/obj/item/organ/internal/posibrain,
		/obj/item/device/paicard,
		/obj/item/device/mmi
	) // New

/datum/controller/subsystem/virtual_reality/Initialize(start_timeofday)
	GLOB.active_vr_areas["Zone 1"] = locate(/area/virtual_reality/zone1)
	GLOB.active_vr_areas["Zone 2"] = locate(/area/virtual_reality/zone2)
	GLOB.active_vr_areas["Zone 3"] = locate(/area/virtual_reality/zone3)
	GLOB.vr_spawns["Zone 1"] = list()
	GLOB.vr_spawns["Zone 2"] = list()
	GLOB.vr_spawns["Zone 3"] = list()

/datum/controller/subsystem/virtual_reality/fire(resumed = FALSE)
	for (var/mob/living/L in virtual_occupants_to_mobs)
		if (!check_vr(L))
			remove_virtual_mob(L, TRUE)
	for (var/mob/living/L in virtual_mobs_to_occupants)
		if (!L.client) // Remove clientless virtual mobs, but NOT occupants - they're already clientless since their mind gets transferred
			remove_virtual_mob(L)
	listclearnulls(virtual_clients)

// New
/datum/controller/subsystem/virtual_reality/proc/clone_atom_template(obj/original, copy_vars, atom/loc)
	RETURN_TYPE(/obj)
	if (!original)
		return
	if (loc && !isloc(loc))
		loc = original.loc
	var/obj/result = new original.type (loc)
	if (!copy_vars || !result)
		return result
	var/list/vars = original.vars

	for (var/name in vars)
		if (name in GLOB.duplicate_object_disallowed_vars)
			continue
		if (!issaved(vars[name]))
			continue
		if (isdatum(vars[name]))
			continue
		if(islist(vars[name]) && LAZYLEN(vars[name]))
			if(isdatum(vars[name][1]))
				continue
		result.vars[name] = vars[name]

	if(istype(result, /obj/machinery/atmospherics))
		result.vars["atmos_initalized"] = FALSE

	return result

/datum/controller/subsystem/virtual_reality/proc/clone_atom_vr(atom/A)
	var/atom/cloned_atom = clone_atom(A)

	if(A.color)
		cloned_atom.color = A.color

	return cloned_atom

/datum/controller/subsystem/virtual_reality/proc/recursive_storage_copy(obj/item/storage/S, obj/item/storage/O)
	for(var/obj/item/I in S.contents)
		qdel(I)

	for(var/obj/item/I in O.contents)
		if(!is_type_in_list(I, vr_blacklist))
			var/obj/item/cloned_I = clone_atom_vr(I)
			S.handle_item_insertion(cloned_I)

			if(istype(cloned_I, /obj/item/storage))
				recursive_storage_copy(cloned_I, I)

/datum/controller/subsystem/virtual_reality/proc/accessories_copy(obj/item/clothing/cloned_I, obj/item/clothing/I)
	for(var/obj/item/clothing/accessory/A in I.accessories)
		if(!is_type_in_list(A, vr_blacklist))
			var/obj/item/clothing/accessory/cloned_A = clone_atom_vr(A)
			cloned_I.attach_accessory(null, cloned_A)

/datum/controller/subsystem/virtual_reality/proc/apply_vr_equipment(mob/living/simulated_mob, mob/living/new_occupant)
	for(var/obj/item/I in new_occupant.contents)
		if(!is_type_in_list(I, vr_blacklist))
			var/obj/item/cloned_I = clone_atom_vr(I)

			var/item_slot = new_occupant.get_inventory_slot(I)

			if(istype(cloned_I, /obj/item/storage))
				recursive_storage_copy(cloned_I, I)

			if(istype(cloned_I, /obj/item/clothing))
				accessories_copy(cloned_I, I)


			simulated_mob.equip_to_slot(cloned_I, item_slot)
//

/// Checks whether or not the provided occupant can remain inside of VR. Returns TRUE or FALSE.
/datum/controller/subsystem/virtual_reality/proc/check_vr(mob/living/user)
	if ((user.getBrainLoss() >= 25)) // Boot out mobs with moderate brain damage
		return FALSE
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.shock_stage >= 15) // Boot out humans in high pain
			return FALSE
	if (user.isSynthetic()) // And also boot out synthetics with low charge
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/internal/cell/C = H.internal_organs_by_name[BP_CELL]
			if(istype(C) && C.percent() <= 25)
				return FALSE
	var/is_valid = FALSE
	var/obj/machinery/vr_pod/pod = user.loc
	if (istype(pod)) // Check for a usable VR pod
		is_valid = pod.operable()
	else // Finally, check for a VR implant, but only if nothing else is active
		is_valid = !!locate(/obj/item/implant/virtual_reality) in user
	return is_valid

/// Creates a virtual mob for the provided occupant. Humans will take appearance based on client prefs.
/// Returns the instance of the mob that was created.
/datum/controller/subsystem/virtual_reality/proc/create_virtual_mob(mob/living/new_occupant, mob_type, location, silent = FALSE)
	var/mob/living/simulated_mob = new mob_type(location)
	if (ishuman(simulated_mob) && ishuman(new_occupant)) // Copy human appearance for the new mob
		var/mob/living/carbon/human/H = simulated_mob
		var/mob/living/carbon/human/H_original = new_occupant

		new_occupant.client.prefs.copy_to(simulated_mob)
		H.set_nutrition(400)
		H.set_hydration(400)
		H.job = new_occupant.job
		//H.apply_job_equipment()
		//New
		apply_vr_equipment(simulated_mob, new_occupant)

		for(var/obj/item/organ/internal/augment/aug in H_original.internal_organs)
			var/obj/item/organ/internal/augment/augment = clone_atom_vr(aug)

			var/obj/item/organ/external/parent = H.organs_by_name[aug.parent_organ]
			if (!parent)
				to_chat(simulated_mob, SPAN_WARNING("Failed to find a valid organ to install \the [augment] into!"))
				qdel(augment)
				return

			var/surgery_step = GET_SINGLETON(/singleton/surgery_step/internal/replace_organ)

			if (augment.surgery_configure(simulated_mob, simulated_mob, parent, null, surgery_step))
				to_chat(simulated_mob, SPAN_WARNING("Failed to set up \the [augment] for installation in your [parent.name]!"))
				qdel(augment)
				return

			augment.forceMove(simulated_mob)
			augment.replaced(simulated_mob, parent)
			augment.onRoundstart()
		//

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/underwear))
				I.canremove = FALSE
				I.verbs -= /obj/item/underwear/verb/RemoveSocks

	log_and_message_admins("entered VR as [simulated_mob] (assigned role: [new_occupant.mind.assigned_role]).", new_occupant)

	var/datum/extension/virtual_surrogate/VM = get_or_create_extension(simulated_mob, /datum/extension/virtual_surrogate)
	VM.set_mob(simulated_mob, src)

	virtual_occupants_to_mobs[new_occupant] = simulated_mob
	virtual_mobs_to_occupants[simulated_mob] = new_occupant
	virtual_clients[new_occupant.client] = simulated_mob

	new_occupant.mind.transfer_to(simulated_mob)

	if (!silent)
		var/dat = ""
		dat += SPAN_NOTICE(SPAN_BOLD(FONT_LARGE("-=-=-=-<br>You have entered VR!<br>")))
		if (!locate(simulated_mob.client) in was_warned)
			dat += SPAN_NOTICE("You are now controlling a virtual body in a virtual environment.<br>")
			dat += SPAN_NOTICE("Your normal body can be found where you entered VR, hopefully secure from outside influence.<br>")
			dat += SPAN_NOTICE("You won't be able to see or hear anything around your normal body, but if your pod loses power or is forced open, you'll be returned.")
			dat += SPAN_NOTICE("<br><br>From an in-character perspective, <b>everything done here is simulated, and will have no <i>direct</i> impact on the round.</b><br>")
			dat += SPAN_NOTICE("Of course, you're still beholden to the server's rules, and you're expected to follow them! Don't beat someone to death without asking.<br>")
			dat += SPAN_NOTICE("If you die in this form, you'll be forced back to your body. You can also use the \[Exit-VR\] verb at any time, which you can find in the VR tab.<br>")
		dat += SPAN_NOTICE(SPAN_BOLD(FONT_LARGE("-=-=-=-")))
		to_chat(simulated_mob, dat)
		playsound(simulated_mob.loc, 'sound/machines/boop1.ogg', 50)
		simulated_mob.languages = new_occupant.languages.Copy()
		simulated_mob.default_language = new_occupant.default_language
	simulated_mob.lastarea = null
	return simulated_mob

/// Removes a mob from VR. Accepts both occupants and virtual mobs as a first argument.
/// Returns TRUE if the removal succeeded.
/datum/controller/subsystem/virtual_reality/proc/remove_virtual_mob(mob/living/removed_mob, sudden = FALSE, easter_egg_chance = 1, silent = FALSE)
	var/mob/living/occ_mob
	var/mob/living/vir_mob

	if (virtual_occupants_to_mobs[removed_mob])
		occ_mob = removed_mob
		vir_mob = virtual_occupants_to_mobs[removed_mob]
	else if (virtual_mobs_to_occupants[removed_mob])
		occ_mob = virtual_mobs_to_occupants[removed_mob]
		vir_mob = removed_mob

	if (!vir_mob)
		return FALSE

	var/list/pre_vr_buffs = vir_mob.fetch_buffs_of_type(/datum/skill_buff/virtual_reality)
	if (LAZYLEN(pre_vr_buffs))
		for (var/datum/skill_buff/virtual_reality/VRB in pre_vr_buffs)
			VRB.remove()

	var/client/C = virtual_clients[vir_mob.client]

	virtual_clients -= C

	if (!silent)
		var/dat = ""
		dat += SPAN_NOTICE(SPAN_BOLD(FONT_LARGE("-=-=-=-<br>You have left VR!<br>")))
		if (!(vir_mob.client in was_warned))
			was_warned += vir_mob.client
			dat += SPAN_NOTICE("You have exited virtual reality and returned to your normal body.<br>")
			dat += SPAN_NOTICE("Everything that happened in VR was simulated, but it did happen. In-character, you remember all the events that transpired inside.<br>")
			dat += SPAN_NOTICE("Now that you've been in and out of VR, you won't see these messages again this round.<br>")
		dat += SPAN_NOTICE(SPAN_BOLD(FONT_LARGE("-=-=-=-")))
		to_chat(vir_mob, dat)

	if (!sudden)
		vir_mob.visible_message(SPAN_NOTICE("\The [vir_mob] visibly pixelates, and then fades away."))
		to_chat(vir_mob, SPAN_NOTICE("Your view blurs and distorts for a moment, and you feel weightless. And then, you're back in reality."))
	else
		vir_mob.visible_message(SPAN_WARNING("\The [vir_mob] suddenly distorts and pops out of existence."))
		to_chat(vir_mob, SPAN_DANGER(FONT_LARGE("You're abruptly dragged back to reality!")))

	if (occ_mob) // Occupier mob might have been destroyed somehow, in which case we just kill the virtual one
		vir_mob.mind.transfer_to(occ_mob)
		if (prob(easter_egg_chance))
			to_chat(occ_mob, SPAN_WARNING("Just like the simulations...!"))
		var/list/vr_buffs = occ_mob.fetch_buffs_of_type(/datum/skill_buff/virtual_reality)
		if (LAZYLEN(vr_buffs))
			for (var/datum/skill_buff/virtual_reality/VRB in vr_buffs)
				VRB.remove()
		occ_mob.lastarea = vir_mob.lastarea

	virtual_occupants_to_mobs[occ_mob] = null
	virtual_occupants_to_mobs -= occ_mob
	virtual_mobs_to_occupants[vir_mob] = null
	virtual_mobs_to_occupants -= vir_mob

	QDEL_NULL(vir_mob)
	return TRUE

/// Returns the virtual mob representing the provided mob, if it has any.
/datum/controller/subsystem/virtual_reality/proc/get_surrogate_for(mob/living/L)
	var/mob/M = virtual_occupants_to_mobs[L]
	if (!istype(M))
		return
	return M

/// Inverse of get_surrogate_for - returns the occupant mob that's controlling a virtual mob.
/datum/controller/subsystem/virtual_reality/proc/get_occupant_for(mob/living/L)
	var/mob/M = virtual_mobs_to_occupants[L]
	if (!istype(M))
		return
	return M

/// Gets a list of all turfs that are valid VR entry points at call time.
/datum/controller/subsystem/virtual_reality/proc/get_vr_spawns(zone)
	. = list()

	if(zone == "Thunderdome")
		var/list/spawn_options = list("Thunderdome Team 1","Thunderdome Team 2","Thunderdome Spectators")
		zone = input("Select a spawn point.", "Select spawnpoint.") as null|anything in spawn_options

	for (var/obj/effect/vr_spawn/L in GLOB.vr_spawns[zone])
		var/turf/T = get_turf(L)
		. += T

/// Returns TRUE if a mob can enter VR, and FALSE if it can't.
/datum/controller/subsystem/virtual_reality/proc/can_enter_vr(mob/living/target)
	var/mob/living/carbon/human/H = target // we typecast immediately, but the typecast var is only used after sanity checks
	if (target.isSynthetic())
		if (ishuman(target))
			var/obj/item/organ/internal/cell/C = H.internal_organs_by_name[BP_CELL]
			if(istype(C) && C.percent() <= 25) // if a human has low charge, intercept
				return FALSE
	if (ishuman(target))
		if (H.shock_stage > 15) // if a human is in severe pain, intercept
			return FALSE
	return target.getBrainLoss() < 25 // otherwise, check for moderate brain damage

/datum/controller/subsystem/virtual_reality/proc/copy_template(area/source, area/target, plating_required)
	RETURN_TYPE(/list)
	if (!target || !source)
		return
	var/list/turfs_src = get_area_turfs(source.type)
	var/list/turfs_trg = get_area_turfs(target.type)
	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/turf in turfs_src)
		if (turf.x < src_min_x || !src_min_x)
			src_min_x = turf.x
		if (turf.y < src_min_y || !src_min_y)
			src_min_y = turf.y
	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/turf in turfs_trg)
		if (turf.x < trg_min_x || !trg_min_x)
			trg_min_x = turf.x
		if (turf.y < trg_min_y || !trg_min_y)
			trg_min_y = turf.y
	var/list/refined_src = list()
	for (var/turf/turf in turfs_src)
		refined_src[turf] = list(turf.x - src_min_x, turf.y - src_min_y)
	var/list/refined_trg = list()
	for (var/turf/turf in turfs_trg)
		refined_trg[turf] = list(turf.x - trg_min_x, turf.y - trg_min_y)
	var/list/turfs_to_update = list()
	var/list/copied_movables = list()
	var/turf_index = 0
	moving:
		for (var/turf/source_turf in refined_src)
			var/list/source_position = refined_src[source_turf]
			for (var/turf/target_turf in refined_trg)
				var/list/target_position = refined_trg[target_turf]
				var/same_position = source_position[1] == target_position[1] \
					&& source_position[2] == target_position[2]
				if (same_position)
					var/old_dir1 = source_turf.dir
					var/old_icon_state1 = source_turf.icon_state
					var/old_icon1 = source_turf.icon
					var/old_underlays = source_turf.underlays.Copy()
					if (plating_required)
						if (istype(target_turf, get_base_turf_by_area(target_turf)))
							continue moving
					var/turf/temp_target_turf = target_turf
					temp_target_turf.ChangeTurf(source_turf.type)
					temp_target_turf.set_dir(old_dir1)
					temp_target_turf.icon_state = old_icon_state1
					temp_target_turf.icon = old_icon1
					temp_target_turf.CopyOverlays(source_turf)
					temp_target_turf.underlays = old_underlays
					for (var/obj/obj in source_turf)
						if (!obj.simulated)
							continue
						copied_movables += clone_atom_template(obj, TRUE, temp_target_turf)
					for (var/mob/mob in source_turf)
						if (!mob.simulated)
							continue
						copied_movables += clone_atom_template(mob, TRUE, temp_target_turf)
					turfs_to_update += temp_target_turf
					refined_src -= source_turf
					refined_trg -= target_turf

					if(turf_index % 15 == 0)
						sleep(1)
					turf_index++
					continue moving
	for (var/turf/simulated/simulated in turfs_to_update)
		SSair.mark_for_update(simulated)
	return copied_movables

/datum/controller/subsystem/virtual_reality/proc/build_atmospherics(area/target)
	for(var/obj/machinery/atmospherics/A in target)
		A.atmos_init()

/datum/controller/subsystem/virtual_reality/proc/before_template_load(area/source, area/target)
	for(var/obj/structure/closet/C in source)
		C.dump_contents()

/datum/controller/subsystem/virtual_reality/proc/after_template_load(area/source, area/target)
	for(var/obj/structure/closet/C in target)
		C.store_contents()

	build_atmospherics(target)

	if(istype(source, /area/virtual_reality/infirmary))
		for(var/obj/machinery/body_scanconsole/C in target)
			C.FindScanner()
		for(var/obj/machinery/vitals_monitor/V in target)
			var/obj/machinery/optable/O = locate(/obj/machinery/optable) in range(1, V)
			if(O)
				V.update_optable(O)

/datum/controller/subsystem/virtual_reality/proc/after_mob_creation(mob/living/L, zone)
	if(!L)
		return

/datum/controller/subsystem/virtual_reality/proc/load_template(datum/nano_module/program/vr_control/vr_program, user, zone, template_area)
	if (!zone)
		to_chat(user, SPAN_WARNING("No VR zone selected. Cannot load template."))
		return TRUE

	if (zone in special_zones)
		to_chat(user, SPAN_WARNING("This zone is unchangable."))
		return TRUE

	var/area/zone_area = GLOB.active_vr_areas[zone]
	if (!zone_area)
		to_chat(user, SPAN_WARNING("The system could not find the specified VR zone: [zone]"))
		return TRUE

	var/list/the_matrix = SSvirtual_reality.virtual_occupants_to_mobs
	var/P = GLOB.vr_areas[template_area]
	var/area/A = locate(P)
	if (!A)
		P = GLOB.emagged_vr_areas[template_area]
		A = locate(P)
		if (!A) // if we still don't have our area after checking for emagged ones, throw an error
			to_chat(user, SPAN_WARNING("The system could not find the specified template: [template_area]"))
			return TRUE
	if (zone_area == A)
		return TRUE
	if (LAZYLEN(the_matrix))
		if (alert(user, "Switching the VR area will eject [LAZYLEN(the_matrix)] users from the simulation. Continue?", "Change Area", "Yes", "No") != "Yes")
			return TRUE
		log_and_message_admins("changed the VR area to [A.name], ejecting [LAZYLEN(the_matrix)] occupants.", user)
	else
		log_and_message_admins("changed the VR area to [A.name].", user)

	if(vr_program && vr_program.area_cooldown > world.time)
		to_chat(user, SPAN_WARNING("VR program is recalibrating, try again later."))
		return TRUE

	if(loading_tracker[zone])
		// in case of runtimes
		if(world.time > loading_tracker[zone])
			loading_tracker[zone] = FALSE
		else
			to_chat(user, SPAN_WARNING("This zone is already loading a template. Try again, once its finished."))
			return TRUE

	vr_program.area_cooldown = world.time + 30 SECONDS
	loading_tracker[zone] = world.time + 120 SECONDS
	to_chat(user, SPAN_WARNING("Loading template: [A.name]..."))

	var/list/mobs_in_zone = mobs_in_area(zone_area)
	for (var/mob/living/L in mobs_in_zone)
		to_chat(L, SPAN_DANGER(FONT_LARGE("ALERT: Loaded VR template reconfiguring. Terminating connection.")))
		SSvirtual_reality.remove_virtual_mob(L, TRUE)

	var/loaded_normally = TRUE
	var/turf_index = 0
	if (!vr_program.emagged || prob(75))
		for (var/turf/T in zone_area)
			if (!istype(T, /turf/unsimulated/floor/plating))
				var/obj_index = 0
				T.ChangeTurf(/turf/unsimulated/floor/plating)
				for (var/atom/C in T.contents)
					if(ismob(C))
						var/mob/M = C
						if(M.client)
							continue
					qdel(C)
					if(obj_index % 5 == 0)
						sleep(1)
					obj_index++
				if(turf_index % 5 == 0)
					sleep(1)
				turf_index++
	else // we're emagged, just fuck our shit up a quarter of the time
		loaded_normally = FALSE
		var/atom/comp_holder = vr_program.program.computer.holder
		comp_holder.audible_message(SPAN_DANGER("\The [comp_holder] buzzes oddly!"))
		to_chat(user, SPAN_WARNING("updatevr.dm:[rand(10000, 20000)]:warning: Previous loaded template did not fully unload. Virtual space may be affected."))
		playsound(vr_program.program.computer.holder, 'sound/machines/buzz-sigh.ogg', 50)

	// in this way, we use the selected area as a template. we copy all of its contents to the actual area,
	// allowing users to "reset" the template by refreshing it
	var/area/active_area = zone_area
	// Just in case, set_dynamic_lighting already returns false for the same type of lighting
	if(active_area.dynamic_lighting != A.dynamic_lighting)
		active_area.set_dynamic_lighting(A.dynamic_lighting)
	before_template_load(A, active_area)
	copy_template(A, active_area)
	active_area.forced_ambience = A.forced_ambience
	active_area.sound_env = A.sound_env
	GLOB.vr_spawns[zone] = list()
	for (var/obj/effect/vr_spawn/V in active_area)
		GLOB.vr_spawns[zone] += V

	after_template_load(A, active_area)
	to_chat(user, SPAN_NOTICE("Successfully loaded new area: [A.name]!"))
	loading_tracker[zone] = FALSE
	zone_current_area[active_area.name] = template_area
	if (loaded_normally)
		playsound(vr_program.program.computer.holder, 'sound/machines/ping.ogg', 50)
	return TRUE
