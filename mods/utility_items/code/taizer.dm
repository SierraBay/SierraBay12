/obj/item/projectile/bullet/electrode
	name = "electrode"
	icon = 'mods/utility_items/icons/projectiles_by_teteshnik.dmi'
	damage_type = DAMAGE_BRUTE
	damage_flags = DAMAGE_FLAG_SHARP
	damage = 1
	armor_penetration = 0
	sharp = TRUE
	agony = 20

/obj/item/projectile/bullet/electrode/on_hit(atom/target, blocked)
	. = ..()
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(H.should_have_organ(BP_EYES))
			var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]
			if(eyes && BP_IS_ROBOTIC(eyes))
				H.eye_blind = max(H.eye_blind, 5)

/obj/item/projectile/bullet/electrode/low
	agony = 20

/obj/item/projectile/bullet/electrode/medium
	agony = 40

/obj/item/projectile/bullet/electrode/high
	agony = 60

/obj/item/ammo_casing/battery
	name = "low battery electrode"
	desc = "A taser electrode."
	icon = 'mods/utility_items/icons/electrode_by_teteshnik.dmi'
	icon_state = "electrode"
	spent_icon = "electrode-spent"
	caliber = CALIBER_PISTOL_FAST
	projectile_type = /obj/item/projectile/bullet/electrode/low
	matter = list(MATERIAL_STEEL = 160)

/obj/item/ammo_casing/battery/medium
	name = "medium battery electrode"
	projectile_type = /obj/item/projectile/bullet/electrode/medium

/obj/item/ammo_casing/battery/high
	name = "high battery electrode"
	projectile_type = /obj/item/projectile/bullet/electrode/high

/obj/item/gun/projectile/taser
	name = "taser"
	desc = "The NT Mk20 NL is a small, taser used for non-lethal takedowns. Produced by NT, it's actually a licensed version of a W-T design. It can switch between high and low intensity stun shots."
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING
	caliber = CALIBER_PISTOL_FAST
	icon = 'mods/utility_items/icons/taser_by_teteshnik.dmi'
	icon_state = "taser"
	item_state = "taser"
	item_icons = list(
		slot_r_hand_str = 'mods/utility_items/icons/righthand_taser_teteshnik.dmi',
		slot_l_hand_str = 'mods/utility_items/icons/lefthand_taser_teteshnik.dmi',
	)
	ammo_type = /obj/item/ammo_casing/battery
	max_shells = 1
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	auto_eject = 0
	w_class = ITEM_SIZE_NORMAL
	fire_sound = 'mods/utility_items/sound/taser.ogg'

/obj/item/gun/projectile/taser/on_update_icon()
	..()
	if(length(loaded))
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-empty"

/obj/machinery/vending/security
	products = list(
		/obj/item/handcuffs = 8,
		/obj/item/grenade/flashbang = 4,
		/obj/item/grenade/chem_grenade/teargas = 4,
		/obj/item/device/flash = 5,
		/obj/item/reagent_containers/food/snacks/donut/normal = 12,
		/obj/item/storage/box/evidence = 6,
		/obj/item/ammo_casing/battery/high = 8,
		/obj/item/ammo_casing/battery/medium = 8,
		/obj/item/ammo_casing/battery = 8
	)

/obj/item/storage/belt/security
	contents_allowed = list(
		/obj/item/crowbar,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/handcuffs,
		/obj/item/device/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_magazine,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/melee/baton,
		/obj/item/melee/telebaton,
		/obj/item/flame/lighter,
		/obj/item/device/flashlight,
		/obj/item/modular_computer/tablet,
		/obj/item/modular_computer/pda,
		/obj/item/device/radio/headset,
		/obj/item/device/hailer,
		/obj/item/device/megaphone,
		/obj/item/melee,
		/obj/item/taperoll,
		/obj/item/device/holowarrant,
		/obj/item/magnetic_ammo,
		/obj/item/device/binoculars,
		/obj/item/clothing/gloves,
		/obj/item/clothing/head/beret,
		/obj/item/material/knife,
		/obj/item/ammo_casing/battery
	)

/obj/item/storage/belt/holster/security
	contents_allowed = list(
		/obj/item/crowbar,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/handcuffs,
		/obj/item/device/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_magazine,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/melee/baton,
		/obj/item/melee/telebaton,
		/obj/item/flame/lighter,
		/obj/item/device/flashlight,
		/obj/item/modular_computer/tablet,
		/obj/item/modular_computer/pda,
		/obj/item/device/radio,
		/obj/item/device/hailer,
		/obj/item/device/megaphone,
		/obj/item/melee,
		/obj/item/taperoll,
		/obj/item/device/holowarrant,
		/obj/item/magnetic_ammo,
		/obj/item/device/binoculars,
		/obj/item/clothing/gloves,
		/obj/item/clothing/head/beret,
		/obj/item/material/knife,
		/obj/item/ammo_casing/battery
		)
