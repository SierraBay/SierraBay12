/obj/effect/effect/cig_smoke
	name = "smoke"
	icon_state = "smallsmoke"
	icon = 'mods/utility_items/icons/smoke.dmi'
	opacity = FALSE
	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_HUMAN_LAYER

	var/time_to_live = 3 SECONDS

/obj/effect/effect/cig_smoke/Initialize()
	. = ..()
	set_dir(pick(GLOB.cardinal))
	pixel_x = rand(0, 13)
	pixel_y = rand(0, 13)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/effect/cig_smoke/LateInitialize()
	animate(src, alpha = 0, time_to_live, easing = EASE_IN)
	QDEL_IN(src, time_to_live)

/obj/item/clothing/mask/smokable
	var/smoke_effect = 0
	var/smoke_amount = 1

// Proc override section

/obj/item/clothing/mask/smokable/smoke(amount, manual)
	smoketime -= amount
	if(reagents && reagents.total_volume) // check if it has any reagents at all
		var/smoke_loc = loc
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			smoke_loc = C.loc
			if ((src == C.wear_mask || manual) && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
				reagents.trans_to_mob(C, smoke_amount * amount, CHEM_INGEST, 0.2)
				add_trace_DNA(C)
		else // else just remove some of the reagents
			reagents.remove_any(smoke_amount * amount)

		smoke_effect++

		if(smoke_effect >= 4 || manual)
			smoke_effect = 0
			new /obj/effect/effect/cig_smoke(smoke_loc)

	var/turf/T = get_turf(src)
	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			if (src == C.wear_mask && C.internal)
				environment = C.internal.return_air()
		if(environment.get_by_flag(XGM_GAS_OXIDIZER) < gas_consumption)
			extinguish()
		else
			environment.remove_by_flag(XGM_GAS_OXIDIZER, gas_consumption)
			environment.adjust_gas(GAS_CO2, 0.5*gas_consumption,0)
			environment.adjust_gas(GAS_CO, 0.5*gas_consumption)

/obj/item/clothing/mask/smokable/light(flavor_text = "[usr] lights the [name].")
	if(QDELETED(src))
		return
	if(!lit)
		if(is_wet())
			to_chat(usr, SPAN_WARNING("You are too wet to light \the [src]."))
			return
		if(submerged())
			to_chat(usr, SPAN_WARNING("You cannot light \the [src] underwater."))
			return
		lit = 1
		damtype = DAMAGE_BURN
		if(reagents.get_reagent_amount(/datum/reagent/toxin/phoron)) // the phoron explodes when exposed to fire
			var/datum/effect/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/phoron) / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
			var/datum/effect/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		atom_flags &= ~ATOM_FLAG_NO_REACT // allowing reagents to react after being lit
		HANDLE_REACTIONS(reagents)
		update_icon()
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
			smoke_amount = reagents.total_volume / smoketime
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/cigarette/use_before(mob/living/carbon/human/H, mob/user)
	if (lit && H == user && istype(H))
		var/obj/item/blocked = H.check_mouth_coverage()
		if (blocked)
			to_chat(H, SPAN_WARNING("\The [blocked] is in the way!"))
			return TRUE
		playsound(H, "sound/effects/inhale.ogg", 50, 0, -1)
		user.visible_message(\
			"[user] takes a [pick("drag","puff","pull")] on \his [name].", \
			"You take a [pick("drag","puff","pull")] on your [name].")
		smoke(12, TRUE)
		add_trace_DNA(H)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return TRUE

	if(!lit && istype(H) && H.on_fire)
		user.do_attack_animation(H)
		light(H, user)
		return TRUE

	return ..()


// Tobacco section

/datum/reagent/bicaridine/tobacco
	taste_description = "speeding up time?"

/datum/reagent/tobacco/perception
	name = "Herbal drugs and tobacco"
	description = "Cut and process tobacco leaves along with herbal preparations."
	taste_description = "tobacco"
	scent = "cigarette smoke and herbal drug?"
	scent_range = 6

/datum/reagent/tobacco/perception/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	M.add_chemical_effect(CE_SLOWDOWN, 1)

/datum/reagent/tobacco/medical
	name = "Medical tobacco"
	description = "medicinal tobacco used for relaxation and concentration."
	taste_description = "relax, concetration and tobacco"
	scent = "relax and tobacco"
	scent_range = 2

/datum/reagent/tobacco/strong
	name = "Strong tobacco"
	description = "Strong tobacco for strong men... or women, i don't know"
	taste_description = "strong tobacco that hits the throat hard"
	scent = "Strong tobacco"
	scent_range = 10

/datum/reagent/tobacco/strong/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	M.reagents.add_reagent(/datum/reagent/nicotine, 10)

/datum/reagent/tobacco/female
	name = "female tobacco"
	description = "female tobacco for good lady's"
	taste_description = "weak tobacco that gently caresses the throat."
	scent = "weak tobacco"

/datum/reagent/tobacco/honey
	name = "tobacco with honey"
	description = "tobacco that has been processed in honey"
	taste_description = "the sweetness of honey and the strength of tobacco."
	scent = "sweet tobacco"

/datum/reagent/tobacco/coffee
	name = "tobacco with coffee"
	description = "tobacco leaves that have been mixed with coffee powder"
	taste_description = "sweet tobacco and energetic coffee."
	scent = "sweet tobacco and energy tobacco"
	scent_descriptor = SCENT_DESC_ODOR

// Flavoured tobacco

/obj/item/clothing/mask/chewable/tobacco/perception
	name = "perception tobacco"
	desc = "Cut and process tobacco leaves along with herbal preparations."

	filling = list(/datum/reagent/tobacco/perception = 1, /datum/reagent/bicaridine/tobacco = 1)

/obj/item/clothing/mask/chewable/tobacco/medical
	name = "medical tobacco"
	desc = "Medicinal tobacco used for relaxation and concentration."

	filling = list(/datum/reagent/tobacco/medical = 1, /datum/reagent/paroxetine = 0.7)

/obj/item/clothing/mask/chewable/tobacco/strong
	name = "strong tobacco"
	desc = "Strong tobacco for strong men... or women, perhaps."

	filling = list(/datum/reagent/tobacco/strong = 1)

/obj/item/clothing/mask/chewable/tobacco/female
	name = "female tobacco"
	desc = "Female tobacco for good lady's."

	filling = list(/datum/reagent/tobacco/female = 1)

/obj/item/clothing/mask/chewable/tobacco/honey
	name = "tobacco with honey"
	desc = "Tobacco that has been processed in honey."

	filling = list(/datum/reagent/tobacco/honey = 1)

/obj/item/clothing/mask/chewable/tobacco/coffee
	name = "tobacco with coffee"
	desc = "Tobacco leaves that have been mixed with coffee powder."

	filling = list(/datum/reagent/tobacco/coffee = 1)

// Ready for sale

/obj/item/storage/chewables/rollable/perception
	name = "bag of perception tobacco"
	desc = "Cut and process tobacco leaves along with herbal preparations."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/perception = 8)
	icon_state = "rollfine"

/obj/item/storage/chewables/rollable/medical
	name = "bag of medical tobacco"
	desc = "Medicinal tobacco used for relaxation and concentration."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/medical = 8)
	icon_state = "rollfine"

/obj/item/storage/chewables/rollable/strong
	name = "bag of strong tobacco"
	desc = "Strong tobacco for strong men... or women, perhaps."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/strong = 8)
	icon_state = "rollfine"

/obj/item/storage/chewables/rollable/female
	name = "bag of female tobacco"
	desc = "Female tobacco for good lady's."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/female = 8)
	icon_state = "rollfine"

/obj/item/storage/chewables/rollable/honey
	name = "bag of honey tobacco"
	desc = "Tobacco that has been processed in honey."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/honey = 8)
	icon_state = "rollfine"

/obj/item/storage/chewables/rollable/coffee
	name = "bag of coffee tobacco"
	desc = "Tobacco leaves that have been mixed with coffee powder."
	startswith = list(/obj/item/clothing/mask/chewable/tobacco/coffee = 8)
	icon_state = "rollfine"

// Income machine

/obj/machinery/vending/cigarette
	name = "\improper Cigarette Machine"
	desc = "A specialized vending machine designed to contribute to your slow and uncomfortable death."
	icon_state = "cigs"
	icon_vend = "cigs-vend"
	icon_deny = "cigs-deny"
	base_type = /obj/machinery/vending/cigarette
	product_slogans = {"\
		There's no better time to start smokin'.;\
		Smoke now, and win the adoration of your peers.;\
		They beat cancer centuries ago, so smoke away.;\
		If you're not smoking, you must be joking.\
	"}
	product_ads = {"\
		Probably not bad for you!;\
		Don't believe the scientists!;\
		It's good for you!;\
		Don't quit, buy more!;\
		Smoke!;\
		Nicotine heaven.;\
		Best cigarettes since 2150.;\
		Award-winning cigarettes, all the best brands.;\
		Feeling temperamental? Try a Temperamento!;\
		Carcinoma Angels - go fuck yerself!;\
		Don't be so hard on yourself, kid. Smoke a Lucky Star!;\
		We understand the depressed, alcoholic cowboy in you. That's why we also smoke Jericho.;\
		Professionals. Better cigarettes for better people. Yes, better people.\
	"}
	antag_slogans = {"\
		With your lungs full of smoke, you’ll share the experience of countless Gaian civilians!;\
		Smoke your troubles away. Is being a citizen of Sol worth all this trouble?;\
		We kill you, you buy! It's the SCG way!\
	"}
	prices = list(
		/obj/item/storage/chewables/tobacco = 40,
		/obj/item/storage/chewables/tobacco2 = 50,
		/obj/item/storage/chewables/tobacco3 = 60,
		/obj/item/storage/cigpaper/filters = 5,
		/obj/item/storage/cigpaper = 8,
		/obj/item/storage/cigpaper/fancy = 12,
		/obj/item/storage/chewables/rollable/bad = 20,
		/obj/item/storage/chewables/rollable/generic = 40,
		/obj/item/storage/chewables/rollable/fine = 60,
		/obj/item/storage/chewables/rollable/perception = 60,
		/obj/item/storage/chewables/rollable/medical = 75,
		/obj/item/storage/chewables/rollable/female = 60,
		/obj/item/storage/chewables/rollable/honey = 60,
		/obj/item/storage/chewables/rollable/coffee = 60,
		/obj/item/storage/chewables/rollable/rollingkit = 45,
		/obj/item/storage/fancy/smokable/transstellar = 45,
		/obj/item/storage/fancy/smokable/luckystars = 50,
		/obj/item/storage/fancy/smokable/jerichos = 65,
		/obj/item/storage/fancy/smokable/menthols = 55,
		/obj/item/storage/fancy/smokable/carcinomas = 65,
		/obj/item/storage/fancy/smokable/professionals = 70,
		/obj/item/storage/fancy/smokable/trident = 85,
		/obj/item/storage/fancy/smokable/trident_mint = 85,
		/obj/item/storage/fancy/smokable/trident_fruit = 85,
		/obj/item/storage/fancy/matches/matchbox = 5,
		/obj/item/storage/fancy/matches/matchbook = 2,
		/obj/item/flame/lighter/random = 5,
		/obj/item/clothing/mask/smokable/ecig/simple = 50,
		/obj/item/clothing/mask/smokable/ecig/util = 100,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 250,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/orange = 15,
		/obj/item/reagent_containers/ecig_cartridge/mint = 15,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 15,
		/obj/item/reagent_containers/ecig_cartridge/grape = 15,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 15,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 15,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 15
	)
	products = list(
		/obj/item/storage/cigpaper/filters = 5,
		/obj/item/storage/cigpaper = 3,
		/obj/item/storage/cigpaper/fancy = 2,
		/obj/item/storage/chewables/rollable/bad = 2,
		/obj/item/storage/chewables/rollable/generic = 2,
		/obj/item/storage/chewables/rollable/fine = 2,
		/obj/item/storage/chewables/rollable/perception = 2,
		/obj/item/storage/chewables/rollable/medical = 2,
		/obj/item/storage/chewables/rollable/female = 2,
		/obj/item/storage/chewables/rollable/honey = 2,
		/obj/item/storage/chewables/rollable/coffee = 2,
		/obj/item/storage/chewables/rollable/rollingkit = 2,
		/obj/item/storage/fancy/smokable/transstellar = 5,
		/obj/item/storage/fancy/smokable/luckystars = 2,
		/obj/item/storage/fancy/smokable/jerichos = 2,
		/obj/item/storage/fancy/smokable/menthols = 2,
		/obj/item/storage/fancy/smokable/carcinomas = 2,
		/obj/item/storage/fancy/smokable/professionals = 2,
		/obj/item/storage/fancy/smokable/trident = 2,
		/obj/item/storage/fancy/smokable/trident_mint = 2,
		/obj/item/storage/fancy/smokable/trident_fruit = 2,
		/obj/item/storage/fancy/matches/matchbox = 5,
		/obj/item/storage/fancy/matches/matchbook = 5,
		/obj/item/flame/lighter/random = 4,
		/obj/item/storage/chewables/tobacco = 2,
		/obj/item/storage/chewables/tobacco2 = 2,
		/obj/item/storage/chewables/tobacco3 = 2,
		/obj/item/clothing/mask/smokable/ecig/simple = 10,
		/obj/item/clothing/mask/smokable/ecig/util = 5,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 1,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 10,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 5,
		/obj/item/reagent_containers/ecig_cartridge/orange = 5,
		/obj/item/reagent_containers/ecig_cartridge/mint = 5,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 5,
		/obj/item/reagent_containers/ecig_cartridge/grape = 5,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 5,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 5,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 2
	)
	contraband = list(
		/obj/item/flame/lighter/zippo = 4,
		/obj/item/clothing/mask/smokable/cigarette/rolled/sausage = 3
	)
	premium = list(
		/obj/item/storage/fancy/smokable/cigar = 5,
		/obj/item/storage/fancy/smokable/killthroat = 5
	)
	rare_products = list(
		/obj/item/storage/box/syndie_kit/cigarette = 50,
		/obj/item/storage/box/syndie_kit/syringegun = 40,
		/obj/item/clothing/mask/chameleon/voice = 20
	)
	antag = list(
		/obj/item/grenade/smokebomb = 1,
		/obj/item/storage/box/syndie_kit/cigarette = 0,
		/obj/item/storage/box/syndie_kit/syringegun = 0,
		/obj/item/clothing/mask/chameleon/voice = 0
	)
