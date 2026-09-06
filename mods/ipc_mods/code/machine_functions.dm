/mob/living/carbon/human/proc/detach_limb()
	set category = "Abilities"
	set name = "Detach Limb"
	set desc = "Detach one of your robotic appendages."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained())
		to_chat(src, SPAN_WARNING("You can't do that in your current state!"))
		return

	var/obj/item/organ/external/E = get_organ(zone_sel.selecting)

	if(!E)
		to_chat(src, SPAN_WARNING("You are missing that limb."))
		return

	if(!BP_IS_ROBOTIC(E))
		to_chat(src, SPAN_WARNING("You can only detach robotic limbs."))
		return

	if(E.is_stump() || E.is_broken())
		to_chat(src, SPAN_WARNING("The limb is too damaged to be removed manually!"))
		return

	if(E.vital)
		to_chat(src, SPAN_WARNING("Your safety system stops you from removing \the [E]."))
		return

	if(!do_after(src, 2 SECONDS, src)) return

	last_special = world.time + 20

	E.removed(src)
	E.forceMove(get_turf(src))

	update_body()
	updatehealth()
	UpdateDamageIcon()

	visible_message(SPAN_NOTICE("\The [src] detaches \his [E]!"),
			SPAN_NOTICE("You detach your [E]!"))

/mob/living/carbon/human/proc/attach_limb()
	set category = "Abilities"
	set name = "Attach Limb"
	set desc = "Attach a robotic limb to your body."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained())
		to_chat(src, SPAN_WARNING("You can't do that in your current state!"))
		return

	var/obj/item/organ/external/O = src.get_active_hand()

	if(!O)
		return

	if(istype(O))
		if(!BP_IS_ROBOTIC(O))
			to_chat(src, SPAN_WARNING("You are unable to interface with organic matter."))
			return

	var/obj/item/organ/external/E = get_organ(zone_sel.selecting)

	if(E)
		to_chat(src, SPAN_WARNING("You are not missing that limb."))
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

	visible_message(SPAN_NOTICE("\The [src] attaches \the [O] to \his body!"),
			SPAN_NOTICE("You attach \the [O] to your body!"))



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

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(isSynthetic())
		overlay_fullscreen("sensoremp", /obj/screen/fullscreen/glitchs)
		addtimer(new Callback(src, PROC_REF(clear_emp_act)), 1.5 SECONDS)

/mob/living/carbon/human/proc/clear_emp_act()
	clear_fullscreen("sensoremp")
