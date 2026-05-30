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

// START VOX SHOTGUN
/obj/item/gun/energy/voxshot
	name = "gunk spewer"
	desc = "Somewhat massive type of object, that smells burned flesh and teeth dust. Parts of it twitch and writhe, as if alive."
	icon = 'mods/utility_items/icons/vox.dmi'
	icon_state = "voxshot"
	item_icons = list(
		slot_l_hand_str = 'mods/utility_items/icons/lefthand.dmi',
		slot_r_hand_str = 'mods/utility_items/icons/righthand.dmi'
	)
	item_state = "voxshot"

	fire_sound_text = "spew"

	w_class = ITEM_SIZE_LARGE
	one_hand_penalty = 6 // shotgun
	bulk = 4 // shotgun
	force = 10

	projectile_type = /obj/item/projectile/oilyvomit
	self_recharge = 1
	firemodes = list(
		list(
			"mode_name" = "oily vomit",
			"fire_sound" = 'mods/utility_items/sounds/voxshotvomit.ogg',
			"fire_delay" = 10,
			"max_shots" = 5,
			"burst" = 1,
			"move_delay" = null,
			"burst_accuracy" = list(30),
			"dispersion" = null,
			"projectile_type" = /obj/item/projectile/oilyvomit,
			"charge_cost" = 50
		),
		list(
			"mode_name" = "clump of teeth",
			"fire_sound" = 'sound/weapons/rapidslice.ogg',
			"fire_delay" = 20,
			"burst" = 5,
			"max_shots" = 25,
			"burst_delay" = 0,
			"move_delay" = 4,
			"burst_accuracy" = list(0, 0, 0, 0, 0),
			"dispersion" = list(0, 0, 0, 1, 2),
			"projectile_type" = /obj/item/projectile/bullet/teeth,
			"charge_cost" = 10,
		)
	)

/obj/item/gun/energy/voxshot/Initialize()
	. = ..()
	set_extension(src, /datum/extension/voxform)

/obj/item/gun/energy/voxshot/check_accidents()
	if(prob(20))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /obj/decal/cleanable/vomit(loc)
		visible_message("[src] throws up!")
	return

/obj/item/gun/energy/voxshot/on_update_icon()
	..()
	var/ratio = power_supply.percent()
	if(power_supply.charge < charge_cost)
		ratio = 0
	else
		ratio = clamp(round(ratio, 20), 20, 100)
	icon_state = "[initial(icon_state)][ratio]"

/obj/item/projectile/bullet/teeth
	name = "tooth"
	is_pellet = TRUE
	embed = TRUE
	damage = 15
	agony = 20
	muzzle_type = null

	icon_state = "flechette"


/obj/item/projectile/bullet/teeth/Initialize()
	. = ..()
	pixel_y = rand(-16, 16)
	pixel_x = rand(-16, 16)

/obj/item/projectile/bullet/attack_mob(mob/living/target_mob, distance, miss_modifier)
	def_zone = ran_zone(def_zone, 0)
	. = ..()

/obj/item/projectile/oilyvomit
	name = "oily puke"
	nodamage = TRUE
	life_span = 5
	icon = 'icons/obj/weapons/other.dmi'
	icon_state = "slugegg"
	color = "#b64c51"

/obj/item/projectile/oilyvomit/on_hit(mob/living/L)
	L.adjust_fire_stacks(25)
	L.IgniteMob()
	playsound(L, 'sound/effects/meatsizzle.ogg', 50, 1)
	. = ..()

/obj/item/projectile/oilyvomit/on_impact(atom/A)
	var/obj/decal/cleanable/liquid_fuel/puke = new(get_turf(A))
	puke.name = "oily vomit"
	puke.icon = 'icons/effects/blood.dmi'
	puke.icon_state = "mfloor[rand(1,7)]"
	puke.color = "#553408"
	. = ..()

// END VOX SHOTGUN
