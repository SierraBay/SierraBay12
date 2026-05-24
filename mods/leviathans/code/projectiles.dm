// Large fireball projectile
/obj/meteor/leviathan_fireball
	name = "draconic fireball"
	desc = "A massive ball of stellar plasma."
	icon = 'mods/leviathans/icons/projectiles.dmi'
	icon_state = "dragonball"
	health = 5
	hits = 8
	ismissile = TRUE
	hitpwr = EX_ACT_DEVASTATING
	heavy = 1
	meteordrop = /obj/item/ore/phoron
	dropamt = 10

/obj/meteor/leviathan_fireball/meteor_effect()
	..()
	// Massive explosion for the dragon
	explosion(src.loc, 18, adminlog = 1, turf_breaker = TRUE)

/obj/meteor/leviathan_fireball/get_shield_damage()
	return ..() * rand(40, 80)

// Ball EMP charge
/obj/meteor/supermatter/medusa
	name = "medusa charge"
	icon = 'mods/leviathans/icons/projectiles.dmi'
	icon_state = "medusaball"
	desc = "Shiny lightning ball"
	meteordrop = /obj/item/ore/uranium
	health = 3
	dropamt = 5
	ismissile = TRUE

/obj/meteor/supermatter/medusa/meteor_effect()
	..()
	empulse(get_turf(src), rand(5,8), rand(6,9))
	log_and_message_admins("Medusa charge exploded", null, src)

// Piercing pod containing drones
/obj/meteor/drone_pod
	name = "autonomous dronepod missile"
	desc = "A small metallic pod missile containing hostile drones."
	icon = 'mods/leviathans/icons/dronepod.dmi'
	icon_state = "burpod"
	meteordrop = null
	ismissile = TRUE
	health = 7
	hitpwr = EX_ACT_DEVASTATING
	hits = 12
	pixel_x = -16
	pixel_y = -16
	// Chance to pierce ship shields
	var/pass_chance = 33

/obj/meteor/drone_pod/meteor_effect()
	log_and_message_admins("Drone pod from swarm placed", null, src)

	var/turf/T = get_turf(src)
	if(!T) return

	playsound(T, 'sound/effects/meteorimpact.ogg', 100, 1)

	new /obj/structure/drone_shell(T)

	var/datum/effect/smoke_spread/smoke = new
	smoke.set_up(3, 0, T)
	smoke.start()
	playsound(T, 'sound/effects/smoke.ogg', 50, 1)

	var/drone_count = rand(1, 3)
	for(var/i = 1 to drone_count)
		new /mob/living/simple_animal/hostile/retaliate/malf_drone(T)

	// 10% chance to spawn a hullbreaker animal
	if(prob(10))
		new /mob/living/simple_animal/hostile/fleet_heavy/malf(T)


/obj/meteor/drone_pod/get_hit()
	hits--
	if(hits <= 0)
		meteor_effect()
		qdel(src)

/obj/meteor/drone_pod/can_pass_shield(obj/machinery/power/shield_generator/gen)
	if(prob(pass_chance))
		return TRUE
	var/turf/T = get_turf(src)
	new /obj/gibspawner/robot(T)
	qdel(src)
	return FALSE

/mob/living/simple_animal/hostile/fleet_heavy/malf
	faction = "malf_drone"

/obj/structure/drone_shell
	name = "drone shell"
	desc = "A mangled piece of a drone pod's outer casing."
	icon = 'mods/leviathans/icons/dronepod.dmi'
	icon_state = "pod_open"
	density = TRUE
	anchored = TRUE
	health_max = 100
	pixel_x = -16
	pixel_y = -16

/obj/structure/drone_shell/on_death()
	new /obj/item/ore/iron(get_turf(src))
	qdel(src)

/obj/structure/drone_shell/use_tool(obj/item/W, mob/user, list/click_params)
	if(isWelder(W))
		var/obj/item/weldingtool/WT = W
		if(!WT.isOn())
			to_chat(user, SPAN_WARNING("\The [WT] must be on to do this."))
			return TRUE
		if(WT.remove_fuel(3, user))
			user.visible_message(SPAN_NOTICE("\The [user] starts deconstructing \the [src] with \a [WT]."), SPAN_NOTICE("You start deconstructing \the [src] with \a [WT]."))
			if(do_after(user, 3 SECONDS, src) && WT.isOn())
				user.visible_message(SPAN_NOTICE("\The [user] deconstructs \the [src] with \a [WT]."), SPAN_NOTICE("You deconstruct \the [src] with \a [WT]."))
				new /obj/item/stack/material/steel/ten(get_turf(src))
				qdel(src)
			return TRUE
	return ..()
