/obj/item/gun/energy/voxshot
	name = "gunk spewer"
	desc = "Somewhat massive type of object, that smells burned flesh and teeth dust. Parts of it twitch and writhe, as if alive."
	icon = 'mods/vox/icons/vox.dmi'
	icon_state = "voxshot"
	item_icons = list(
		slot_l_hand_str = 'mods/vox/icons/lefthand.dmi',
		slot_r_hand_str = 'mods/vox/icons/righthand.dmi'
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
			"fire_sound" = 'mods/vox/sounds/voxshotvomit.ogg',
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
