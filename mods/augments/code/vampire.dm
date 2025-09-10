/obj/item/organ/internal/augment/active/vampire
	name = "vampire"
	augment_slots = AUGMENT_HEAD
	icon = 'mods/augments/icons/augment.dmi'
	icon_state = "vampire"
	desc = "A small computer system constantly tracks your physiological state and vital signs. A muscle gesture can be used to receive a simple diagnostic report, not unlike that from a handheld scanner."
	augment_flags = AUGMENT_BIOLOGICAL
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 4)
	var/amount_per_transfer_from_this = 5
	var/fangs = 0
	var/max_reagents = 5

/*
/obj/item/organ/internal/augment/active/vampire/activate()
	var/mob/living/carbon/human/H = src
	var/obj/item/grab/G = H.get_active_hand()
	if (!istype(G))
		to_chat(H, SPAN_WARNING( "You must be grabbing a victim in your active hand to use your augmentations."))
		return

	if(!G.can_absorb())
		to_chat(H, SPAN_WARNING( "You must have a tighter grip on victim to drain their blood."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if (!istype(T) || T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_PAIN)
		to_chat(H, SPAN_WARNING( "[T] is not a creature you can transfer blood from."))
		return

	if(T.head && (T.head.item_flags & ITEM_FLAG_AIRTIGHT))
		to_chat(H, SPAN_WARNING( "[T]'s headgear is blocking the way to the neck."))
		return

	var/obj/item/blocked = H.check_mouth_coverage()
	if(blocked)
		to_chat(H, SPAN_WARNING( "\The [blocked] is in the way of your fangs!"))
		return

	if(fangs)
		to_chat(H, SPAN_WARNING( "Your fangs are already sunk into a victim's neck!"))
		return

	var/blood = 0
	var/blood_total = 0
	var/blood_usable = 0
	var/blood_drained = 0

	H.visible_message(SPAN("danger", "[H] bites [T]'s neck!"),\
						   SPAN("danger", "You bite [T]'s neck and begin to drain their blood."),\
						   SPAN("danger", "You hear a soft puncture and a wet sucking noise"))

	var/endsuckmsg = "You extract your fangs from [T.name]'s neck and stop draining them of blood."
	H.visible_message(SPAN("danger", "[H] stops biting [T.name]'s neck!"),\
						   SPAN("notice", "[endsuckmsg]"))
*/

// Зона вайбкода

/obj/item/organ/internal/augment/active/vampire/Initialize()
	. = ..()
	create_reagents(5)


/obj/item/organ/internal/augment/active/vampire/activate()

	if(!reagents)
		return

	var/list/choices = list(
		"Draw" = mutable_appearance('mods/augments/icons/augment.dmi', "vampire-draw"),
		"Inject" = mutable_appearance('mods/augments/icons/augment.dmi', "vampire-inject"),
		"Attack" = mutable_appearance('mods/augments/icons/augment.dmi', "vampire-bite"),
	//	"Drain" = mutable_appearance('mods/augments/icons/augment.dmi', "vampire-drain")
	)

	var/choice = show_radial_menu(usr, usr, choices, radius = 42, require_near = TRUE, tooltips = TRUE, check_locs = list(src))

	switch(choice)
		if("Draw")
			draw_from_container(owner)
		if("Inject")
			inject(owner)
		if("Attack")
			attack_target(owner)
//		if("Drain")
//			drain_blood(H)

/obj/item/organ/internal/augment/active/vampire/proc/draw_from_container(mob/owner)
	var/obj/item/reagent_containers/target = usr.get_active_hand()

	if(owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to draw liquids through it!"))
		return

	if(!istype(target))
		to_chat(owner, SPAN_NOTICE("You need to hold container in your hands to draw reagents from it."))
		return

	if(!target.reagents.total_volume)
		to_chat(owner, SPAN_NOTICE("[target] is empty."))
		return

	if(!target.is_open_container() && !istype(target, /obj/structure/reagent_dispensers) && !istype(target, /obj/item/slime_extract))
		to_chat(owner, SPAN_NOTICE("You cannot directly remove reagents from this object."))
		return

	if(reagents.total_volume >= max_reagents)
		to_chat(owner, SPAN_NOTICE("Your fangs is full. Сlean them from reagents first."))
		return

	var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You fill your fangs with [trans] units of the solution."))

	update_icon()

/obj/item/organ/internal/augment/active/vampire/proc/inject(mob/owner)
	var/target
	var/obj/item/reagent_containers/C = usr.get_active_hand()
	var/obj/item/grab/G = owner.get_active_hand()

	if(owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to inject liquids through it!"))
		return

	if(owner.pulling && iscarbon(owner.pulling))
		target = owner.pulling

	if(istype(C))
		target = C

	if(istype(G))
		target = G

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to hold container in your hands or grab victim to inject liquids into them."))
		return

	if(istype(target, /obj/item/implantcase/chem))
		return

	if(C && !C.is_open_container() && !ismob(target) && !istype(target, /obj/item/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/smokable/cigarette) && !istype(target, /obj/item/storage/fancy/smokable))
		to_chat(owner, SPAN_NOTICE("You cannot directly fill this object."))
		return
	if(C && !C.reagents.get_free_space())
		to_chat(owner, SPAN_NOTICE("[target] is full."))
		return

	if(isliving(target))
		vampirestab(target, owner)
		return

	var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You inject \the [target] with [trans] units of the solution. \The [src] now contains [src.reagents.total_volume] units."))

	update_icon()

/obj/item/organ/internal/augment/active/vampire/proc/attack_target(mob/owner)
	var/target
	var/obj/item/clothing/mask/M
	var/obj/item/grab/G = owner.get_active_hand()

	if(owner.wear_mask && istype(M, /obj/item/clothing/mask/muzzle/tape) && istype(M, /obj/item/clothing/mask/surgical))
		to_chat(owner, SPAN_WARNING("You pierce \The [M] covering your mouth with your sharp fangs, chewing it!"))
		visible_message(SPAN_DANGER("Large fangs extracts from [owner]'s mouth and tears \The [M],  apart."))
		qdel(owner.wear_mask)

	if(owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to bite through it!"))
		return

	if(owner.pulling && iscarbon(owner.pulling))
		target = owner.pulling

	if(istype(G))
		target = G

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to pull or grab someone to bite them!"))
		return

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target

		var/target_zone = check_zone(owner.zone_sel.selecting)
		var/obj/item/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting || affecting.is_stump())
			to_chat(owner, SPAN_DANGER("They are missing that limb!"))
			return

		var/hit_area = affecting.name

		owner.visible_message(SPAN_DANGER("[owner] wildly bites [target] in \the [hit_area] with his razor-sharp fangs!"))
		H.apply_damage(15, DAMAGE_BRUTE, target_zone, damage_flags=DAMAGE_FLAG_SHARP)
	admin_attack_log(owner, target, "Has bited", "Has been bitten", "bitten")

/*

/obj/item/organ/internal/augment/active/vampire/proc/drain_blood(mob/owner)
	var/source
	var/is_mob = FALSE
	if(owner.pulling && iscarbon(owner.pulling))
		source = owner.pulling
		is_mob = TRUE
		var/obj/item/reagent_containers/ivbag/held = owner.held_item()
		if(istype(held))
			source = held
		else
			to_chat(H, SPAN_WARNING("No blood source! Grab a living carbon or hold a blood pack."))
			return
	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(H, SPAN_WARNING("The implant is full!"))
		return

	var/datum/reagent/blood/blood_reagent
	var/drain_amount = min(10, reagents.maximum_volume - reagents.total_volume)
	var/blood_data

	if(is_mob)
		var/mob/living/carbon/target = source
		if(target.stat == DEAD || target.blood_volume < 1)
			to_chat(H, SPAN_WARNING("No blood to drain!"))
			return

		blood_data = target.get_blood_data()
		if(!blood_data || !(owner.dna.b_type in blood_data.receiver))
			to_chat(H, SPAN_WARNING("The blood is incompatible with you!"))
			return

		drain_amount = min(drain_amount, target.blood_volume)
		if(drain_amount <= 0)
			return

		target.blood_volume -= drain_amount
		blood_reagent = new /datum/reagent/blood(drain_amount)
		blood_reagent.data = blood_data
		reagents.add_reagent(/datum/reagent/blood, drain_amount, data = blood_data)

		var/obj/item/reagent_containers/ivbag/bag = source
		var/current_blood = bag.reagents.get_reagent_amount(/datum/reagent/blood)
		if(current_blood < 1)
			to_chat(H, SPAN_WARNING("No blood in the pack!"))
			return

		blood_reagent = bag.reagents.get_reagent(/datum/reagent/blood)
		blood_data = blood_reagent?.data
		if(!blood_data || !(owner.dna.b_type in blood_data.receiver))
			to_chat(H, SPAN_WARNING("The blood is incompatible with you!"))
			return

		drain_amount = min(drain_amount, current_blood)
		if(drain_amount <= 0)
			return

		bag.reagents.trans_to(src, drain_amount, transfered_by = owner)

	to_chat(H, SPAN_DANGER("You drain [drain_amount] units of blood."))
	if(is_mob)
		var/mob/living/carbon/target = source
		to_chat(target, SPAN_DANGER("[owner] drains your blood!"))
		if(target.blood_volume <= BLOOD_VOLUME_BAD)
	bag.update_icon()
	return
*/

// Morale support (reckless copypaste from syringes.dm) section

/obj/item/organ/internal/augment/active/vampire/proc/vampirestab(mob/living/carbon/target, mob/living/carbon/owner)
	var/should_admin_log = reagents.should_admin_log()
	if(istype(target, /mob/living/carbon/human))

		var/mob/living/carbon/human/H = target

		var/target_zone = check_zone(owner.zone_sel.selecting)
		var/obj/item/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting || affecting.is_stump())
			to_chat(owner, SPAN_DANGER("They are missing that limb!"))
			return

		var/hit_area = affecting.name

		if((owner != target) && H.check_shields(7, src, owner, "\the [src]"))
			return

		if (target != owner && H.get_blocked_ratio(target_zone, DAMAGE_BRUTE, damage_flags=DAMAGE_FLAG_SHARP) > 0.1 && prob(50))
			for(var/mob/O in viewers(world.view, owner))
				O.show_message(text(SPAN_DANGER("[owner] tries to bite [target] in \the [hit_area] with [src.name], but the attack is deflected by armor!")), 1)

			admin_attack_log(owner, target, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")
			return

		owner.visible_message(SPAN_DANGER("[owner] deeply bites [target] in \the [hit_area] with his razor-sharp fangs!"))
		target.apply_damage(3, DAMAGE_BRUTE, target_zone, damage_flags=DAMAGE_FLAG_SHARP)

	else
		owner.visible_message(SPAN_DANGER("[owner] stabs [target] with [src.name]!"))
		target.apply_damage(3, DAMAGE_BRUTE)

	var/trans = reagents.trans_to_mob(target, 5, CHEM_BLOOD)
	if (should_admin_log)
		var/contained_reagents = reagents.get_reagents()
		admin_inject_log(owner, target, src, contained_reagents, trans, violent=1)

// Traitor section

/obj/item/device/augment_implanter/vampire
	augment = /obj/item/organ/internal/augment/active/vampire
