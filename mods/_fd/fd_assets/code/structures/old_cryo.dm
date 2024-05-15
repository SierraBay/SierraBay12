/mob/living/carbon/human/joinable
	var/mob/living/carbon/human/joinable/brainmob

/mob/living/carbon/human/joinable/attack_ghost(mob/observer/ghost/user)
	var/question = "�� �������, ��� ������ ������ ���� �� ��������� �� �����������?"
	var/ask = alert(question, "�� �� ��� ������� �������� ����, ��� �� �� ��������� ������� ������� ��� ���������!", "��", "���")
	if(!ask)
		return
	if(ask == "���" || mind)
		return
	var/datum/ghosttrap/T = get_ghost_trap("space sleeper")
	T.transfer_personality(user, src)

/mob/living/carbon/human/joinable/proc/PickName()
	src.brainmob.real_name = src.brainmob.name

/mob/living/carbon/human/joinable/proc/UpdateNames()
	var/new_name = brainmob ? brainmob.real_name : ""
	if (new_name)
		if (brainmob)
			brainmob.SetName(new_name)
		SetName("\the [new_name]'s [initial(name)]")
		return
	SetName("\the [initial(name)]")

/singleton/hierarchy/outfit/survivor
	name = "Space Sleeper"
	shoes = /obj/item/clothing/shoes/black
	uniform = /obj/item/clothing/under/frontier/old
	id_slot = slot_wear_id
	id_types = list(/obj/item/card/id/civilian)

#define SURVIVOR_SPAWNER_RANDOM_NAME       FLAG(0)
#define SURVIVOR_SPAWNER_CUT_SURVIVAL      FLAG(1)
#define SURVIVOR_SPAWNER_CUT_ID_PDA        (SURVIVOR_SPAWNER_RANDOM_NAME | SURVIVOR_SPAWNER_CUT_SURVIVAL)
#define SURVIVOR_SPAWNER_PLAIN_HEADSET     FLAG(2)

#define SURVIVOR_SPAWNER_RANDOM_SKIN_TONE    FLAG(3)
#define SURVIVOR_SPAWNER_RANDOM_SKIN_COLOR   FLAG(4)
#define SURVIVOR_SPAWNER_RANDOM_HAIR_COLOR   FLAG(5)
#define SURVIVOR_SPAWNER_RANDOM_HAIR_STYLE   FLAG(6)
#define SURVIVOR_SPAWNER_RANDOM_FACIAL_STYLE FLAG(7)
#define SURVIVOR_SPAWNER_RANDOM_EYE_COLOR    FLAG(8)
#define SURVIVOR_SPAWNER_RANDOM_GENDER       FLAG(9)

#define SURVIVOR_SPAWNER_NO_RANDOMIZATION ~(SURVIVOR_SPAWNER_RANDOM_NAME|SURVIVOR_SPAWNER_RANDOM_SKIN_TONE|SURVIVOR_SPAWNER_RANDOM_SKIN_COLOR|SURVIVOR_SPAWNER_RANDOM_HAIR_COLOR|SURVIVOR_SPAWNER_RANDOM_HAIR_STYLE|SURVIVOR_SPAWNER_RANDOM_FACIAL_STYLE|SURVIVOR_SPAWNER_RANDOM_EYE_COLOR)


/obj/structure/abandoned_cryo
	name = "emergency cryogenic freezer"
	desc = "A man-sized pod of pretty old design."
	icon = 'mods/_fd/fd_assets/icons/structures/old_cryo.dmi'
	icon_state = "pod_closed"
	density = TRUE
	anchored = TRUE
	var/opened = FALSE

// corpse landmark code

	var/species = list(SPECIES_HUMAN)                 // List of species to pick from.
	var/survivor_outfits = list(/singleton/hierarchy/outfit/survivor) // List of outfits to pick from. Uses pickweight()
	var/spawn_flags = (~0)

	var/skin_colors_per_species   = list() // Custom skin colors, per species -type-, if any. For example if you want dead Skrell to always have blue headtails, or similar
	var/skin_tones_per_species    = list() // Custom skin tones, per species -type-, if any. See above as to why.
	var/eye_colors_per_species    = list() // Custom eye colors, per species -type-, if any. See above as to why.
	var/hair_colors_per_species   = list() // Custom hair colors, per species -type-, if any. See above as to why.
	var/hair_styles_per_species   = list() // Custom hair styles, per species -type-, if any. For example if you want a punk gang with handlebars.
	var/facial_styles_per_species = list() // Custom facial hair styles, per species -type-, if any. See above as to why
	var/genders_per_species       = list() // For gender biases per species -type-

/obj/structure/abandoned_cryo/attackby(obj/item/C, mob/user)
	if(isCrowbar(C) && user.skill_check(SKILL_HAULING, SKILL_TRAINED))
		if(opened)
			to_chat(user, SPAN_DANGER("Pod were alreade opened!"))
		else if(!opened)
			user.visible_message(
				SPAN_WARNING("\The [user] wedges \the [C] into \the [src] and starts forcing it open!"),
				SPAN_DANGER("You start forcing \the [src] open."),
				SPAN_WARNING("You hear metal groaning and grinding!")
			)
			playsound(loc, 'sound/machines/airlock_creaking.ogg', 100, TRUE)
			if(do_after(user, 30, src))
				opened = TRUE
				icon_state = "pod_opened"
				var/new_species = pickweight(species)
				var/mob/living/carbon/human/joinable/survivor = new (loc, new_species)
				randomize_appearance(survivor, new_species)
				equip_outfit(survivor)
				survivor.update_icon()
				survivor.add_language(LANGUAGE_SPACER)
				if(prob(30))
					survivor.adjustBruteLoss(20)
					user.visible_message(
						SPAN_DANGER("You damaged \the [src], while trying to open it!"),
					)
	if(isWrench(C))
		if(!anchored)
			anchored = TRUE
			to_chat(user, "<span class='notice'>You secure pod to the floor.</span>")
		else
			to_chat(user, "<span class='notice'>You unsecure pod from the floor.</span>")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			anchored = FALSE

	if(isMultitool(C) && user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		if(opened)
			to_chat(user, SPAN_DANGER("Pod were alreade opened!"))
		else if(!opened)
			user.visible_message(
				SPAN_WARNING("\The [user] starts to hacking \the [src] with \the [C]!"),
				SPAN_DANGER("You start hacking \the [src]."),
				SPAN_WARNING("You hear various beeps!")
			)
			playsound(loc, 'sound/machines/button4.ogg', 100, TRUE)
			if(do_after(user, 50, src))
				opened = TRUE
				icon_state = "pod_opened"
				var/new_species = pickweight(species)
				var/mob/living/carbon/human/joinable/survivor = new (loc, new_species)
				randomize_appearance(survivor, new_species)
				equip_outfit(survivor)
				survivor.update_icon()
				survivor.add_language(LANGUAGE_SPACER)

	else
		user.visible_message(
			SPAN_WARNING("You probably need crowbar or wrench to do something with this old crap! Or, better, get someone more professional.")
		)

/obj/structure/abandoned_cryo/attack_hand(mob/user)
	user.visible_message(
		SPAN_WARNING("You can't open this thing with bare hands!")
	)

#define HEX_COLOR_TO_RGB_ARGS(X) arglist(GetHexColors(X))
/obj/structure/abandoned_cryo/proc/randomize_appearance(mob/living/carbon/human/M, species_choice)
	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_GENDER))
		if(species_choice in genders_per_species)
			M.change_gender(pick(genders_per_species[species_choice]))
		else
			M.randomize_gender()

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_SKIN_TONE))
		if(species_choice in skin_tones_per_species)
			M.change_skin_tone(pick(skin_tones_per_species[species_choice]))
		else
			M.randomize_skin_tone()

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_SKIN_COLOR))
		if(species_choice in skin_colors_per_species)
			M.change_skin_color(HEX_COLOR_TO_RGB_ARGS(pick(skin_colors_per_species[species_choice])))
		else
			M.skin_tone = random_skin_tone(M.species)

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_HAIR_COLOR))
		if(species_choice in hair_colors_per_species)
			M.change_hair_color(HEX_COLOR_TO_RGB_ARGS(pick(hair_colors_per_species[species_choice])))
		else
			M.randomize_hair_color()
		var/list/rgb = rgb2num(M.head_hair_color)
		M.change_facial_hair_color(rgb[1], rgb[2], rgb[3])

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_HAIR_STYLE))
		if(species_choice in hair_styles_per_species)
			M.change_hair(pick(hair_styles_per_species[species_choice]))
		else
			M.randomize_hair_style()

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_FACIAL_STYLE))
		if(species_choice in facial_styles_per_species)
			M.change_facial_hair(pick(facial_styles_per_species[species_choice]))
		else
			M.randomize_facial_hair_style()

	if((spawn_flags & SURVIVOR_SPAWNER_RANDOM_EYE_COLOR))
		if(species_choice in eye_colors_per_species)
			M.change_eye_color(HEX_COLOR_TO_RGB_ARGS(pick(eye_colors_per_species[species_choice])))
		else
			M.randomize_eye_color()

	var/singleton/cultural_info/culture = M.get_cultural_value(TAG_CULTURE)
	if(culture && SURVIVOR_SPAWNER_RANDOM_NAME & spawn_flags)
		M.SetName(culture.get_random_name(M.gender))
	else
		M.SetName(name)
	M.real_name = M.name

#undef HEX_COLOR_TO_RGB_ARGS

/obj/structure/abandoned_cryo/proc/equip_outfit(mob/living/carbon/human/M)
	var/adjustments = 0
	adjustments = (spawn_flags & SURVIVOR_SPAWNER_CUT_SURVIVAL)  ? (adjustments|OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR) : adjustments
	adjustments = (spawn_flags & SURVIVOR_SPAWNER_CUT_ID_PDA)    ? (adjustments|OUTFIT_ADJUSTMENT_SKIP_ID_PDA)        : adjustments
	adjustments = (spawn_flags & SURVIVOR_SPAWNER_PLAIN_HEADSET) ? (adjustments|OUTFIT_ADJUSTMENT_PLAIN_HEADSET)      : adjustments

	var/singleton/hierarchy/outfit/survivor_outfit = outfit_by_type(pickweight(survivor_outfits))
	survivor_outfit.equip(M, equip_adjustments = adjustments)

#undef SURVIVOR_SPAWNER_RANDOM_NAME
#undef SURVIVOR_SPAWNER_CUT_SURVIVAL
#undef SURVIVOR_SPAWNER_CUT_ID_PDA
#undef SURVIVOR_SPAWNER_PLAIN_HEADSET

#undef SURVIVOR_SPAWNER_RANDOM_SKIN_TONE
#undef SURVIVOR_SPAWNER_RANDOM_SKIN_COLOR
#undef SURVIVOR_SPAWNER_RANDOM_HAIR_COLOR
#undef SURVIVOR_SPAWNER_RANDOM_HAIR_STYLE
#undef SURVIVOR_SPAWNER_RANDOM_FACIAL_STYLE
#undef SURVIVOR_SPAWNER_RANDOM_EYE_COLOR
#undef SURVIVOR_SPAWNER_RANDOM_GENDER

#undef SURVIVOR_SPAWNER_NO_RANDOMIZATION
