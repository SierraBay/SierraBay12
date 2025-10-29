/obj/flying_planet_deco
	icon = 'mods/anomaly/icons/flying_deco.dmi'

///Обьект реагирует на грави удар
/obj/flying_planet_deco/proc/react_at_gravi()
	return


//ДЕРЕВО
/obj/flying_planet_deco/tree
	name = "Дерево"
	desc = "Покарёженное переломанное дерево обыкновеннейших размеров. Что же за сила так помучило его?"
	var/health
	///Звуки разрушений дерева
	var/list/sounds_of_broken
	pixel_x = -16

/obj/flying_planet_deco/tree/Initialize()
	. = ..()
	health = rand(3, 5)
	var/list/possible_sprites = list(
		"tree_1",
		"tree_2",
		"tree_3",
		"tree_4",
		"tree_5"
	)
	icon_state = pick(possible_sprites)

/obj/flying_planet_deco/tree/react_at_gravi()
	set waitfor = FALSE
	damage_tree()

/obj/flying_planet_deco/tree/proc/damage_tree()
	set waitfor = FALSE
	health = clamp(health - 1, 0, 5)
	shake_animation(2)
	if(health == 0)
		var/list/destroys = list(
			'mods/anomaly/sounds/FALLING_TREE.ogg'
		)
		playsound(get_turf(src), pick(destroys), 100)
		sleep(4 SECONDS)
		destroy_tree()
	else
		var/list/tresks = list(
			'mods/anomaly/sounds/TRESK_1.ogg',
			'mods/anomaly/sounds/TRESK_2.ogg'
		)
		playsound(get_turf(src), pick(tresks), 100)
		sleep(1.5 SECONDS)
		spawn_stiks()

/obj/flying_planet_deco/tree/Click(location, control, params)
	. = ..()
	if(!ishuman(usr))
		return
	var/mob/living/carbon/player = usr
	if(!player.weakened)
		to_chat(usr, SPAN_INFO("Я трогаю дерево...думаю я выгляжу глупо..."))
		return
	usr.forceMove(get_turf(src))
	to_chat(usr, SPAN_GOOD("Я подтягиваю себя к стволу дерева!"))

/obj/flying_planet_deco/tree/proc/spawn_stiks()
	var/sticks_ammout = rand(1, 3)
	var/list/turfs = range(3, get_turf(src))
	LAZYREMOVE(turfs, get_turf(src))
	for(var/turf/T in turfs)
		if(locate(/obj/flying_planet_deco/sticks) in T || locate(/obj/flying_planet_deco/logs) in T)
			continue
		while(sticks_ammout > 0)
			new /obj/flying_planet_deco/sticks(T)
			sticks_ammout--

/obj/flying_planet_deco/tree/proc/destroy_tree()
	var/logs_ammout = rand(1, 3)
	var/list/turfs = range(3, get_turf(src))
	LAZYREMOVE(turfs, get_turf(src))
	for(var/turf/T in turfs)
		if(locate(/obj/flying_planet_deco/sticks) in T || locate(/obj/flying_planet_deco/logs) in T)
			continue
		while(logs_ammout > 0)
			new /obj/flying_planet_deco/logs(T)
			logs_ammout--
	qdel(src)


///Палочки
/obj/flying_planet_deco/sticks
	name = "Палки"
	desc = "Ветки, палки, видимо с дерева. Видимо ветра тут сильные, ветви рвёт."

/obj/flying_planet_deco/sticks/Initialize()
	. = ..()
	var/list/possible_sprites = list(
		"burnedbush6",
		"burnedbush7",
		"burnedbush8",
		"burnedbush9"
	)
	icon_state = pick(possible_sprites)

/obj/flying_planet_deco/logs
	name = "Бревно"
	desc = "Бревно, в прошлом часть великого дерева. В прошлом."

/obj/flying_planet_deco/pen
	name = "Пень"
	icon_state = "destroyed_tree"
	desc = "Пень, в прошлом фундамент великого дерева. В прошлом."

/obj/flying_planet_deco/logs/Initialize()
	. = ..()
	var/list/possible_sprites = list(
		"burnedbush10"
		)
	icon_state = pick(possible_sprites)
