// Вооружение из различных модов, потому что что? Правильно, рантесты не проходят если у тебя оружие лежит в моде не глобале.
// Поэтому мы делаем глобал модпаком ЭТОТ мод.
// Гений ли я? Да нет, не очень, просто надоело.

///////////////////////////////
// ICCG Guns (Farfleet usage)//
///////////////////////////////

/* WEAPONARY - BALLISTICS
 * ========
 */

/obj/item/gun/projectile/automatic/assault_rifle/heltek
	name = "LA-700 assault rifle"
	desc = "HelTek LA-700 is a standart equipment of ICCG Space-assault Forces. Looks very similiar to STS-35."
	icon = 'mods/guns/icons/obj/iccg_rifle.dmi'
	icon_state = "iccg_rifle"
	item_state = "arifle"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_iccg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_iccg.dmi',
		)

/obj/item/gun/projectile/automatic/assault_rifle/heltek/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "iccg_rifle"
		wielded_item_state = "arifle-wielded"
	else
		icon_state = "iccg_rifle-empty"
		wielded_item_state = "arifle-wielded-empty"

/obj/item/gun/projectile/automatic/mr735
	name = "MR-735 assault rifle"
	desc = "A cheap rifle for close quarters combat, with an auto-firing mode available. HelTek MR-735 is a standard rifle for ICCG Space-assault Forces, designed without a stock for easier storage and combat in closed spaces. Perfect weapon for some ship's crew."
	icon = 'mods/guns/icons/obj/mr735.dmi'
	icon_state = "nostockrifle"
	item_state = "nostockrifle"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_iccg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_iccg.dmi',
		)
	wielded_item_state = "nostockrifle_wielded"
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list("mode_name" = "semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null, can_autofire=FALSE),
		list("mode_name" = "2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list("mode_name" = "full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), can_autofire=TRUE)
		)

/obj/item/gun/projectile/automatic/mr735/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "nostockrifle"
		wielded_item_state = "nostockrifle-wielded"
	else
		icon_state = "nostockrifle-empty"
		wielded_item_state = "nostockrifle-wielded-empty"


/obj/item/gun/projectile/automatic/mbr
	name = "MBR carabine"
	desc = "A shabby bullpup carbine. Despite its size, it looks a little uncomfortable, but it is robust. HelTek MBR is a standart equipment of ICCG Space-assault Forces, designed in a bullpup layout. Possesses autofire and is perfect for the ship's crew."
	icon = 'mods/guns/icons/obj/mbr_bullpup.dmi'
	icon_state = "mbr_bullpup"
	item_state = "mbr_bullpup"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_iccg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_iccg.dmi',
		)
	wielded_item_state = "mbr_bullpup-wielded"
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	bulk = GUN_BULK_RIFLE + 1
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'

	firemodes = list(
		list("mode_name" = "semi auto",      burst=1,    fire_delay=null, one_hand_penalty=8,  burst_accuracy=null,                dispersion=null, can_autofire=FALSE),
		list("mode_name" = "2-round bursts", burst=2,    fire_delay=null, one_hand_penalty=9,  burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list("mode_name" = "full auto",      burst=1,    fire_delay=1.7,    burst_delay=1.3,     one_hand_penalty=7,  burst_accuracy=list(0,-1,-1), dispersion=list(1.3, 1.5, 1.7, 1.9, 2.2), can_autofire=TRUE)
		)

/obj/item/gun/projectile/automatic/mbr/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "mbr_bullpup"
	else
		icon_state = "mbr_bullpup-empty"


/* WEAPONARY - ENERGY
 * ========
 */

/obj/item/gun/energy/laser/bonfire
	name = "Bonfire-75 carbine"
	desc = "Strange construction: laser carbine with underslung grenade launcher and very capable internal battery. HelTek Bonfire-75 is a weapon designed for suppressive fire in close quarters, where usage of ballistic weaponry will be uneffective or simply hazardous."
	icon = 'mods/guns/icons/obj/bonfire.dmi'
	icon_state = "bonfire"
	item_state = "bonfire"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_iccg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_iccg.dmi',
		)
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_LARGE
	force = 10
	one_hand_penalty = 2
	fire_delay = 6
	burst_delay = 2
	max_shots = 30
	bulk = GUN_BULK_RIFLE
	origin_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4)
	matter = list(MATERIAL_STEEL = 2000)
	projectile_type = /obj/item/projectile/beam/smalllaser
	wielded_item_state = "bonfire-wielded"

	firemodes = list(
		list("mode_name" = "semi auto",       burst=1, fire_delay=null, one_hand_penalty=0, burst_accuracy=null, dispersion=null),
		list("mode_name" = "3-ray bursts", burst=3, fire_delay=null, one_hand_penalty=1, burst_accuracy=list(0,0,-1,-1),       dispersion=list(0.0, 0.0, 0.5, 0.6)),
		list("mode_name" = "fire grenades",  burst=null, fire_delay=null,  use_launcher=1,    one_hand_penalty=10, burst_accuracy=null, dispersion=null)
		)

	var/use_launcher = 0
	var/obj/item/gun/launcher/grenade/underslung/launcher

/obj/item/gun/energy/laser/bonfire/Initialize()
	. = ..()
	launcher = new(src)

/obj/item/gun/energy/laser/bonfire/use_tool(obj/item/tool, mob/user, list/click_params)
	if(istype(tool, /obj/item/grenade))
		launcher.load(tool, user)
		return TRUE
	return ..()

/obj/item/gun/energy/laser/bonfire/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/energy/laser/bonfire/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	if(use_launcher)
		launcher.Fire(target, user, params, pointblank, reflex)
		if(!launcher.chambered)
			switch_firemodes() //switch back automatically
	else
		..()

/obj/item/gun/energy/laser/bonfire/toggle_safety(mob/user)
	..()
	if(launcher)
		launcher.safety_state = safety_state //Set the launcher's safety to be equivalent to the bullpup's.

/obj/item/gun/energy/ionrifle/small/stupor
	name = "Stupor ion pistol"
	desc = "The HelTek Stupor-45 is a compact anti-drone weapon. Due to their small output of EMP, you need be marksman to disable human-sized synthetic. But it's still better, than nothing."
	icon = 'mods/guns/icons/obj/stupor.dmi'
	icon_state = "stupor"
	item_state = "stupor"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_iccg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_iccg.dmi',
		)
	fire_delay = 40
	one_hand_penalty = 0
	charge_cost = 40
	max_shots = 5

// CSS Anti-psionics stuff

/obj/item/ammo_casing/pistol/nullglass
	desc = "A 10mm bullet casing with a nullglass coating."
	projectile_type = /obj/item/projectile/bullet/nullglass

/obj/item/ammo_casing/pistol/nullglass/disrupts_psionics()
	return src

/obj/item/ammo_magazine/pistol/nullglass
	ammo_type = /obj/item/ammo_casing/pistol/nullglass

/////////////////////////////////
// SCG Guns (Third Fleet usage)//
/////////////////////////////////

/* GUNS
 * ========
 */

/obj/item/gun/projectile/automatic/sol_smg
	name = "MSI-220 submachine gun"
	desc = "Mars Security Industries MSI-220 'Rapido'. Commonly used by Military Police, Sol Federal Police and other governmental paramilitary structures tied to MSI contracts."
	icon = 'mods/guns/icons/obj/smg_sol.dmi'
	icon_state = "solsmg"
	item_state = "solsmg"
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_sol.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_sol.dmi',
		)
	safety_icon = "safety"
	w_class = ITEM_SIZE_LARGE
	force = 10
	caliber = CALIBER_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 8)
	slot_flags = SLOT_BELT|SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/smg_sol
	allowed_magazines = /obj/item/ammo_magazine/smg_sol
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	bulk = -1
	accuracy = 1
	one_hand_penalty = 4

	barrel_thread = TRUE
	silencer_offset = 6

	//SMG
	firemodes = list(
		list("mode_name" = "semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=4, burst_accuracy=null, dispersion=null),
		list("mode_name" = "3-round bursts", burst=3, fire_delay=null, move_delay=4,    one_hand_penalty=5, burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list("mode_name" = "short bursts",   burst=5, fire_delay=null, move_delay=4,    one_hand_penalty=6, burst_accuracy=list(0,-1,-1,-1,-2), dispersion=list(0.6, 0.6, 1.0, 1.0, 1.2)),
		)

/obj/item/gun/projectile/automatic/sol_smg/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "solsmg-[round(length(ammo_magazine.stored_ammo),5)]"
	else
		icon_state = "solsmg"

/obj/item/gun/projectile/automatic/sol_smg/empty
	starts_loaded = FALSE

// Old Lathe
/datum/fabricator_recipe/arms_ammo/hidden/magazine_smg_sol
	name = "ammunition (SOLMAG submachine gun)"
	path = /obj/item/ammo_magazine/smg_sol

// Modded MODPACK_RND Lathe
/datum/design/autolathe/arms_ammo/hidden/magazine_smg_sol
	name = "ammunition (SOLMAG submachine gun)"
	build_path = /obj/item/ammo_magazine/smg_sol

/obj/item/ammo_magazine/smg_sol
	name = "SOLMAG magazine"
	icon = 'mods/guns/icons/obj/smg_sol.dmi'
	icon_state = "sol"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = CALIBER_PISTOL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/smg_sol/empty
	initial_ammo = 0

/obj/item/storage/box/ammo/smg_sol
	name = "box of SOLMAG SMG magazines"
	startswith = list(/obj/item/ammo_magazine/smg_sol = 6)

/////////////////////////////////
// Misc guns//
/////////////////////////////////

/* GUNS
 * ========
 */

//C-20A
/obj/item/gun/projectile/automatic/sec_smg/c20a
	name = "C-20A carabine"
	desc = "A licensed derivative of the infamous C-20r SMG, the C-20A is a lightweight carabine produced by NanoTrasen. Chambered in 7mm Usurpator rounds, the weapon trades bullet mass for muzzle velocity and superior ergonomics."
	icon_state = "c20a"
	item_state = "c20a"
	wielded_item_state = "c20a"
	icon = 'mods/guns/icons/obj/nt_smg.dmi'
	item_icons = list(
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_sec_smg.dmi',
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_sec_smg.dmi',
		)
	safety_icon = "safety"
	slot_flags = SLOT_BELT|SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/smg_nt
	allowed_magazines = /obj/item/ammo_magazine/smg_nt
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'

/obj/item/gun/projectile/automatic/sec_smg/c20a/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "c20a-[round(length(ammo_magazine.stored_ammo),4)]"
		item_state = "c20a"
		wielded_item_state = "c20a"
	else
		icon_state = "c20a"
		item_state = "c20a-empty"
		wielded_item_state = "c20a-empty"

/obj/item/gun/projectile/automatic/sec_smg/c20a/empty
	starts_loaded = FALSE

/datum/design/item/weapon/c20a
	id = "c20a"
	req_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	materials = list(MATERIAL_STEEL = 8000, MATERIAL_SILVER = 3000, MATERIAL_DIAMOND = 1500)
	build_path = /obj/item/gun/projectile/automatic/sec_smg/c20a
	sort_string = "TAZGA"

/obj/item/ammo_magazine/smg_nt
	name = "box magazine"
	icon_state = "smg"
	icon = 'mods/guns/icons/obj/nt_smg.dmi'
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/pistol/small
	matter = list(MATERIAL_STEEL = 1200)
	caliber = CALIBER_PISTOL_SMALL
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/smg_nt/empty
	initial_ammo = 0

/obj/item/ammo_magazine/smg_nt/rubber
	labels = list("rubber")
	ammo_type = /obj/item/ammo_casing/pistol/small/rubber

/obj/item/ammo_magazine/smg_nt/practice
	labels = list("practice")
	ammo_type = /obj/item/ammo_casing/pistol/small/practice

/obj/item/ammo_magazine/smg_nt/ap
	labels = list("AP")
	icon_state = "smg_ap"
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/pistol/small/ap

/obj/item/ammo_casing/pistol/small/ap
	desc = "An armor piercing pistol bullet casing."
	label = "AP"
	projectile_type = /obj/item/projectile/bullet/pistol/holdout/ap
	icon_state = "smallcasing_f"

/obj/item/projectile/bullet/pistol/holdout/ap
	damage = 30
	armor_penetration = 15
	//[SIERRA-ADD] - Mechs-by-Shegar
	mech_armor_penetration = 0
	mech_armor_damage = 20 //15 попаданий чтоб сорвать броню
	//[SIERRA-ADD]

/obj/item/storage/box/ammo/smg_nt
	name = "box of 7mm box magazines - lethal"
	startswith = list(/obj/item/ammo_magazine/smg_nt = 7)

/obj/item/storage/box/ammo/smg_nt/rubber
	name = "box of 7mm box magazines - rubber"
	startswith = list(/obj/item/ammo_magazine/smg_nt/rubber = 7)

/obj/item/storage/box/ammo/smg_nt/ap
	name = "box of 7mm box magazines - armor piercing"
	startswith = list(/obj/item/ammo_magazine/smg_nt/ap = 4)

// Ammo Box

/obj/item/ammobox/pistol/small_ap
	ammo_type = /obj/item/ammo_casing/pistol/small/ap
