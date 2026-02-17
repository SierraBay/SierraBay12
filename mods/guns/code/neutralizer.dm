// By Teteshnik

/obj/item/projectile/bullet/electrode
	name = "electrode"
	icon = 'mods/guns/icons/obj/projectiles.dmi'
	damage_type = DAMAGE_BRUTE
	damage_flags = DAMAGE_FLAG_SHARP
	damage = 1
	armor_penetration = 0
	sharp = TRUE
	agony = 40

/obj/item/projectile/bullet/electrode/on_hit(atom/target, blocked, def_zone = null)
	. = ..()
	if(blocked < 100 && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(H.should_have_organ(BP_EYES))
			var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]
			if(eyes && BP_IS_ROBOTIC(eyes))
				H.eye_blind = max(H.eye_blind, src.agony / 10)
	else if(isrobot(target))
		var/mob/living/silicon/robot/R = target
		if (R.status_flags & CANWEAKEN)
			R.Weaken(src.agony / 5)

/obj/item/projectile/bullet/electrode/high
	agony = 60

/obj/item/ammo_casing/battery
	name = "low-power NT Mk20 electrode"
	desc = "A NT Mk20 neutralizer one-use electrode. This one emits low-power electric pulse on hit and short-time effect on synthetic targets."
	icon = 'mods/guns/icons/obj/ammo.dmi'
	icon_state = "electrode"
	spent_icon = "electrode-spent"
	caliber = "electrode"
	projectile_type = /obj/item/projectile/bullet/electrode
	matter = list(MATERIAL_STEEL = 160)

/obj/item/ammo_casing/battery/examine(mob/user)
	. = ..()
	if(caliber)
		to_chat(user, "It is an [caliber] for .")
	if (!BB)
		to_chat(user, "This one is spent.")

/obj/item/ammo_casing/battery/high
	name = "high-power NT Mk20 electrode"
	desc = "A NT Mk20 neutralizer one-use electrode. This one emits high-power electric pulse on hit and prolonged effect on synthetic targets."
	icon_state = "electrode_h"
	spent_icon = "electrode_h-spent"
	projectile_type = /obj/item/projectile/bullet/electrode/high

/obj/item/gun/projectile/taser
	name = "NT Mk20 neutralizer"
	desc = "The NT Mk20 NL is a compact non-lethal neutralizer that combines the functionality of a classic contact taser and an electronic scrambler. It is used for the non-lethal detention of organic and cybernetic subjects."
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING
	caliber = "electrode"
	icon = 'mods/guns/icons/obj/neutralizer.dmi'
	icon_state = "taser"
	item_state = "taser"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_neutralizer.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_neutralizer.dmi',
	)
	ammo_type = /obj/item/ammo_casing/battery
	max_shells = 1
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	auto_eject = 0
	w_class = ITEM_SIZE_NORMAL
	fire_sound = 'mods/guns/sounds/taser.ogg'

/obj/item/gun/projectile/taser/on_update_icon()
	..()
	if(length(loaded))
		var/obj/item/ammo_casing/AC = loaded[1]
		if(AC.BB)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)]-spent"
	else
		icon_state = "[initial(icon_state)]-empty"

/datum/design/item/weapon/neutralizer
	id = "neutralizer"
	req_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_POWER = 2)
	materials = list(MATERIAL_STEEL = 5000)
	build_path = /obj/item/gun/projectile/taser
	sort_string = "TADAN"

/obj/machinery/vending/security
	products = list(
		/obj/item/handcuffs = 8,
		/obj/item/grenade/flashbang = 4,
		/obj/item/grenade/chem_grenade/teargas = 4,
		/obj/item/device/flash = 5,
		/obj/item/reagent_containers/food/snacks/donut/normal = 12,
		/obj/item/storage/box/evidence = 6,
		/obj/item/clothing/accessory/badge/holo/NT = 4,
		/obj/item/clothing/accessory/badge/holo/NT/cord = 4,
		/obj/item/ammo_casing/battery/high = 12,
		/obj/item/ammo_casing/battery = 12
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
