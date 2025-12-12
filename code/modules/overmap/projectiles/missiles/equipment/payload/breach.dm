// Breach a hull
/obj/item/missile_equipment/payload/breach
	name = "breach device"
	missile_name_override = "breach missile"
	desc = "HEAT missile."
	icon_state = "ion"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 3, TECH_ENGINEERING = 3)
	matter = list(MATERIAL_ALUMINIUM = 4000, MATERIAL_GOLD = 1000, MATERIAL_URANIUM = 500)

	var/breach_deep = 6
	var/last_shot = 0
	var/fire_delay = 0.01 SECONDS

/obj/item/missile_equipment/payload/breach/on_trigger(armed)
	if (armed)
		var/shots_fired = breach_deep
		for(shots_fired; shots_fired >= 0; shots_fired -= 1)
			if((last_shot + fire_delay) <= world.time)
				last_shot = world.time
			for(var/i in 1 to shots_fired)
				var/obj/item/projectile/proj = new /obj/item/projectile/beam/heat(get_turf(src))
				proj.life_span = breach_deep
				proj.launch( get_step(loc, loc.dir))
				if(i < shots_fired)
					sleep(fire_delay)
		playsound(src.loc, 'sound/weapons/marauder.ogg', 30, 1)
	..()


/obj/item/projectile/beam/heat
	name = "heat"
	icon_state = "heavylaser"
	fire_sound = null
	damage = 950
	armor_penetration = 100
	edge = TRUE
	damage_type = DAMAGE_EXPLODE
	life_span = 3
	pass_flags = PASS_FLAG_TABLE
	distance_falloff = 3

	muzzle_type = /obj/projectile/laser/heavy/muzzle
	tracer_type = /obj/projectile/laser/heavy/tracer
	impact_type = /obj/projectile/laser/heavy/impact

/obj/item/projectile/beam/heat/on_impact(atom/A)
	. = ..()
	if(A.density)
		A.ex_act(EX_ACT_DEVASTATING)
		for(var/mob/H in range(20, src))
			if(!H.stat && !istype(H, /mob/living/silicon/ai))
				shake_camera(H, 5, 2)
		qdel(src)
