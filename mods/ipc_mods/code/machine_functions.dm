/mob/living/carbon/human/proc/detach_limb()
	set category = "Abilities"
	set name = "Detach Limb"
	set desc = "Detach one of your robotic appendages."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained())
		to_chat(src,"<span class='warning'>You can't do that in your current state!</span>")
		return

	var/obj/item/organ/external/E = get_organ(zone_sel.selecting)

	if(!E)
		to_chat(src,"<span class='warning'>You are missing that limb.</span>")
		return

	if(!BP_IS_ROBOTIC(E))
		to_chat(src,"<span class='warning'>You can only detach robotic limbs.</span>")
		return

	if(E.is_stump() || E.is_broken())
		to_chat(src,"<span class='warning'>The limb is too damaged to be removed manually!</span>")
		return

	if(E.vital)
		to_chat(src,"<span class='warning'>Your safety system stops you from removing \the [E].</span>")
		return

	if(!do_after(src, 2 SECONDS, src)) return

	last_special = world.time + 20

	E.removed(src)
	E.forceMove(get_turf(src))

	update_body()
	updatehealth()
	UpdateDamageIcon()

	visible_message("<span class='notice'>\The [src] detaches \his [E]!</span>",
			"<span class='notice'>You detach your [E]!</span>")

/mob/living/carbon/human/proc/attach_limb()
	set category = "Abilities"
	set name = "Attach Limb"
	set desc = "Attach a robotic limb to your body."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained())
		to_chat(src,"<span class='warning'>You can not do that in your current state!</span>")
		return

	var/obj/item/organ/external/O = src.get_active_hand()

	if(istype(O))

		if(!BP_IS_ROBOTIC(O))
			to_chat(src,"<span class='warning'>You are unable to interface with organic matter.</span>")
			return

	if(!O)
		return


	var/obj/item/organ/external/E = get_organ(zone_sel.selecting)

	if(E)
		to_chat(src,"<span class='warning'>You are not missing that limb.</span>")
		return

	if(!do_after(src, 2 SECONDS, src)) return

	last_special = world.time + 20

	src.drop_from_inventory(O)
	O.replaced(src)
	src.update_body()
	src.updatehealth()
	src.UpdateDamageIcon()

	update_body()
	updatehealth()
	UpdateDamageIcon()

	visible_message("<span class='notice'>\The [src] attaches \the [O] to \his body!</span>",
			"<span class='notice'>You attach \the [O] to your body!</span>")



/obj/screen/fullscreen/no_power
	icon = 'mods/ipc_mods/icons/glitch.dmi'
	icon_state = "no_power"
	layer = BLIND_LAYER
	scale_to_view = TRUE

/obj/screen/fullscreen/glitch_monitor
	icon = 'mods/ipc_mods/icons/glitch.dmi'
	icon_state = "glitch_monitor"
	layer = BLIND_LAYER
	scale_to_view = TRUE
	alpha = 60

/obj/screen/fullscreen/glitchs
	icon = 'mods/ipc_mods/icons/glitch.dmi'
	icon_state = "glitch_eye"
	layer = BLIND_LAYER
	scale_to_view = TRUE

/obj/screen/fullscreen/glitch_bw
	icon = 'mods/ipc_mods/icons/glitch.dmi'
	icon_state = "glitch_bw"
	layer = BLIND_LAYER
	scale_to_view = TRUE
	alpha = 60

/obj/screen/fullscreen/glitch_bw/alpha
	alpha = 160


/datum/species/handle_vision(mob/living/carbon/human/H)
	if(H.isSynthetic())
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
	else
		.=..()

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(isSynthetic())
		overlay_fullscreen("sensoremp", /obj/screen/fullscreen/glitchs)
		addtimer(new Callback(src, PROC_REF(clear_emp_act)), 1.5 SECONDS)

/mob/living/carbon/human/proc/clear_emp_act()
	clear_fullscreen("sensoremp")
