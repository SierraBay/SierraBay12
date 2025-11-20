/obj/energy_ball
	name = "НЕЧТО"
	desc = "Чудовищно огромный сгусток чего-то электрического, словно мега выстрел от X-6! Какая-то шаровая молния? Лучше к этому не приближаться!"
	anchored = TRUE
	icon = 'mods/anomaly/icons/energy_ball.dmi'
	icon_state = "energy_ball"
	glide_size = 0.8
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	var/next_tesla_attack = 0
	var/next_move = 0
	var/list/current_turfs = list()
	var/turf/current_target_turf
	var/current_step = 1

/obj/energy_ball/New(loc, ...)
	. = ..()
	current_turfs = create_circle_turfs(get_turf(src), 6)
	START_PROCESSING(SSanom, src)

///Гибает если к нему подойти
/obj/energy_ball/Bumped(AM)
	if(isliving(AM))
		var/mob/living/victim = AM
		victim.dust()


/obj/energy_ball/Process()
	if(world.time > next_tesla_attack)
		do_tesla_attack()
	if(world.time > next_move)
		do_tesla_move()

/obj/energy_ball/proc/do_tesla_attack()
	set waitfor = FALSE
	next_tesla_attack = world.time + rand(5 SECONDS, 9 SECONDS)
	var/hited = FALSE
	for(var/mob/living/picked_living in range(get_turf(src), 3))
		electroanomaly_act(picked_living, null)
		src.Beam(BeamTarget = get_turf(picked_living), icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
		hited = TRUE

	for(var/obj/structure/aurora/picked_aurora in range(get_turf(src), 3))
		picked_aurora.wake_up(5 SECONDS)
		src.Beam(BeamTarget = get_turf(picked_aurora), icon_state = "electra_long",icon='mods/anomaly/icons/effects.dmi',time = 0.3 SECONDS)
		hited = TRUE

	if(hited)
		playsound(src, 'mods/anomaly/sounds/electra_blast.ogg', 100, FALSE  )

///Нам пора двигаться
/obj/energy_ball/proc/do_tesla_move()
	if(!current_target_turf)
		current_target_turf = current_turfs[current_step]

	if(get_turf(src) in current_turfs)
		current_step ++

	if(current_step > LAZYLEN(current_turfs))
		current_step = 1
	current_target_turf = current_turfs[current_step]

	forceMove(get_step(get_turf(src), get_dir(get_turf(src), current_target_turf)))
	next_move = world.time + 0.6 SECONDS

/obj/energy_ball/forceMove()
	. = ..()
	for(var/mob/living/victim in loc)
		victim.dust()
