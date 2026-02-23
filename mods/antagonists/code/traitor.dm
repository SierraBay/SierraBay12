//
//        TRAITOR OPTIONAL OBJECTIVES
//
/datum/objective/traitor
	var/static/possible_items[] = list(
		"captain's final argument", // antique laser gun is long gone
		"bluespace rift generator",
		"RCD",
		"jetpack",
		"captain's jumpsuit",
		"functional AI",
		"pair of magboots",
		"[station_name()] blueprints",
		"28 moles of phoron (full tank)",
		"sample of slime extract",
		"piece of corgi meat",
		"chief science officer's jumpsuit",
		"chief engineer's jumpsuit",
		"chief medical officer's jumpsuit",
		"head of security's jumpsuit",
		"head of personnel's jumpsuit",
		"hypospray",
		"captain's pinpointer",
		"ablative armor vest",
		"\improper NT breacher chassis control module",
		"captain's HCM",
		"HoP's HCM",
		"CMO's HCM",
		"HoS' HCM",
		"research command HCM",
		"heavy exploration HCM",
		"hazard hardsuit control module",
		"nuclear instructions envelope",
		"DELTA protocol envelope",
		"ALPHA Protocol envelope",
		"UMBRA Protocol envelope",
		"RE: Regarding testing supplies envelope",
	)

// list for loadout items with custom names
GLOBAL_LIST_EMPTY(custom_items)

/datum/gear_tweak/custom_name/tweak_item(user, obj/item/I, metadata)
	. = ..()
	if (metadata)
		var/new_entry = list(
			"item_name" = metadata,
			"owner" = user
		)
		GLOB.custom_items += list(new_entry)


/datum/objective/traitor/find_target()
	var/objective
	switch (rand(1, 4))
		if (1, 2) // human
			..()
			if(target && target.current)
				objective = "[target.current.real_name], the [target.assigned_role]."
			else
				objective = get_random_objective_item()
		if (3) // static item
			objective = get_random_objective_item()
		if (4) // custom item or static item if not found
			objective = get_random_custom_item() || get_random_objective_item()
	explanation_text = "My goal involves [objective]"
	return objective


/datum/objective/traitor/proc/get_random_custom_item()
	if(!LAZYLEN(GLOB.custom_items))
		return

	var/list/entry = pick(GLOB.custom_items)

	var/item_name = entry["item_name"]
	var/mob/item_owner = entry["owner"]
	if ("[item_owner]" == "[owner.current]")
		return
	return "[item_name] owned by [item_owner]"

/datum/objective/traitor/proc/get_random_objective_item()
	return pick(possible_items)

/datum/antagonist/traitor/create_objectives(datum/mind/traitor)
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = traitor
	traitor.objectives += survive_objective


/mob/living/proc/get_objectives()
	set name = "Get Objectives"
	set category = "IC"
	set src = usr

	if(!mind)
		return
	if(locate(/datum/objective/traitor) in mind.objectives)
		to_chat(mind.current, "You already have your objectives for today.")
		return

	for(var/i = 1 to 3)
		var/datum/objective/traitor/objective = new
		objective.owner = mind

		var/attempts_left = 10 // preventing infinite loop

		while(attempts_left-- > 0)
			objective.find_target()
			if(!mind.has_similar_objective(objective))
				mind.objectives += objective
				break

		if(attempts_left <= 0)
			log_and_message_admins(SPAN_WARNING("Objective generation failed! Last attempt: [objective.explanation_text]"), mind.current)
			qdel(objective)

	var/obj_count = 1
	to_chat(mind.current, SPAN_NOTICE("Your current objectives:"))
	for(var/datum/objective/objective in mind.objectives)
		to_chat(mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++


/datum/mind/proc/has_similar_objective(datum/objective/traitor/new_obj)
	for(var/datum/objective/traitor/existing in objectives)
		if(existing.explanation_text == new_obj.explanation_text)
			return TRUE
	return FALSE


/datum/antagonist/traitor/add_antagonist_mind(datum/mind/player, ignore_role, nonstandard_role_type, nonstandard_role_msg, bypass = FALSE)
	if (..())
		player.current.verbs += /mob/living/proc/get_objectives
		// there is 1 second spawn in parent proc and this text should be displayed right after it
		addtimer(new Callback(src, .proc/give_objectives_hint, player), 1.1 SECOND)
		return 1
	else
		return 0

/datum/antagonist/proc/give_objectives_hint(datum/mind/player)
	to_chat(player.current, SPAN_NOTICE("Unsure what goal to pursue? You can acquire several objectives with the \
			<b>Get Objectives</b> verb, located in the IC tab. These objectives are optional and don't give you \
			the right to go on a murder spree, you still need to think of an ambition to perform the suggested goals."))

//
//        DOOR CHARGE
//
/datum/antagonist/traitor
	initial_spawn_target = 3


/obj/item/door_charge
	name = "door charge"
	desc = "This is a booby trap, planted inside opened airlock mechanism. Next time door opens, it will explode!."
	gender = PLURAL
	icon = 'mods/antagonists/icons/obj/door_charge.dmi'
	icon_state = "door_charge"
	item_state = "door_charge"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_ESOTERIC = 4)
	var/ready = 0

/obj/item/door_charge/use_after(atom/movable/target, mob/user)
	if (ismob(target) || !istype(target, /obj/machinery/door/airlock))
		return FALSE

	to_chat(user, "Planting explosives...")
	user.do_attack_animation(target)

	if(do_after(user, 50, target) && in_range(user, target))
		if(!user.unequip_item())
			return TRUE

		forceMove(target)

		log_and_message_admins("planted \a [src] on \the [target].")

		to_chat(user, "Bomb has been planted.")

		GLOB.density_set_event.register(target, src, PROC_REF(explode))

	return TRUE


/obj/item/door_charge/proc/explode(obj/machinery/door/airlock/airlock)
	if(!airlock.density)
		explosion(get_turf(airlock), 3, EX_ACT_HEAVY)
		airlock.ex_act(1)
		qdel(src)

//
//        BLUESPACE JAUNTER
//

/obj/item/device/syndietele
	name = "strange sensor"
	desc = "Looks like regular powernet sensor, but this one almost black and have spooky red light blinking"
	icon = 'mods/antagonists/icons/obj/syndiejaunter.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = list(TECH_BLUESPACE = 4, TECH_ESOTERIC = 3)

	w_class = ITEM_SIZE_SMALL

/obj/item/device/syndiejaunter
	name = "strange device"
	desc = "This thing looks like remote. Almost black, with red button and status display."
	icon = 'mods/antagonists/icons/obj/syndiejaunter.dmi'
	icon_state = "jaunter"
	item_state = "jaunter"
	w_class = ITEM_SIZE_SMALL
	var/obj/item/device/syndietele/beacon
	var/usable = 1
	var/image/cached_usable

/obj/item/device/syndiejaunter/examine(mob/user, distance)
	. = ..()
	to_chat(user, SPAN_NOTICE("Display is [usable ? "online and shows number [usable]" : "offline"]."))
/obj/item/device/syndiejaunter/Initialize()
	. = ..()
	update_icon()

/obj/item/device/syndiejaunter/on_update_icon()
	. = ..()
	if(usable)
		AddOverlays(image(icon, "usable"))
	else
		ClearOverlays()

/obj/item/device/syndiejaunter/attack_self(mob/user)
	if(!istype(beacon) || !usable)
		return 0

	animated_teleportation(user, beacon)
	usable = max(usable - 1, 0)
	update_icon()

/obj/item/device/syndiejaunter/use_after(atom/target, mob/user)
	if(istype(target,/obj/item/device/syndietele))
		beacon = target
		to_chat(user, "You succesfully linked [src] to [target]!")
	else
		to_chat(user, "You can't link [src] to [target]!")
	update_icon()

/obj/item/storage/box/syndie_kit/jaunter
	startswith = list(/obj/item/device/syndietele,
					  /obj/item/device/syndiejaunter)

//
//        HOLOBOMBS
//

/obj/item/device/holobomb
	name = "holobomb"
	desc = "A small explosive charge with a holoprojector designed to disable the curious guards."
	icon = 'mods/antagonists/icons/obj/holobomb.dmi'
	icon_state = "minibomb"
	item_state = "nothing"
	slot_flags = SLOT_EARS
	w_class = ITEM_SIZE_SMALL
	var/active = FALSE
	var/mode = 0

/obj/item/device/holobomb/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(!target)
		return
	if(target.w_class <= w_class)
		name = target.name
		desc = target.desc
		icon = target.icon
		color = target.color
		icon_state = target.icon_state
		active = TRUE
		to_chat(user, "\The [src] is now active.")
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
		update_icon()
	else
		to_chat(user, "\The [target] is too big for \the [src] hologramm")

/obj/item/device/holobomb/attack_self(mob/user)
	trigger(user)

/obj/item/device/holobomb/emp_act()
	..()
	trigger()

/obj/item/device/holobomb/attack_hand(mob/user)
	. = ..()
	if(!mode)
		trigger(user)

/obj/item/device/holobomb/proc/switch_mode(mob/user)
	mode = !mode
	if(mode)
		to_chat(user, "Mode 1.Now \the [src] will explode upon activation.")
	else
		to_chat(user, "Mode 2. Now \the [src] will explode as soon as they pick it up or upon activation.")

/obj/item/device/holobomb/proc/trigger(mob/user)
	if(!active)
		switch_mode(user)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!user)
		return
	var/obj/item/organ/external/O = H.get_organ(pick(BP_L_HAND, BP_R_HAND))
	if(!O)
		return

	var/dam = rand(35, 45)
	H.visible_message("<span class='danger'>\The [src] in \the [H]'s hand explodes with a loud bang!</span>")
	H.apply_damage(dam, DAMAGE_BRUTE, O, damage_flags = DAMAGE_FLAG_SHARP, used_weapon = "explode")
	explosion(src.loc, 0,0,1,1)
	H.Stun(5)
	qdel(src)

/obj/item/paper/holobomb
	name = "instruction"
	info = "Бомба имеет два режима. В первом она взрывается при попытке \"ипользовать\" её, во втором при прикосновении. Для начала работы с бомбой выберете режим и просканируйте нужный вам небольшой предмет. Всё, бомба взведена, удачи! И помните, после активации режим бомбы лучше не менять."

/obj/item/storage/box/syndie_kit/holobombs
	name = "box of holobombs"
	desc = "A box containing 5 experimental holobombs."
	icon_state = "flashbang"
	startswith = list(/obj/item/device/holobomb = 5, /obj/item/paper/holobomb = 1)

//
//        Poison
//

/obj/item/storage/box/syndie_kit/bioterror
	startswith = list(
		/obj/item/reagent_containers/glass/beaker/vial/random/toxin/bioterror = 7
	)

/obj/item/reagent_containers/glass/beaker/vial/random/toxin/bioterror
	random_reagent_list = list(
		list(/datum/reagent/drugs/mindbreaker = 10, /datum/reagent/drugs/hextro = 20) = 2,
		list(/datum/reagent/toxin/carpotoxin = 30)                                    = 2,
		list(/datum/reagent/impedrezene = 30)                                         = 2,
		list(/datum/reagent/mutagen = 30)                                             = 2,
		list(/datum/reagent/toxin/amatoxin = 30)                                      = 2,
		list(/datum/reagent/drugs/cryptobiolin = 30)                                  = 2,
		list(/datum/reagent/impedrezene = 30)                                         = 2,
		list(/datum/reagent/toxin/potassium_chlorophoride = 30)                       = 2,
		list(/datum/reagent/acid/polyacid = 30)                                       = 2,
		list(/datum/reagent/radium = 30)                                              = 2,
		list(/datum/reagent/toxin/zombiepowder = 30)                                  = 1)

// Key

/obj/item/device/encryptionkey/syndie_full
	icon_state = "cypherkey"
	channels = list("Mercenary" = 1, "Command" = 1, "Security" = 1, "Engineering" = 1, "Exploration" = 1, "Science" = 1, "Medical" = 1, "Supply" = 1, "Service" = 1)
	origin_tech = list(TECH_ESOTERIC = 3)
	syndie = 1

// Stimm

/obj/item/reagent_containers/hypospray/autoinjector/stimpack
	name = "stimpack"
	band_color = COLOR_PINK //inf //was: COLOR_DARK_GRAY
	starts_with = list(/datum/reagent/nitritozadole = 5)

/datum/reagent/nitritozadole
	name = "Nitritozadole"
	description = "Nitritozadole is a very dangerous mix, which can increase your speed temporarly."
	taste_description = "metal"
	reagent_state = LIQUID
	color = "#ff2681"
	metabolism = REM * 0.20
	overdose = REAGENTS_OVERDOSE / 3
	value = 4.5

/datum/reagent/nitritozadole/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == SPECIES_DIONA)
		return

	if(prob(2))
		to_chat(M, SPAN_DANGER("My heart gonna break out from the chest!"))
		M.stun_effect_act(0, 15, BP_CHEST, "heart damage") //a small pain without damage
		if(prob(15))
			for(var/obj/item/organ/internal/heart/H in M.internal_organs)
				H.damage += 1

	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))
	M.add_chemical_effect(CE_SPEEDBOOST, 1.5)
	M.add_chemical_effect(CE_PULSE, 3)


// Radlaser

/obj/item/device/scanner/health/syndie
	name = "health analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	item_flags = ITEM_FLAG_NO_BLUDGEON
	matter = list(MATERIAL_ALUMINIUM = 200)
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 2, TECH_ESOTERIC = 2)

/obj/item/device/scanner/health/syndie/scan(mob/living/carbon/human/A, mob/user)
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	if(!istype(A))
		return

	A.apply_damage(30, DAMAGE_RADIATION, damage_flags = DAMAGE_FLAG_DISPERSED)

/obj/item/device/scanner/health/syndie/examine(mob/user)
	. = ..()
	if (isobserver(user) || (user.mind && user.mind.special_role != null) || user.skill_check(SKILL_DEVICES, SKILL_MASTER) || user.skill_check(SKILL_MEDICAL, SKILL_MASTER))
		to_chat(user, "The scanner contacts do not look as they should. ")
		return

// Bugs

/obj/item/device/spy_bug
	on_turf_icon = 'mods/antagonists/icons/obj/bug_on_turf.dmi'
