
//we're plaseholder for now, gonna finish this later

/obj/item/organ/internal/augment/active/clicker
	name = "integrated dartgun"
	desc = "A small implantable dartgun, coming with two toxin-covered flechettes inside augment. Can't be recharged."
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "dartgun"
	action_button_name = "Activate target matrix"
	augment_slots = AUGMENT_EYES
	var/ready_to_fire = FALSE
	var/charges = 2


/obj/item/organ/internal/augment/active/clicker/emp_act(severity)
	if (istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, SPAN_DANGER("Your [name] malfunctions, blinding you!"))
		M.eye_blind = 4
		M.eye_blurry = 8
		if (ready_to_fire)
			ready_to_fire = FALSE
			refresh_action_button()
	..()

// Real augment

/obj/item/organ/internal/augment/active/clicker/bale_eye
	name = "integrated laser"
	desc = "A small laser projector integrated into mechanical eyes lens system. Can recharge itself without a large increase in overall power consumption, but this comes at the cost of much longer recharge time. "
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "bale_eye"
	action_button_name = "Activate target matrix"
	augment_slots = AUGMENT_EYES
	augment_flags = AUGMENT_MECHANICAL
	charges = 8
	/// Shots the capacitor holds when full
	var/max_charges = 8
	var/charge_tick = 0
	/// Organ ticks (one per Life() tick) to charge one shot
	var/recharge_time = 120


/obj/item/organ/internal/augment/active/clicker/bale_eye/activate()
	if(!ready_to_fire)
		ready_to_fire = TRUE
		to_chat(owner, SPAN_WARNING("Augment target matrix active and ready to fire."))
		to_chat(owner, SPAN_GOOD("Matrix online, use ctrl+click on target to perform shooting attack on target outside your point-blank range."))
		playsound(owner, 'sound/weapons/flash.ogg', 35, 1)
	else
		ready_to_fire = FALSE
		to_chat(owner, SPAN_WARNING("You have deactivated your target matrix."))
	refresh_action_button()

/obj/item/organ/internal/augment/active/clicker/bale_eye/Process()
	if(charges >= max_charges)
		return PROCESS_KILL
	charge_tick++
	if(charge_tick >= recharge_time)
		charge_tick = 0
		charges++
		if(owner)
			to_chat(owner, SPAN_NOTICE("Your integrated laser's capacitor has charged another shot."))
	// The countdown to the next shot changes every tick
	refresh_action_button()

/// Fires at a ctrl+clicked target. Returns FALSE when the click should do a normal ctrl+click instead.
/obj/item/organ/internal/augment/active/clicker/bale_eye/proc/try_fire(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!ready_to_fire || !owner || !target_turf)
		return FALSE
	if(charges <= 0)
		to_chat(owner, SPAN_WARNING("Your weapon is unable to fire due to insufficient charge!"))
		return TRUE
	if(owner.glasses)
		to_chat(owner, SPAN_WARNING("Your weapon is unable to fire because your eyes are covered by something!"))
		return TRUE
	var/turf/start = get_turf(owner)
	var/obj/item/projectile/beam/smalllaser/beam = new(start)
	playsound(start, 'sound/weapons/Taser.ogg', 25, 1)
	beam.original = target
	beam.current = target
	beam.starting = start
	beam.shot_from = name
	beam.launch(target, owner.zone_sel?.selecting, target_turf.x - start.x, target_turf.y - start.y)
	charges--
	owner.next_click = world.time + 2 SECONDS
	refresh_action_button()
	return TRUE

/// Shots left, cyan while the target matrix is armed, plus the time to the next shot while recharging.
/obj/item/organ/internal/augment/active/clicker/bale_eye/get_action_button_label()
	var/text_color = ready_to_fire ? COLOR_CYAN : COLOR_WHITE
	if(charges <= 0)
		text_color = COLOR_RED_LIGHT
	if(charges >= max_charges)
		return create_action_button_label("[charges]", text_color)
	return create_action_button_label("[charges]<br>[get_seconds_to_next_shot()]s", text_color)

/// Rough seconds until the next shot, as the capacitor charges once per Life() tick.
/obj/item/organ/internal/augment/active/clicker/bale_eye/proc/get_seconds_to_next_shot()
	return ceil((recharge_time - charge_tick) * SSmobs.wait / (1 SECOND))

/obj/item/device/augment_implanter/bale_eye
	augment = /obj/item/organ/internal/augment/active/clicker/bale_eye

/datum/uplink_item/item/augment/aug_bale_eye
	name = "Integrated Laser CBM (eyes)"
	desc = "An augment that slots small self-rechargable integrated laser. Target matrix allows firing at any targets, but with fairly low accuracy. \
	It can be easily concealed. It requires NON-ORGANIC eyes."
	item_cost = 24
	path = /obj/item/device/augment_implanter/bale_eye
