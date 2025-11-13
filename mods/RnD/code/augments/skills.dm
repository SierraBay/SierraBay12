/obj/item/organ/internal/augment/active/neural_interface
	name = "neural interface"
	augment_slots = AUGMENT_HEAD
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "chip"
	desc = "Neural interface suit, working with 'shards' - tiny memory disks, which can host various information. From data to pre-installed skills."
	action_button_name = "Interact with shard port"
	augment_flags = AUGMENT_BIOLOGICAL | AUGMENT_SCANNABLE
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 4)

	var/obj/item/neural_chip/chip

	/// Unique ID for collecting the right effect in skill handling
	var/id

	/// Which abilities does this impact?
	var/list/buffs = list()

	/// If organ is damaged, should we reduce anything?
	var/list/injury_debuffs = list()

	/// Only subtypes of /datum/skill_buff/augment
	var/buffpath = /datum/skill_buff/augment

	/// Mostly to control if we should remove buffs when we go
	var/active = FALSE

	/// If we applied a debuff
	var/debuffing = FALSE

/obj/item/organ/internal/augment/active/neural_interface/emp_act(severity)
	. = ..()
	if (owner && active)
		if (prob(100 - (20 * severity))) // 60% chance for EMP_ACT_LIGHT and 80% chance for EMP_ACT_HEAVY severity, respectively
			to_chat(owner, SPAN_WARNING("You feel a wave of nausea as your [name] deactivates."))
			active = FALSE
/*
/obj/item/organ/internal/augment/active/neural_interface/activate()

	var/list/choices = list(
		"Insert" = mutable_appearance('mods/RnD/icons/augment.dmi', "chip-insert"),
		"Eject" = mutable_appearance('mods/RnD/icons/augment.dmi', "chip-eject"),
		"Show Info" = mutable_appearance('mods/RnD/icons/augment.dmi', "chip-info")
	)

	var/choice = show_radial_menu(usr, usr, choices, radius = 42, require_near = TRUE, tooltips = TRUE, check_locs = list(src))

	switch(choice)
		if("Insert")
			insert(owner)
		if("Eject")
			eject(owner)
		if("Show Info")
			show_info(owner)
*/
/*
/obj/item/organ/internal/augment/active/neural_interface/proc/insert(mob/owner)
	var/target
	var/obj/item/neural_chip/C = usr.get_active_hand()

	if(owner.wear_mask && owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to draw liquids through it!"))
		return

	if(istype(C))
		target = C

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to hold container in your hands to draw reagents from it."))
		return

	if(!isliving(target) && !C.reagents.total_volume)
		to_chat(owner, SPAN_NOTICE("[target] is empty."))
		return

	if(!isliving(target) && reagents.total_volume >= max_reagents)
		to_chat(owner, SPAN_NOTICE("Your fangs is full. Сlean them from reagents first."))
		return

	var/trans = C.reagents.trans_to_obj(src, amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You fill your fangs with [trans] units of the solution."))

	update_icon()
*/


/*
/obj/item/organ/internal/augment/active/neural_interface/onInstall()
	if (owner.get_skill_value(chip.skill_type))
	if (length(buffs))
		var/datum/skill_buff/augment/A
		A = owner.buff_skill(buffs, 0, buffpath)
		if (A && istype(A))
			active = TRUE
			A.id = id
*/

/obj/item/organ/internal/augment/active/neural_interface/onRemove()
	debuffing = FALSE
	if (!active)
		return
	for (var/datum/skill_buff/augment/D as anything in owner.fetch_buffs_of_type(buffpath, 0))
		if (D.id != id)
			continue
		D.remove()
		return




// Chipin-in section

/obj/item/neural_chip
	name = "neural chip"
	desc = "master neural chip object, i don't wanna chipin-in."
	// var/skill_type =
