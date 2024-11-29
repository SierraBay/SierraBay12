/obj/item/material/utensil
	icon = 'icons/obj/machines/kitchen.dmi'
	w_class = ITEM_SIZE_TINY
	thrown_force_multiplier = 1
	origin_tech = list(TECH_MATERIAL = 1)
	attack_verb = list("attacked", "stabbed", "poked")
	max_force = 8
	force_multiplier = 0.1 // 6 when wielded with hardness 60 (steel)
	thrown_force_multiplier = 0.25 // 5 when thrown with weight 20 (steel)
	puncture = TRUE
	default_material = MATERIAL_ALUMINIUM
	applies_material_name = TRUE

	/// Descriptive string for currently loaded food object
	var/loaded

	/// Whether the utensil is able to collect reagents from food
	var/scoop_food = TRUE


/obj/item/material/utensil/Initialize()
	. = ..()
	if (prob(60))
		pixel_y = rand(0, 4)
	if (material.conductive)
		obj_flags |= OBJ_FLAG_CONDUCTIBLE
	if (scoop_food)
		create_reagents(5)


/obj/item/material/utensil/use_after(mob/living/carbon/subject, mob/living/carbon/user)
	if (!istype(subject))
		return FALSE
	if (reagents.total_volume > 0)
		if(subject == user)
			if(!subject.can_eat(loaded))
				return TRUE
			switch(subject.get_fullness())
				if (0 to 50)
					to_chat(subject, SPAN_DANGER("You ravenously stick \the [src] into your mouth and gobble the food!"))
				if (50 to 150)
					to_chat(subject, SPAN_NOTICE("You hungrily chew the food on \the [src]."))
				if (150 to 350)
					to_chat(subject, SPAN_NOTICE("You chew the food on \the [src]."))
				if (350 to 550)
					to_chat(subject, SPAN_NOTICE("You unwillingly chew the food on \the [src]."))
				if (550 to INFINITY)
					to_chat(subject, SPAN_WARNING("You cannot take one more bite from \the [src]!"))
					return TRUE
		else
			user.visible_message(SPAN_WARNING("\The [user] begins to feed \the [subject]!"))
			if (!subject.can_force_feed(user, loaded) || !do_after(user, 5 SECONDS, subject, DO_PUBLIC_UNIQUE))
				return TRUE
			if (user.get_active_hand() != src)
				return TRUE
			subject.visible_message(SPAN_NOTICE("\The [user] feeds some [loaded] to \the [subject] with \the [src]."))
		reagents.trans_to_mob(subject, reagents.total_volume, CHEM_INGEST)
		playsound(subject.loc,'sound/items/eatfood.ogg', rand(10,40), TRUE)
		ClearOverlays()
		return TRUE
	else
		to_chat(user, SPAN_WARNING("You don't have anything on \the [src]."))
		return TRUE


/obj/item/material/utensil/knife
	name = "table knife"
	desc = "A simple table knife, used to cut up individual portions of food."
	icon = 'icons/obj/weapons/knife.dmi'
	icon_state = "table"
	item_state = "knife"
	scoop_food = FALSE
	edge = TRUE
	attack_verb = list("slashed", "stabbed", "cut")
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES

/obj/item/material/utensil/knife/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/utensil/knife/silver/default_material = MATERIAL_SILVER
/obj/item/material/utensil/knife/titanium/default_material = MATERIAL_TITANIUM


/obj/item/material/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/material/utensil/fork/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/utensil/fork/silver/default_material = MATERIAL_SILVER
/obj/item/material/utensil/fork/titanium/default_material = MATERIAL_TITANIUM


/obj/item/material/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")
	force_multiplier = 0.1 //2 when wielded with weight 20 (steel)

/obj/item/material/utensil/spoon/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/utensil/spoon/silver/default_material = MATERIAL_SILVER
/obj/item/material/utensil/spoon/titanium/default_material = MATERIAL_TITANIUM


/obj/item/material/utensil/spork
	name = "spork"
	desc = "It's a spork. It's much like a fork, but much blunter."
	icon_state = "spork"

/obj/item/material/utensil/spork/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/utensil/spork/silver/default_material = MATERIAL_SILVER
/obj/item/material/utensil/spork/titanium/default_material = MATERIAL_TITANIUM


/obj/item/material/utensil/foon
	name = "foon"
	desc = "It's a foon. It's much like a spoon, but much sharper."
	icon_state = "foon"

/obj/item/material/utensil/foon/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/utensil/foon/silver/default_material = MATERIAL_SILVER
/obj/item/material/utensil/foon/titanium/default_material = MATERIAL_TITANIUM


/obj/item/storage/box/silverware
	name = "silverware box"
	startswith = list(
		/obj/item/material/utensil/knife/silver = 4,
		/obj/item/material/utensil/fork/silver = 4,
		/obj/item/material/utensil/spoon/silver = 4
	)


/obj/item/material/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "rolling_pin"
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	default_material = MATERIAL_WOOD
	max_force = 15
	force_multiplier = 0.7 // 10 when wielded with weight 15 (wood)
	thrown_force_multiplier = 1 // as above

/obj/item/material/rollingpin/plastic/default_material = MATERIAL_PLASTIC
/obj/item/material/rollingpin/aluminium/default_material = MATERIAL_ALUMINIUM


/obj/item/material/rollingpin/use_before(mob/living/target, mob/living/user)
	. = FALSE
	if ((MUTATION_CLUMSY in user.mutations) && prob(50) && user.unEquip(src))
		var/datum/pronouns/pronouns = user.choose_from_pronouns()
		user.visible_message(
			SPAN_WARNING("\The [user] manages to hit [pronouns.self] on the head with \the [src]!"),
			SPAN_WARNING("\The [src] slips out of your hand and hits your head!"),
			SPAN_WARNING("Bonk!")
		)
		user.take_organ_damage(10, 0)
		user.Paralyse(2)
		return TRUE
