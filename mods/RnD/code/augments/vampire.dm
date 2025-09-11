/obj/item/organ/internal/augment/active/vampire
	name = "vampire"
	augment_slots = AUGMENT_HEAD
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "vampire"
	desc = "A pair of cybernetic fangs, installing into organic mouth, which can be used as some sort of robust hypospray. Make sure you can survive stake to heart."
	augment_flags = AUGMENT_BIOLOGICAL
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 4)
	var/amount_per_transfer_from_this = 5
	var/fangs = 0
	var/max_reagents = 5


/obj/item/organ/internal/augment/active/vampire/Initialize()
	. = ..()
	create_reagents(5)


/obj/item/organ/internal/augment/active/vampire/activate()

	if(!reagents)
		return

	var/list/choices = list(
		"Draw" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-draw"),
		"Inject" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-inject"),
		"Bite" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-bite"),
		"Gulp" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-gulp")
	)

	var/choice = show_radial_menu(usr, usr, choices, radius = 42, require_near = TRUE, tooltips = TRUE, check_locs = list(src))

	switch(choice)
		if("Draw")
			draw_from_container(owner)
		if("Inject")
			inject(owner)
		if("Bite")
			attack_target(owner)
		if("Gulp")
			gulp(owner)


/obj/item/organ/internal/augment/active/vampire/proc/draw_from_container(mob/owner)
	var/target
	var/obj/item/reagent_containers/C = usr.get_active_hand()

	if(owner.wear_mask && owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to draw liquids through it!"))
		return

	if(istype(C))
		target = C

	if(owner.pulling && iscarbon(owner.pulling))
		target = owner.pulling

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to hold container in your hands to draw reagents from it."))
		return

	if(isliving(target))
		vampire_sample(target, owner)
		return

	if(!isliving(target) && !C.reagents.total_volume)
		to_chat(owner, SPAN_NOTICE("[target] is empty."))
		return

	if(!isliving(target) && !C.is_open_container() && !istype(target, /obj/structure/reagent_dispensers) && !istype(target, /obj/item/slime_extract))
		to_chat(owner, SPAN_NOTICE("You cannot directly remove reagents from this object."))
		return

	if(!isliving(target) && reagents.total_volume >= max_reagents)
		to_chat(owner, SPAN_NOTICE("Your fangs is full. Сlean them from reagents first."))
		return

	var/trans = C.reagents.trans_to_obj(src, amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You fill your fangs with [trans] units of the solution."))

	update_icon()


/obj/item/organ/internal/augment/active/vampire/proc/inject(mob/owner)
	var/target
	var/obj/item/reagent_containers/C = usr.get_active_hand()

	if(owner.wear_mask && owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to inject liquids through it!"))
		return

	if(istype(C))
		target = C

	if(owner.pulling && iscarbon(owner.pulling))
		target = owner.pulling

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to hold container in your hands or grab victim to inject liquids into them."))
		return

	if(istype(target, /obj/item/implantcase/chem))
		return

	if(!isliving(target) && !C.is_open_container() && !ismob(target) && !istype(target, /obj/item/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/smokable/cigarette) && !istype(target, /obj/item/storage/fancy/smokable))
		to_chat(owner, SPAN_NOTICE("You cannot directly fill this object."))
		return

	if(!isliving(target) && !C.reagents.get_free_space())
		to_chat(owner, SPAN_NOTICE("[target] is full."))
		return

	if(isliving(target))
		vampire_stab(target, owner)
		return

	var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You inject \the [target] with [trans] units of the solution. \The [src] now contains [src.reagents.total_volume] units."))

	update_icon()

/obj/item/organ/internal/augment/active/vampire/proc/attack_target(mob/owner)
	var/target


	if(owner.wear_mask && owner.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)
		to_chat(owner, SPAN_WARNING("The material covering your mouth is too thick to bite through it!"))
		return

	if(owner.pulling && iscarbon(owner.pulling))
		target = owner.pulling

	if(!target)
		to_chat(owner, SPAN_NOTICE("You need to pull someone to bite them!"))
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
		playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
	admin_attack_log(owner, target, "Has bited", "Has been bitten", "bitten")

/obj/item/organ/internal/augment/active/vampire/proc/gulp(mob/owner)
	var/should_admin_log = reagents.should_admin_log()

	if (should_admin_log)
		var/proceed = alert(owner, "Reagents in your fangs are potentially harmful. Are you sure?", "Safety Alert", "I am!", "No.")
		if (proceed != "I am!")
			return

	if(!src.reagents.total_volume)
		to_chat(owner, SPAN_NOTICE("Your fangs are empty."))
		return

	var/trans = reagents.trans_to_mob(owner, 5, CHEM_BLOOD)
	to_chat(owner, SPAN_NOTICE("You lower the barrier between your fangs casing and your bloodstream. \The [src] now contains [src.reagents.total_volume] units."))
	if (should_admin_log)
		var/contained_reagents = reagents.get_reagents()
		admin_inject_log(owner, src, contained_reagents, trans, violent=0)


// Morale support (reckless copypaste from syringes.dm) section

/obj/item/organ/internal/augment/active/vampire/proc/vampire_stab(mob/living/carbon/target, mob/living/carbon/owner)
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
		playsound(loc, 'sound/weapons/bite.ogg', 25, 1)

	else
		owner.visible_message(SPAN_DANGER("[owner] deeply bites [target] with their razor-sharp fangs!"))
		target.apply_damage(3, DAMAGE_BRUTE)

	var/trans = reagents.trans_to_mob(target, 5, CHEM_BLOOD)
	if (should_admin_log)
		var/contained_reagents = reagents.get_reagents()
		admin_inject_log(owner, target, src, contained_reagents, trans, violent=1)


/obj/item/organ/internal/augment/active/vampire/proc/vampire_sample(mob/living/carbon/target, mob/living/carbon/owner)
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

		owner.visible_message(SPAN_DANGER("[owner] deeply bites [target] in \the [hit_area] with their razor-sharp fangs!"))
		target.apply_damage(3, DAMAGE_BRUTE, target_zone, damage_flags=DAMAGE_FLAG_SHARP)
		playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
	else
		owner.visible_message(SPAN_DANGER("[owner] bites [target] with their razor-sharp fangs!"))
		target.apply_damage(3, DAMAGE_BRUTE)
		playsound(loc, 'sound/weapons/bite.ogg', 25, 1)

	var/amount = min(reagents.get_free_space(), amount_per_transfer_from_this)
	to_chat(owner, SPAN_NOTICE("You fill your fangs with [target] blood."))
	target.take_blood(src, amount)


// Traitor section

/obj/item/device/augment_implanter/vampire
	augment = /obj/item/organ/internal/augment/active/vampire

/datum/uplink_item/item/augment/aug_vampire
	name = "Vampire Augment (head)"
	desc = "An augment that adds two sharp fangs to your mouth. It can store chemicals and inject them into vessels or people. \
	It can be easily concealed, but usage of augment is fairly dramatic. It requires ORGANIC head."
	item_cost = 32
	path = /obj/item/device/augment_implanter/vampire
