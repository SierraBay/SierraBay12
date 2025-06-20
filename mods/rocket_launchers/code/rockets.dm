// base projectile
/obj/item/projectile/bullet/rpg_rocket
	name = "RPG missile"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "missile"
	fire_sound = 'mods/rocket_launchers/sounds/rocket_fire.ogg'
	damage = 15
	armor_penetration = 0
	damage_falloff = 0
	life_span = 255
	var/explosion_size = 1

// trace effect
/obj/item/projectile/bullet/rpg_rocket/tracer_effect()
	new /obj/temp_visual/rps_smoke (get_turf(src))

// base casing
/obj/item/ammo_casing/rpg_rocket
	name = "RPG rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "slshell"
	projectile_type = /obj/item/projectile/bullet/rpg_rocket
	caliber = CALIBER_ROCKET

// hit base
/obj/item/projectile/bullet/rpg_rocket/on_hit(atom/target, blocked, def_zone)
	. = ..()
	if(get_dist(starting, target.loc) < 3 || starting.loc == target.loc) // check detonating distance
		return FALSE
	else
		var/turf/T = get_turf(src)
		if(!T) return FALSE
		on_explosion(T)
		return TRUE

// exlosion on hit
/obj/item/projectile/bullet/rpg_rocket/proc/on_explosion(turf/O)
	if(explosion_size)
		explosion(O, explosion_size, 0, 0, 0)

// ---------ROCKET PROJECTILES---------
// FRAG
/obj/item/projectile/bullet/rpg_rocket/frag
	name = "RPG frag missile"
	explosion_size = 2
	var/list/fragment_types = list(/obj/item/projectile/bullet/pellet/fragment/strong = 1) // makin stronger fragments
	var/num_fragments = 72
	var/spread_range = 7

/obj/item/projectile/bullet/rpg_rocket/frag/proc/detonate()
	var/turf/T = get_turf(src)
	if(!T) return

	T.hotspot_expose(700,125)

	src.fragmentate(T, num_fragments, spread_range, fragment_types)

	qdel(src)

/obj/item/projectile/bullet/rpg_rocket/frag/on_hit(atom/target, blocked)
	if(!..())
		return

	src.detonate()

// HEAT
/obj/item/projectile/bullet/rpg_rocket/heat
	name = "RPG heat missile"
	var/heat_damage = 200

/obj/item/projectile/bullet/rpg_rocket/heat/proc/jet_process(turf/T, damage, def_zone, dir, iterator)
	if(!iterator) return

	var/blocked = FALSE
	var/turf/next_turf = get_step(T, dir)

	if(!(T.density || istype(T, /turf/space)))
		T.IgniteTurf(damage / 2)

	for(var/atom/A in T)
		if(blocked) return

		if(ismech(A))
			var/mob/living/exosuit/mech = A

			for(var/obj/aura/mechshield/aura_shield in mech.auras)
				if(aura_shield.active)
					aura_shield.shields?.stop_damage(damage) // stopped by shield
					blocked = TRUE

			if(!blocked)
				switch(def_zone)
					if(BP_HEAD , BP_CHEST, BP_MOUTH, BP_EYES, BP_GROIN)
						for(var/mob/living/pilot in mech.pilots)
							pilot.apply_damage(damage / 4, DAMAGE_BRUTE, def_zone)
							pilot.apply_damage(damage / 2, DAMAGE_BURN, def_zone)
							to_chat(pilot, SPAN_WARNING("You feel a wave of heat wash over you!"))
							pilot.adjust_fire_stacks(rand(4,6) * iterator / 2)
							pilot.IgniteMob()

				var/mech_damage = damage * 1.25
				var/obj/item/mech_component/target_part = mech.zoneToComponent(def_zone)
				var/overflow_damage = max(0, mech_damage - target_part?.max_hp + target_part?.total_damage)
				mech.apply_damage(mech_damage, DAMAGE_BRUTE, def_zone)
				if(overflow_damage > 0)
					for(var/obj/item/mech_component/part in mech)
						if(part != target_part)
							part.take_brute_damage(overflow_damage)

		else if(isliving(A))
			var/mob/living/M = A
			M.apply_damage(damage / 4, DAMAGE_BRUTE, def_zone)
			M.apply_damage(damage / 2, DAMAGE_BURN, def_zone)
			to_chat(M, SPAN_WARNING("You feel a wave of heat wash over you!"))
			M.adjust_fire_stacks(rand(4,6) * iterator / 2)
			M.IgniteMob()

		else if(isobj(A))
			var/obj/obj = A
			obj.damage_health(damage, src.damage_type, src.damage_flags)

	if(blocked) return
	jet_process(next_turf, damage / 2, def_zone, dir, --iterator)

/obj/item/projectile/bullet/rpg_rocket/heat/on_hit(atom/target, blocked, def_zone)
	if(!..())
		return

	var/turf/T = get_turf(src)
	if(!T) return

	if(!def_zone)
		def_zone = ran_zone(def_zone)


	var/dir = get_dir(src.starting, target)
	var/turf/next_turf = get_step(target, dir)

	if(ismech(target))
		var/mob/living/exosuit/mech = target

		for(var/obj/aura/mechshield/aura_shield in mech.auras)
			if(aura_shield.active)
				aura_shield.emp_attack() // remove shield by first charge

		switch(def_zone)
			if(BP_HEAD , BP_CHEST, BP_MOUTH, BP_EYES, BP_GROIN)
				for(var/mob/living/pilot in mech.pilots)
					pilot.apply_damage(heat_damage / 4, DAMAGE_BRUTE, def_zone)
					pilot.apply_damage(heat_damage / 2, DAMAGE_BURN, def_zone)
					to_chat(pilot, SPAN_WARNING("You feel a wave of heat wash over you!"))
					pilot.adjust_fire_stacks(rand(6,8))
					pilot.IgniteMob()

		var/mech_damage = heat_damage * 1.25 // ~250 before resists
		var/obj/item/mech_component/target_part = mech.zoneToComponent(def_zone)
		var/overflow_damage = max(0, mech_damage - target_part?.max_hp + target_part?.total_damage)
		mech.apply_damage(mech_damage, DAMAGE_BURN, def_zone)
		if(overflow_damage > 0)
			for(var/obj/item/mech_component/part in mech)
				if(part != target_part)
					part.take_brute_damage(overflow_damage)

	else if(isliving(target))
		var/mob/living/M = target
		M.apply_damage(heat_damage / 4, DAMAGE_BRUTE, def_zone)
		M.apply_damage(heat_damage / 2, DAMAGE_BURN, def_zone)
		to_chat(M, SPAN_WARNING("You feel a wave of heat wash over you!"))
		M.adjust_fire_stacks(rand(6,8))
		M.IgniteMob()

	else if(isturf(target))
		for (var/obj/obj in target)
			obj.damage_health(heat_damage, src.damage_type, src.damage_flags)

	else if(isobj(target))
		var/obj/obj = target
		obj.damage_health(heat_damage, src.damage_type, src.damage_flags)

	jet_process(next_turf, heat_damage / 2, def_zone, dir, 2)

// TANDEM
/obj/item/projectile/bullet/rpg_rocket/heat/tandem
	name = "RPG tandem missile"

/obj/item/projectile/bullet/rpg_rocket/heat/tandem/attack_mob(mob/living/target_mob, distance, miss_modifier)
	. = ..()
	if(!target_mob.aura_check(AURA_TYPE_BULLET, src,def_zone))
		target_mob.bullet_act(src, def_zone) // force to attack shield or smth with bullet aura

// ---------ROCKET CASING---------
// FRAG
/obj/item/ammo_casing/rpg_rocket/frag
	name = "RPG frag rocket shell"
	desc = "A high explosive FRAG grenade designed to be fired from a launcher."
	icon_state = "slshell"
	projectile_type = /obj/item/projectile/bullet/rpg_rocket/frag

// HEAT
/obj/item/ammo_casing/rpg_rocket/heat
	name = "RPG HEAT rocket shell"
	desc = "A high explosive HEAT grenade designed to be fired from a launcher."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/rpg_rocket/heat

// TANDEM
/obj/item/ammo_casing/rpg_rocket/tandem
	name = "RPG TANDEM rocket shell"
	desc = "A high explosive TANDEM grenade designed to be fired from a launcher."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/rpg_rocket/heat/tandem
