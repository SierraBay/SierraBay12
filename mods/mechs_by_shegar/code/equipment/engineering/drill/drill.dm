/obj/item/mech_equipment/drill/afterattack(atom/target, mob/living/user, inrange, params)
	if(!module_can_be_used(target, user, inrange))
		return
	if (istype(target, /obj/item/material/drill_head))
		attach_head(target, user)
		return

	if(!can_drill(target, user))
		return

	var/obj/item/cell/mech_cell = owner.get_cell()
	mech_cell.use(active_power_use * CELLRATE)
	var/delay = calculate_drill_cooldown()
	owner.setClickCooldown(delay)
	sound_and_message(target)
	var/obj/particle_emitter/sparks/EM = generate_drill_particles(target, delay)


	if (do_after(owner, delay, target, (DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) & ~DO_USER_CAN_TURN))
		if (src != owner.selected_system)
			to_chat(user, SPAN_WARNING("You must keep \the [src] selected to use it."))
			return
		check_drill_integrity()
		target.mech_drill_interaction(owner, src, user)
		message_about_use(target, user)
	else
		to_chat(user, SPAN_WARNING("You must keep \the [src] selected to use it."))
	if(EM)
		EM = null

/obj/item/mech_equipment/drill/proc/message_about_use(atom/target, mob/living/pilot)
	if(!target || !pilot)
		return
	var/audible = "loudly grinding machinery"
	if (iscarbon(target)) //splorch
		audible = "a terrible rending of metal and flesh"
	owner.visible_message(SPAN_DANGER("\The [owner] drives \the [src] into \the [target]."),blind_message = SPAN_WARNING("You hear [audible]."))
	log_and_message_admins("used [src] on [target]", pilot, owner.loc)

/obj/item/mech_equipment/drill/proc/check_drill_integrity()
	if (drill_head.durability <= 0)
		drill_head.shatter()
		drill_head = null

/obj/item/mech_equipment/drill/proc/calculate_drill_cooldown()
	var/delay = 3 SECONDS
	switch (drill_head.material.brute_armor)
		if (15 to INFINITY) delay = 0.5 SECONDS //voxalloy on a good roll
		if (10 to 15) delay = 1 SECOND //titanium, diamond
		if (5 to 10) delay = 2 SECONDS //plasteel, steel
	return delay

/obj/item/mech_equipment/drill/proc/sound_and_message(atom/target)
	playsound(src, 'sound/mecha/mechdrill.ogg', 50, 1)
	owner.visible_message(SPAN_WARNING("\The [owner] starts to drill \the [target]."),blind_message = SPAN_WARNING("You hear a large motor whirring."))

/obj/item/mech_equipment/drill/proc/damage_drill_head(damage_amount)
	drill_head.durability -= 1
	check_drill_integrity()
