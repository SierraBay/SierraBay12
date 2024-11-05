/obj/item/gun/energy/gun/skrell
	icon = 'mods/guns/icons/obj/skrell_pistol.dmi'

/obj/item/gun/energy/pulse_rifle/skrell
	icon = 'mods/guns/icons/obj/skrell_carbine.dmi'

/obj/item/gun/magnetic/railgun/flechette/skrell
	icon = 'icons/obj/guns/skrell_rifle.dmi'

// VOX BOX

/obj/item/projectile/beam/darkmatter
	damage = 30
	armor_penetration = 40

/obj/item/projectile/beam/stun/darkmatter
	agony = 70
	eyeblur = 6

/obj/item/projectile/energy/darkmatter
	damage = 10
	armor_penetration = 40

/obj/item/gun/energy/darkmatter
	firemodes = list(
		list(mode_name="stunning", burst=1, fire_delay=null, move_delay=null, burst_accuracy=list(30), dispersion=null, projectile_type=/obj/item/projectile/beam/stun/darkmatter, charge_cost = 60),
		list(mode_name="focused", burst=1, fire_delay=17, move_delay=null, burst_accuracy=list(30), dispersion=null, projectile_type=/obj/item/projectile/beam/darkmatter, charge_cost = 100),
		list(mode_name="scatter burst", burst=8, fire_delay=null, move_delay=4, burst_accuracy=list(0, 0, 0, 0, 0, 0, 0, 0), dispersion=list(0, 0, 0, 1, 1, 1, 2, 2, 3), projectile_type=/obj/item/projectile/energy/darkmatter, charge_cost = 7)
		)

/obj/item/gun/energy/sonic
	firemodes = list(
		list(mode_name="normal", projectile_type=/obj/item/projectile/energy/plasmastun/sonic/weak, charge_cost = 50),
		list(mode_name="overcharge", projectile_type=/obj/item/projectile/energy/plasmastun/sonic/strong, charge_cost = 100)
		)

/obj/item/projectile/energy/plasmastun/sonic
	life_span = 6

/obj/item/projectile/energy/plasmastun/sonic/strong
	damage = 35

/obj/item/gun/launcher/alien/slugsling
	ammo_gen_time = 150

/obj/item/gun/launcher/alien/spikethrower
	release_force = 38


/obj/item/clothing/suit/armor/vox_scrap
	desc = "A hodgepodge of various pieces of unknown heavy metal scrapped together into a rudimentary vox-shaped piece of armor."
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_MAJOR,
		bomb = ARMOR_BOMB_PADDED
		)

/obj/item/clothing/suit/armor/vox_scrap/New()
		..()
		slowdown_per_slot[slot_wear_suit] = 1.5

/obj/item/clothing/head/helmet/vox_scrap
	name = "rusted metal helmet"
	desc = "A hodgepodge of various pieces of unknown heavy metal scrapped together into a rudimentary vox-shaped helmet."
	icon = 'mods/guns/icons/mob/clothing/obj_head.dmi'
	item_icons = list(slot_head_str = 'mods/guns/icons/mob/clothing/onmob_head.dmi')
	icon_state = "vox_scrap"
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_MAJOR,
		bomb = ARMOR_BOMB_PADDED
		)
	item_flags = ITEM_FLAG_THICKMATERIAL
	flags_inv = HIDEEARS|BLOCKHEADHAIR
	body_parts_covered = HEAD|FACE
	species_restricted = list(SPECIES_VOX)
	siemens_coefficient = 1
	tint = TINT_MODERATE

/obj/item/clothing/head/helmet/vox_scrap/New()
	..()
	slowdown_per_slot[slot_head] = 0.4
