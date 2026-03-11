/obj/meteor/leviathan_fireball
	name = "draconic fireball"
	desc = "A massive ball of stellar plasma."
	icon = 'icons/obj/meteor.dmi' // TODO ПЛЕЙСХОЛДЕР!!!
	icon_state = "flaming"
	hits = 10
	hitpwr = EX_ACT_DEVASTATING
	heavy = 1
	meteordrop = /obj/item/ore/phoron
	dropamt = 10

/obj/meteor/leviathan_fireball/meteor_effect()
	..()
	// Большой бум для большого дракона
	explosion(src.loc, 18, adminlog = 1, turf_breaker = TRUE)

/obj/meteor/supermatter/medusa
	name = "medusa charge"
	icon_state = "glowing_blue" // TODO ПЛЕЙСХОЛДЕР!!!
	desc = "Shiny lightning bolt"
	meteordrop = /obj/item/ore/uranium
	dropamt = 5

// Логика сабота
/obj/meteor/drone_pod
	name = "autonomous drone pod"
	desc = "A small metallic pod containing hostile drones."
	icon = 'icons/obj/meteor.dmi' // TODO ПЛЕЙСХОЛДЕР!!!
	icon_state = "small"
	meteordrop = null
	ismissile = TRUE
	hitpwr = EX_ACT_HEAVY
	hits = 6

/obj/meteor/drone_pod/meteor_effect()
	log_and_message_admins("Drone pod from swarm placed", null, src)
	var/obj/meteor/drone_pod/secondary/M = new(src.loc)
	M.dest = dest
	spawn(0)
		if(M)
			walk_towards(M, dest, 3)

/obj/meteor/drone_pod/secondary
	name = "autonomous drone pod"
	desc = "A small, heavily armored pod containing autonomous drones."
	icon = 'icons/obj/meteor.dmi' // TODO ПЛЕЙСХОЛДЕР!!!
	icon_state = "small"
	hits = 5
	hitpwr = EX_ACT_DEVASTATING
	ismissile = TRUE
	meteordrop = null

/obj/meteor/drone_pod/secondary/meteor_effect()
	var/turf/T = get_turf(src)
	if(!T) return

	var/drone_count = rand(1, 3)
	for(var/i = 1 to drone_count)
		new /mob/living/simple_animal/hostile/retaliate/malf_drone(T)

	// 10% шанс, что появится хуллбрейкер
	if(prob(10))
		new /mob/living/simple_animal/hostile/fleet_heavy(T)

/obj/meteor/drone_pod/secondary/get_hit()
	hits--
	if(hits <= 0)
		meteor_effect()
		qdel(src)
