/* SHOTGUN - 12 GAUGE
 * ========
 */

/obj/item/projectile/bullet/shotgun
	name = "slug"
	damage = 60
	armor_penetration = 10

/obj/item/projectile/bullet/pellet/shotgun/flechette
	name = "flechette"
	icon_state = "flechette"
	damage = 30
	armor_penetration = 35
	pellets = 3
	range_step = 3
	base_spread = 99
	spread_step = 2
	penetration_modifier = 0.5
	hitchance_mod = 5

/*************************
sierra specific ammo types
**************************/

/*
Manstopper Rounds - Shotgun
*/

/obj/item/ammobox/shotgun/manstopper
	ammo_type = /obj/item/ammo_casing/shotgun/manstopper

/obj/item/storage/box/ammo/manstoppershells
	name = "box of manstopper shells"
	startswith = list(/obj/item/ammo_magazine/shotholder/manstopper = 2)

/obj/item/ammo_magazine/shotholder/manstopper
	name = "manstopper shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/manstopper
	marking_color = COLOR_SURGERY_BLUE

/obj/item/ammo_casing/shotgun/manstopper
	name = "shotgun shell"
	desc = "A manstopper shell."
	icon = 'mods/guns/icons/obj/ammo.dmi'
	icon_state = "mnshell"
	spent_icon = "mnshell-spent"
	projectile_type = /obj/item/projectile/bullet/shotgun/manstopper
	matter = list(MATERIAL_STEEL = 360)

/obj/item/projectile/bullet/shotgun/manstopper
	name = "manstopper"
	damage = 50
	agony = 30
	armor_penetration = 0
	penetration_modifier = 0

/*
Dragon's Breath Rounds - Shotgun
*/

/obj/item/ammobox/shotgun/dragon
	ammo_type = /obj/item/ammo_casing/shotgun/dragon

/obj/item/storage/box/ammo/dragon
	name = "box of dragon's breath shells"
	startswith = list(/obj/item/ammo_magazine/shotholder/dragon = 2)

/obj/item/ammo_magazine/shotholder/dragon
	name = "dragon's breath shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/dragon
	marking_color = COLOR_ORANGE

/obj/item/ammo_casing/shotgun/dragon
	name = "dragon's breath shell"
	desc = "A dragon's breath incendiary shell."
	icon = 'mods/guns/icons/obj/ammo.dmi'
	icon_state = "dbshell"
	spent_icon = "dbshell-spent"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun/dragon
	matter = list(MATERIAL_STEEL = 270, MATERIAL_PHORON = 90)

/obj/item/projectile/bullet/pellet/shotgun/dragon
	name = "incendiary pellet"
	icon_state = "pellet"
	damage = 10
	pellets = 4
	damage_type = DAMAGE_BURN
	sharp = TRUE
	embed = FALSE
	damage_flags = DAMAGE_FLAG_LASER
	range_step = 1
	spread_step = 40
	armor_penetration = 0
	penetration_modifier = 0
	//[SIERRA-ADD] - Mechs-by-Shegar
	mech_armor_penetration = 0
	mech_armor_damage = 5 //Дробь малоэффективна
	//[SIERRA-ADD]

/obj/item/projectile/bullet/pellet/shotgun/dragon/on_hit(atom/target, blocked = 0)
	..()
	for(var/turf/T in get_turfs_in_range(get_turf(src), 0))
		new /obj/turf_fire/small (T)
	if(isliving(target))
		var/mob/living/L = target
		L.IgniteMob()
