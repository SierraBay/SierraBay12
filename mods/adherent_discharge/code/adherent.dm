/obj/item/organ/internal/cell/adherent
	var/ready_to_charge


/mob/living/carbon/human/proc/toggle_emergency_discharge()
	set category = "Abilities"
	set name = "Toggle emergency discharge"
	set desc = "Allows you to overload your piezo capacitors."

	var/mob/living/carbon/human/adherent = src
	var/obj/item/organ/internal/cell/adherent/adherent_core = adherent.internal_organs_by_name[BP_CELL]
	if(!adherent_core.ready_to_charge)
		adherent_core.ready_to_charge = TRUE
		to_chat(src, SPAN_WARNING("The emergency discharge is ready for use."))
		to_chat(src, SPAN_GOOD("You are ready to discharge, use alt+click on target to electrocute them."))
		adherent.visible_message(SPAN_WARNING("You hear silent crackle sounds from [adherent] tentacles"))
		playsound(loc, 'mods/adherent_discharge/sounds/discharge_on.ogg', 40, 1)
		return

	adherent_core.ready_to_charge = FALSE
	to_chat(src, SPAN_WARNING("You have relieved the tension of your tentacles."))


/datum/species/adherent/handle_vision(mob/living/carbon/human/H)
	var/list/vision = H.get_accumulated_vision_handlers()
	H.update_sight()
	H.set_sight(H.sight|get_vision_flags(H)|H.equipment_vision_flags|vision[1])
	H.change_light_colour(H.getDarkvisionTint())

	if(H.stat == DEAD)
		return 1

	if(!H.druggy)
		H.set_see_in_dark((H.sight == (SEE_TURFS|SEE_MOBS|SEE_OBJS)) ? 8 : min(H.getDarkvisionRange() + H.equipment_darkness_modifier, 8))
		if(H.equipment_see_invis)
			H.set_see_invisible(max(min(H.see_invisible, H.equipment_see_invis), vision[2]))

	if(H.equipment_tint_total >= TINT_BLIND)
		H.eye_blind = max(H.eye_blind, 1)

	if(!H.client)//no client, no screen to update
		return 1

	if(H.stat == !UNCONSCIOUS)
		H.set_fullscreen(H.eye_blind && !H.equipment_prescription, "glitch_monitor", /obj/screen/fullscreen/glitch_bw/alpha)
	H.set_fullscreen(H.stat == UNCONSCIOUS, "no_power", /obj/screen/fullscreen/no_power)

	if(config.welder_vision)
		H.set_fullscreen(H.equipment_tint_total, "welder", /obj/screen/fullscreen/impaired, H.equipment_tint_total)
	var/how_nearsighted = get_how_nearsighted(H)
	H.set_fullscreen(how_nearsighted, "nearsighted", /obj/screen/fullscreen/oxy, how_nearsighted)
	H.set_fullscreen(H.eye_blurry, "blurry", /obj/screen/fullscreen/glitch_bw)
	H.set_fullscreen(H.druggy, "high", /obj/screen/fullscreen/high)

	for(var/overlay in H.equipment_overlays)
		H.client.screen |= overlay

	return 1

////obj/screen/fullscreen/glitch описан в mods\ipc_mods\code\machine_functions.dm
