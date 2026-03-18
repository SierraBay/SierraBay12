// Огромный фаербол
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
	// Большой бум для большого дракона
	explosion(src.loc, 18, adminlog = 1, turf_breaker = TRUE)

/obj/meteor/leviathan_fireball/get_shield_damage()
	return ..() * rand(40, 80)

// Шаровой ЭМИ заряд
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

// Пробивающий снаряд с дронами внутри
/obj/meteor/drone_pod
	name = "autonomous dronepod missile"
	desc = "A small metallic pod missile containing hostile drones."
	icon = 'icons/obj/meteor.dmi' // TODO ПЛЕЙСХОЛДЕР!!!
	icon_state = "small"
	meteordrop = null
	ismissile = TRUE
	health = 7
	hitpwr = EX_ACT_DEVASTATING
	hits = 12
	// шанс пробития щита
	var/pass_chance = 25

/obj/meteor/drone_pod/meteor_effect()
	log_and_message_admins("Drone pod from swarm placed", null, src)

	var/turf/T = get_turf(src)
	if(!T) return

	playsound(T, 'sound/effects/meteorimpact.ogg', 100, 1)

	var/datum/effect/smoke_spread/smoke = new
	smoke.set_up(3, 0, T)
	smoke.start()
	playsound(T, 'sound/effects/smoke.ogg', 50, 1)

	var/drone_count = rand(1, 3)
	for(var/i = 1 to drone_count)
		new /mob/living/simple_animal/hostile/retaliate/malf_drone(T)

	// 10% шанс, что появится хуллбрейкер
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
	return ..()

/mob/living/simple_animal/hostile/fleet_heavy/malf
	faction = "malf_drone"
