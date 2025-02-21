/singleton/species/shapeshifter
	inherent_verbs = list(
		/mob/living/carbon/human/proc/shapeshifter_select_shape,
		/mob/living/carbon/human/proc/shapeshifter_select_hair,
		/mob/living/carbon/human/proc/shapeshifter_select_gender
		)

	var/list/valid_transform_species = list()
	var/monochromatic
	var/default_form = SPECIES_HUMAN

/singleton/species/shapeshifter/get_valid_shapeshifter_forms(mob/living/carbon/human/H)
	return valid_transform_species

/singleton/species/shapeshifter/get_icobase(mob/living/carbon/human/H, get_deform)
	if(!H) return ..(null, get_deform)
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_icobase(H, get_deform)

/singleton/species/shapeshifter/get_race_key(mob/living/carbon/human/H)
	return "[..()]-[GLOB.mob_ref_to_species_name[any2ref(H)]]"

/singleton/species/shapeshifter/get_bodytype(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_bodytype(H)

/singleton/species/shapeshifter/get_blood_mask(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_blood_mask(H)

/singleton/species/shapeshifter/get_damage_mask(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_damage_mask(H)

/singleton/species/shapeshifter/get_damage_overlays(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_damage_overlays(H)

/singleton/species/shapeshifter/get_tail(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_tail(H)

/singleton/species/shapeshifter/get_tail_animation(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_tail_animation(H)

/singleton/species/shapeshifter/get_tail_hair(mob/living/carbon/human/H)
	if(!H) return ..()
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_tail_hair(H)

/singleton/species/shapeshifter/get_husk_icon(mob/living/carbon/human/H)
	if(H)
		var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
		if(S) return S.get_husk_icon(H)
	 return ..()

/singleton/species/shapeshifter/handle_pre_spawn(mob/living/carbon/human/H)
	..()
	GLOB.mob_ref_to_species_name[any2ref(H)] = default_form

/singleton/species/shapeshifter/handle_post_spawn(mob/living/carbon/human/H)
	if(monochromatic)
		H.head_hair_color = H.skin_color
		H.facial_hair_color = H.head_hair_color
	..()

/singleton/species/shapeshifter/post_organ_rejuvenate(obj/item/organ/org, mob/living/carbon/human/H)
	var/obj/item/organ/external/E = org
	if(H && istype(E))
		E.sync_colour_to_human(H)

/singleton/species/shapeshifter/get_pain_emote(mob/living/carbon/human/H, pain_power)
	var/singleton/species/S = GLOB.species_by_name[GLOB.mob_ref_to_species_name[any2ref(H)]]
	return S.get_pain_emote(H, pain_power)

// Verbs follow.
/mob/living/carbon/human/proc/shapeshifter_select_hair()

	set name = "Select Hair"
	set category = "Abilities"

	if(stat || world.time < last_special)
		return

	last_special = world.time + 10

	visible_message(SPAN_NOTICE("\The [src]'s form contorts subtly."))
	if(species.get_hair_styles())
		var/new_hair = input("Select a hairstyle.", "Shapeshifter Hair") as null|anything in species.get_hair_styles()
		change_hair(new_hair ? new_hair : "Bald")
	if(species.get_facial_hair_styles(gender))
		var/new_hair = input("Select a facial hair style.", "Shapeshifter Hair") as null|anything in species.get_facial_hair_styles(gender)
		change_facial_hair(new_hair ? new_hair : "Shaved")

/mob/living/carbon/human/proc/shapeshifter_select_gender()

	set name = "Select Gender"
	set category = "Abilities"

	if(stat || world.time < last_special)
		return

	last_special = world.time + 50

	var/new_gender = input("Please select a gender.", "Shapeshifter Gender") as null|anything in list(FEMALE, MALE, NEUTER, PLURAL)
	if(!new_gender)
		return

	visible_message(SPAN_NOTICE("\The [src]'s form contorts subtly."))
	change_gender(new_gender)

/mob/living/carbon/human/proc/shapeshifter_select_shape()

	set name = "Select Body Shape"
	set category = "Abilities"

	if(stat || world.time < last_special)
		return

	last_special = world.time + 50

	var/new_species = input("Please select a species to emulate.", "Shapeshifter Body") as null|anything in species.get_valid_shapeshifter_forms(src)
	if(!new_species || !GLOB.species_by_name[new_species] || GLOB.mob_ref_to_species_name[any2ref(src)] == new_species)
		return

	GLOB.mob_ref_to_species_name[any2ref(src)] = new_species
	visible_message(SPAN_NOTICE("\The [src] shifts and contorts, taking the form of \a ["\improper [new_species]"]!"))
	regenerate_icons()

/mob/living/carbon/human/proc/shapeshifter_select_colour()

	set name = "Select Body Colour"
	set category = "Abilities"

	if(stat || world.time < last_special)
		return

	last_special = world.time + 50

	var/new_skin = input("Please select a new body color.", "Shapeshifter Colour") as color
	if(!new_skin)
		return
	shapeshifter_set_colour(new_skin)

/mob/living/carbon/human/proc/shapeshifter_set_colour(new_skin)
	skin_color = new_skin
	var/singleton/species/shapeshifter/S = species
	if(S.monochromatic)
		head_hair_color = skin_color
		facial_hair_color = head_hair_color

	for(var/obj/item/organ/external/E in organs)
		E.sync_colour_to_human(src)

	regenerate_icons()
