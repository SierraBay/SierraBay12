#define SOUNDS_CRYSTAL_METAL    list('mods/_fd/old_space_cannons/sounds/glassbreak1.ogg','mods/_fd/old_space_cannons/sounds/glassbreak2.ogg','mods/_fd/old_space_cannons/sounds/glassbreak3.ogg')
#define CALIBER_SHIP_CRYSTAL    "Crystal"

/obj/item/ammo_magazine/ammobox/crystal/ex_act()
	return

/obj/item/ammo_magazine/ammobox/crystal/New()
	..()
	ammo_count = max_ammo

/obj/item/ammo_magazine/ammobox/crystal/Initialize()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/ammo_magazine/ammobox/crystal/Destroy()
	..()
	STOP_PROCESSING(SSobj, src)

/obj/item/ammo_magazine/ammobox/crystal/Process()
	if(regenerate_ammo && max_ammo < ammo_count)
		regen++
		if(regen >= regenerate_delay)
			regen = 0
			ammo_count++
	..()

///////////////////////////AMMOBOX///////////////////////////

/obj/item/ammo_magazine/ammobox/crystal
	name = "Mobile crystal growth chamber"
	desc = "A box where the crystals growth. (PLACEHOLDER)"

	caliber = CALIBER_SHIP_CRYSTAL
	max_ammo = 48
	ammo_type = /obj/item/ammo_casing/huge_caliber/crystal

	var/ammo_count = 0

	var/regenerate_ammo = TRUE
	var/regenerate_delay = 10
	var/regen = 0

/obj/item/ammo_magazine/ammobox/crystal/high_explosive
	name = "Mobile B-type crystal growth chamber"
	icon_state = "ammocrate_autocannon_he"
	max_ammo = 24
	ammo_type = /obj/item/ammo_casing/huge_caliber/crystal/high_explosive

/obj/item/ammo_magazine/ammobox/crystal/shrapnel
	name = "Mobile X-type crystal growth chamber"
	icon_state = "ammocrate_autocannon_ap"
	max_ammo = 24
	ammo_type = /obj/item/ammo_casing/huge_caliber/crystal/shrapnel

///////////////////////////CASING///////////////////////////

/obj/item/ammo_casing/huge_caliber/crystal
	name = "crystal shard"
	desc = "A strange, regenerative crystal."
	caliber = CALIBER_SHIP_CRYSTAL
	projectile_type = /obj/item/projectile/bullet/huge_caliber/crystal

/obj/item/ammo_casing/huge_caliber/crystal/high_explosive
	projectile_type = /obj/item/projectile/bullet/huge_caliber/crystal/high_explosive

/obj/item/ammo_casing/huge_caliber/crystal/shrapnel
	projectile_type = /obj/item/projectile/bullet/huge_caliber/crystal/shrapnel

///////////////////////////BULLETS///////////////////////////

/obj/item/projectile/bullet/huge_caliber/crystal
	name ="crystal shard"
	icon_state= "Needler Shot"
	damage = 350
	pew_spread = 10
	armor_penetration = 100
	penetration_modifier = 1.1
	muzzle_type = null
	fire_sound = null
	explosion_radius = 6
	explosion_max_power = EX_ACT_DEVASTATING

/obj/item/projectile/bullet/huge_caliber/crystal/Bump(atom/A as mob|obj|turf|area, forced=0)
	if(!exploded)
		exploded = TRUE
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL),150)
	..()

/obj/item/projectile/bullet/huge_caliber/crystal/Destroy()
	if(src)
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL))
	..()


/obj/item/projectile/bullet/huge_caliber/crystal/high_explosive/Bump(atom/A as mob|obj|turf|area, forced=0)
	var/backwards = turn(dir, 180)
	if(!exploded)
		exploded = TRUE
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL),150)
		explosion(get_step(get_turf(A), backwards), explosion_radius, explosion_max_power)
		qdel(src)


/obj/item/projectile/bullet/huge_caliber/crystal/shrapnel
	armor_penetration = 50

/obj/item/projectile/bullet/huge_caliber/crystal/shrapnel/Bump(atom/A as mob|obj|turf|area, forced=0)
	if(!exploded)
		exploded = TRUE
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL),150)
		fragmentate(get_turf(src), rand(40,60), 7, list(/obj/item/projectile/bullet/pellet/fragment/crystal), name)
		qdel(src)
	..()

/obj/item/projectile/bullet/huge_caliber/crystal/shrapnel/Destroy()
	if(src && !exploded)
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL),150)
		fragmentate(get_turf(src), rand(40,60), 7, list(/obj/item/projectile/bullet/pellet/fragment/crystal), name)
	..()

/obj/item/projectile/bullet/pellet/fragment/crystal
	name = "crystal fragment"
	damage = 45
	icon_state= "needle"

/obj/item/projectile/bullet/pellet/fragment/crystal/Bump(atom/A as mob|obj|turf|area, forced=0)
	if(src)
		playsound(get_turf(src),pick(SOUNDS_CRYSTAL_METAL))
	..()

#undef CALIBER_SHIP_CRYSTAL
#undef SOUNDS_CRYSTAL_METAL
