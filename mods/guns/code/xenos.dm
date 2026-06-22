/obj/item/gun/energy/gun/skrell
	icon = 'mods/guns/icons/obj/skrell_pistol.dmi'

/obj/item/gun/energy/pulse_rifle/skrell
	icon = 'mods/guns/icons/obj/skrell_carbine.dmi'

/obj/item/gun/magnetic/railgun/flechette/skrell
	icon = 'mods/guns/icons/obj/skrell_rifle.dmi'

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
		list("mode_name" = "stunning", burst=1, fire_delay=null, move_delay=null, burst_accuracy=list(30), dispersion=null, "projectile_type" = /obj/item/projectile/beam/stun/darkmatter, charge_cost = 60),
		list("mode_name" = "focused", burst=1, fire_delay=17, move_delay=null, burst_accuracy=list(30), dispersion=null, "projectile_type" = /obj/item/projectile/beam/darkmatter, charge_cost = 100),
		list("mode_name" = "scatter burst", burst=8, fire_delay=null, move_delay=4, burst_accuracy=list(0, 0, 0, 0, 0, 0, 0, 0), dispersion=list(0, 0, 0, 1, 1, 1, 2, 2, 3), "projectile_type" = /obj/item/projectile/energy/darkmatter, charge_cost = 7)
		)

/obj/item/gun/energy/sonic
	firemodes = list(
		list("mode_name" = "normal", "projectile_type" = /obj/item/projectile/energy/plasmastun/sonic/weak, charge_cost = 50),
		list("mode_name" = "overcharge", "projectile_type" = /obj/item/projectile/energy/plasmastun/sonic/strong, charge_cost = 100)
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

/obj/item/gun/energy/voxshot
	name = "gunk spewer"
	desc = "Somewhat massive type of object, that smells burned flesh and teeth dust. Parts of it twitch and writhe, as if alive."
	icon = 'mods/guns/icons/obj/vox.dmi'
	icon_state = "voxshot"
	item_icons = list(
		slot_l_hand_str = 'mods/guns/icons/mob/lefthand_guns.dmi',
		slot_r_hand_str = 'mods/guns/icons/mob/righthand_guns.dmi'
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
			"fire_sound" = 'mods/guns/sounds/voxshotvomit.ogg',
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
