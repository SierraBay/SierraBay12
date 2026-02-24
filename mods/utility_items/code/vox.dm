// Vox-related mini-tweaks
/datum/trader/ship/vox
	trade_flags = TRADER_GOODS | TRADER_WANTED_ONLY | TRADER_WANTED_ALL

/singleton/species/vox
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION

// START STEALTH SUIT
/obj/item/clothing/head/helmet/space/vox/stealth
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SMALL,
		rad = ARMOR_RAD_SMALL
		)

/obj/item/clothing/suit/space/vox/stealth
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SMALL,
		rad = ARMOR_RAD_SMALL
		)
	action_button_name = "Toggle Cloak"
	var/cloak = FALSE
	var/cloak_charge = 120
	var/cloak_charge_max = 120

/obj/item/clothing/suit/space/vox/stealth/attack_self(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/stealth) || !istype(H.wear_suit, /obj/item/clothing/suit/space/vox/stealth))
		return
	if(!cloak)
		if(!do_after(H, 5 SECONDS, do_flags = DO_PUBLIC_UNIQUE | DO_USER_CAN_MOVE))
			return
	cloak(H)

/obj/item/clothing/suit/space/vox/stealth/proc/cloak(mob/living/carbon/human/H)
	if(cloak)
		cloak = FALSE
		return 1
	if(cloak_charge <= 60)
		to_chat(H, SPAN_BOLD(SPAN_CLASS("vox", "Cloak is out of charge!")))
		return
	to_chat(H, SPAN_BOLD(SPAN_CLASS("vox", "Stealth mode enabled. Charge: [cloak_charge] seconds")))
	cloak = TRUE
	animate(H, alpha = 255, alpha = 1, time = 10)

	var/currentbrute = 0
	var/currentburn = 0
	var/datum/effect/spark_spread/spark_system = new /datum/effect/spark_spread
	var/remain_cloaked = TRUE
	while(remain_cloaked && cloak_charge > 0)
		currentbrute = H.getBruteLoss()
		currentburn = H.getFireLoss()
		sleep(1 SECOND)
		cloak_charge--
		if(cloak_charge == 60)
			to_chat(H, SPAN_CLASS("vox", "60 seconds untill reveal!"))
		if(cloak_charge == 20)
			to_chat(H, SPAN_BOLD(SPAN_CLASS("vox", "20 seconds untill reveal!")))
		if(!cloak)
			remain_cloaked = FALSE
		if(!istype(H.head, /obj/item/clothing/head/helmet/space/vox/stealth))
			remain_cloaked = FALSE
		if(currentbrute < H.getBruteLoss() || currentburn < H.getFireLoss())
			spark_system.set_up(5, 0, src)
			spark_system.attach(src)
			spark_system.start()
			remain_cloaked = FALSE

	H.visible_message(SPAN_WARNING("[H] suddenly fades in, seemingly from nowhere!"))
	to_chat(H, SPAN_NOTICE("Stealth mode disabled."))
	cloak = FALSE
	animate(H, alpha = 1, alpha = 255, time = 10)

	while(!cloak && cloak_charge < cloak_charge_max)
		sleep(1 SECOND)
		cloak_charge += 2
// END STEALTH SUIT
