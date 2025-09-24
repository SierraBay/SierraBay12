
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
	var/charge_tick = 0
	var/recharge_time = 120


/obj/item/organ/internal/augment/active/clicker/bale_eye/activate()
	if(!ready_to_fire)
		ready_to_fire = TRUE
		to_chat(owner, SPAN_WARNING("Augment target matrix active and ready to fire."))
		to_chat(owner, SPAN_GOOD("Matrix online, use ctrl+click on target to perform shooting attack on target outside your point-blank range."))
		playsound(owner, 'sound/weapons/flash.ogg', 35, 1)
		return

	ready_to_fire = FALSE
	to_chat(owner, SPAN_WARNING("You have deactivated your target matrix."))

/obj/item/organ/internal/augment/active/clicker/bale_eye/Process()
	var/mob/living/carbon/human/H = src
	if (charges >= 8)
		return PROCESS_KILL
	if (++charge_tick < recharge_time)
		return 0
	charge_tick = 0
	charges += 1
	to_chat(H, SPAN_NOTICE("Your integrated laser's internal capacitor charged energy worth for another shot."))
	return 1

/obj/item/device/augment_implanter/bale_eye
	augment = /obj/item/organ/internal/augment/active/clicker/bale_eye

/datum/uplink_item/item/augment/aug_bale_eye
	name = "Concealed Energy Shield CBM (arm)"
	desc = "An augment that slots small self-rechargable integrated laser. Target matrix allows firing at any targets, but with fairly low accuracy. \
	It can be easily consealed. It requires NON-ORGANIC eyes."
	item_cost = 24
	path = /obj/item/device/augment_implanter/bale_eye
