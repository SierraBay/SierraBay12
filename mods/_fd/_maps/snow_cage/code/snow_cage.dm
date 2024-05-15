/obj/overmap/visitable/sector/snow_cage
	name = "arctic planet"
	desc = "An arctic planet with a small number of signatures on the surface. Scans indicate non-natural structures under the planet's surface."
	sector_flags = OVERMAP_SECTOR_KNOWN
	icon_state = "globe"
	initial_generic_waypoints = list(
		"nav_snowcage_1",
		"nav_snowcage_2",
		"nav_snowcage_3"
	)

/datum/map_template/ruin/away_site/snow_cage
	name = "arctic planet"
	id = "awaysite_splanet"
	spawn_cost = INFINITY
	player_cost = 2
	description = "An arctic planet with a small number of signatures on the surface. Scans indicate artificial structures under the planet's surface."
	prefix = "mods/_fd/_maps/snow_cage/maps/"
	suffixes = list("snow_cage-1.dmm","snow_cage-2.dmm","snow_cage-3.dmm","snow_cage-4.dmm")
	area_usage_test_exempted_root_areas = list(/area/splanet/)
	apc_test_exempt_areas = list(
		/area/splanet/outdoors = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/splanet/underground = NO_SCRUBBER|NO_VENT|NO_APC
	)

/obj/shuttle_landmark/nav_splanet/nav1
	name = "Forest Landing Point #1"
	landmark_tag = "nav_snowcage_1"
	base_area = /area/splanet/outdoors

/obj/shuttle_landmark/nav_splanet/nav2
	name = "Forest Landing Point #2"
	landmark_tag = "nav_snowcage_2"
	base_area = /area/splanet/outdoors

/obj/shuttle_landmark/nav_splanet/nav3
	name = "Forest Landing Point #3"
	landmark_tag = "nav_snowcage_3"
	base_area = /area/splanet/outdoors

/area/splanet/outdoors
	name = "Arctic forest"
	icon_state = "centcom"
	dynamic_lighting = 1
	base_turf = /turf/simulated/floor/exoplanet/barren

/area/splanet/indoors
	name = "Cold Caves"
	icon_state = "centcom"
	dynamic_lighting = 1
	base_turf = /turf/simulated/floor/exoplanet/barren

/area/splanet/underground
	name = "Ascent crashsite"
	base_turf = /turf/simulated/open

//МОБЫ

/datum/say_list/smart/harron
	speak = list("Hrrr...","HRrrRRr")
	emote_see = list("clicking it's teeth","growls","sniffs")
	emote_hear = list("barks!")

	say_maybe_target = list("HRr?")	// When they briefly see something.
	say_got_target = list()	// When a target is first assigned.
	say_threaten = list("HRRRrAAA!!")		// When threatening someone.
	say_stand_down = list("Hrrr")	// When the threatened thing goes away.
	say_escalate = list("HRRRRK!!!")		// When the threatened thing doesn't go away.

	threaten_sound = null	// Sound file played when the mob's AI calls threaten_target() for the first time.
	stand_down_sound = null							// Sound file played when the mob's AI loses sight of the threatened target.

/datum/say_list/smart/rafama
	speak = list("WOo...","WOOOOOO")
	emote_see = list("howling","sniffs")
	emote_hear = list("sniffs")

	say_maybe_target = list("Woo")	// When they briefly see something.
	say_got_target = list()	// When a target is first assigned.
	say_threaten = list("WOOoo!!")		// When threatening someone.
	say_stand_down = list("WOo...")	// When the threatened thing goes away.
	say_escalate = list("WOOOOOOOOOOO!!!")		// When the threatened thing doesn't go away.

	threaten_sound = null	// Sound file played when the mob's AI calls threaten_target() for the first time.
	stand_down_sound = null							// Sound file played when the mob's AI loses sight of the threatened target.

/datum/say_list/smart/digger
	speak = list("Skree!","SkRKkK")
	emote_see = list("digs hole in the ground","trembles","giggles")
	emote_hear = list("shakes it's ears")

	say_maybe_target = list("SKkk?")	// When they briefly see something.
	say_got_target = list()	// When a target is first assigned.
	say_threaten = list("SKRRRRK!!")		// When threatening someone.
	say_stand_down = list("SKrr")	// When the threatened thing goes away.
	say_escalate = list("SKREEE!!!")		// When the threatened thing doesn't go away.

	threaten_sound = null	// Sound file played when the mob's AI calls threaten_target() for the first time.
	stand_down_sound = null							// Sound file played when the mob's AI loses sight of the threatened target.


//ЗЕМЛЕРОЙКА

/mob/living/simple_animal/hostile/digger
	name = "earthdigger"
	desc = "Strange looking rodent with sharp claws, probably used as some kind of digging tool."
	faction = "digger"
	icon = 'mods/_fd/fd_assets/icons/animals/adhomai.dmi'
	icon_state = "tunneler"
	icon_living = "tunneler"
	icon_dead = "tunneler_dead"
	movement_cooldown = 1
	maxHealth = 45
	health = 45
	speed = 1
	natural_weapon = /obj/item/natural_weapon/claws/weak
	cold_damage_per_tick = 0
	pass_flags = PASS_FLAG_TABLE
	density = FALSE
	mob_size = MOB_SMALL
	gender = MALE

	say_list_type = /datum/say_list/smart/digger

	special_attack_min_range = 2
	special_attack_max_range = 7
	special_attack_cooldown = 5 SECONDS

	var/tunnel_warning = 0.5 SECONDS
	var/tunnel_tile_speed = 4

/mob/living/simple_animal/hostile/digger/Initialize()
	gender = pick(MALE,FEMALE)
	if(gender == MALE)
		desc = "Strange looking rodent with sharp claws, probably used as some kind of digging tool. This one is probably male"
	if(gender == FEMALE)
		desc = "Strange looking rodent with sharp claws, probably used as some kind of digging tool. This one is probably female"
		icon_state = "tunneler_f"
		icon_living = "tunneler_f"
		icon_dead = "tunneler_f_dead"

	. = ..()

/mob/living/simple_animal/hostile/digger/should_special_attack(atom/A)
	var/turf/destination = get_turf(A)
	var/turf/starting_turf = get_turf(src)
	var/turf/T = starting_turf
	for (var/i = 1 to get_dist(starting_turf, destination))
		if (T == destination)
			break

		T = get_step(T, get_dir(T, destination))
		if (T.density)
			return FALSE
	return T == destination

/mob/living/simple_animal/hostile/digger/do_special_attack(atom/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)

	var/turf/destination = get_turf(A)
	var/turf/starting_turf = get_turf(src)

	do_windup_animation(A, tunnel_warning)
	sleep(tunnel_warning) // For the telegraphing.

	visible_message(SPAN_DANGER("\The [src] tunnels towards \the [A]!"))
	submerge()

	if (handle_tunnel(destination) == FALSE)
		set_AI_busy(FALSE)
		emerge()
		return FALSE

	if (!(src in destination))
		set_AI_busy(FALSE)
		emerge()
		return FALSE

	var/overshoot = TRUE

	for (var/mob/living/L in destination)
		if (L == src)
			continue

		visible_message(SPAN_DANGER("\The [src] erupts from underneath, and hits \the [L]!"))
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		L.Weaken(3)
		overshoot = FALSE

	if (!overshoot)
		set_AI_busy(FALSE)
		emerge()
		return TRUE

	to_chat(src, SPAN_WARNING("You overshoot your target!"))
	playsound(src, 'sound/weapons/punchmiss.ogg', 75, 1)
	var/dir_to_go = get_dir(starting_turf, destination)
	for (var/i = 1 to rand(2, 4))
		destination = get_step(destination, dir_to_go)

	handle_tunnel(destination)
	set_AI_busy(FALSE)
	emerge()
	return FALSE

/mob/living/simple_animal/hostile/digger/proc/handle_tunnel(turf/destination)
	var/turf/T = get_turf(src)

	for (var/i = 1 to get_dist(src, destination))
		if (stat)
			return FALSE
		if (loc == destination)
			break

		T = get_step(src, get_dir(src, destination))
		if (T.density)
			to_chat(src, "<span class='critical'>You hit something really solid!</span>")
			playsound(src, "punch", 75, 1)
			Weaken(5)
			return FALSE

		for (var/mob/living/L in T)
			playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
			L.Weaken(2)

		forceMove(T)

		dig_under_floor(get_turf(src))
		playsound(src, 'sound/effects/break_stone.ogg', 75, 1)
		sleep(tunnel_tile_speed)

/mob/living/simple_animal/hostile/digger/proc/submerge()
	alpha = 0
	dig_under_floor(get_turf(src))
	new /obj/temporary/tunneler_hole(get_turf(src), 1 MINUTE)

/mob/living/simple_animal/hostile/digger/proc/emerge()
	alpha = 255
	dig_under_floor(get_turf(src))
	new /obj/temporary/tunneler_hole(get_turf(src), 1 MINUTE)

/mob/living/simple_animal/hostile/digger/proc/dig_under_floor(turf/T)
	new /obj/item/ore/glass(T)

//ВОЛКОЛАК

/mob/living/simple_animal/hostile/harron
	name = "wolfdog"
	desc = "A fast, lightweighted predator accustomed to hiding and ambushing in cold terrain. Rare example of technologies and naure working together."
	icon = 'mods/_fd/fd_assets/icons/animals/adhomai.dmi'
	faction = "cyber_harron"
	icon_state = "cyber_harron"
	icon_living = "cyber_harron"
	icon_dead = "cyber_harron_dead"
	maxHealth = 80
	health = 80
	speed = 2
	mob_bump_flag = HUMAN
	mob_push_flags = ~HEAVY
	mob_swap_flags = ~HEAVY
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_MEDIUM
	natural_weapon = /obj/item/natural_weapon/bite/strong
	cold_damage_per_tick = 0

	say_list_type = /datum/say_list/smart/harron

	var/cloaked_alpha = 45
	var/cloaked_bonus_damage = 30
	var/cloaked_weaken_amount = 3
	var/cloak_cooldown = 10 SECONDS
	var/last_uncloak = 0
	var/cloaked = FALSE

/mob/living/simple_animal/hostile/harron/proc/cloak()
	if (is_cloaked())
		return
	animate(src, alpha = cloaked_alpha, time = 1 SECOND)
	cloaked = TRUE

/mob/living/simple_animal/hostile/harron/proc/uncloak()
	last_uncloak = world.time
	if (!is_cloaked())
		return
	animate(src, alpha = initial(alpha), time = 1 SECOND)
	cloaked = FALSE

/mob/living/simple_animal/hostile/harron/proc/can_cloak()
	if (stat)
		return FALSE
	if (last_uncloak + cloak_cooldown > world.time)
		return FALSE

	return TRUE

/mob/living/simple_animal/hostile/harron/proc/break_cloak()
	uncloak()


/mob/living/simple_animal/hostile/harron/is_cloaked()
	return cloaked

/mob/living/simple_animal/hostile/harron/handle_special()
	if (!is_cloaked() && can_cloak())
		cloak()

/mob/living/simple_animal/hostile/harron/apply_bonus_melee_damage(atom/A, damage_amount)
	if (is_cloaked())
		return damage_amount + cloaked_bonus_damage
	return ..()

/mob/living/simple_animal/hostile/harron/apply_melee_effects(atom/A)
	if (is_cloaked() && isliving(A))
		var/mob/living/L = A
		L.Weaken(cloaked_weaken_amount)
		to_chat(L, SPAN_DANGER("\The [src] ambushes you!"))
		playsound(src, 'sound/weapons/spiderlunge.ogg', 75, 1)
	uncloak()
	..()

/mob/living/simple_animal/hostile/harron/bullet_act(obj/item/projectile/P)
	. = ..()
	break_cloak()

/mob/living/simple_animal/hostile/harron/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	break_cloak()


//ОЛЕНЬ

/mob/living/simple_animal/hostile/rafama
	name = "rafama"
	desc = "A vaguely canine looking beast. It looks as though its fur is made of stone wool."
	icon = 'mods/_fd/fd_assets/icons/animals/adhomai.dmi'
	gender = MALE
	faction = "rafama_m"
	icon_state = "rafama_m"
	icon_living = "rafama_m"
	icon_dead = "rafama_m_dead"
	maxHealth = 200
	health = 200
	speed = 2
	mob_size = MOB_LARGE
	mob_bump_flag = HUMAN
	mob_push_flags = ~HEAVY
	mob_swap_flags = ~HEAVY
	natural_weapon = /obj/item/natural_weapon/claws
	cold_damage_per_tick = 0

	say_list_type = /datum/say_list/smart/rafama

	special_attack_min_range = 3
	special_attack_max_range = 7
	special_attack_cooldown = 15 SECONDS

	var/leap_warmup = 2 SECOND
	var/leap_sound = 'sound/weapons/spiderlunge.ogg'

/mob/living/simple_animal/hostile/rafama/Initialize()
	gender = pick(MALE,FEMALE)
	if(gender == MALE)
		desc = "A vaguely canine looking beast. It looks as though its fur is made of stone wool. This one is probably male."
	if(gender == FEMALE)
		desc = "A vaguely canine looking beast. It looks as though its fur is made of stone wool. This one is probably female."
		icon_state = "rafama_f"
		icon_living = "rafama_f"
		icon_dead = "rafama_f_dead"
		special_attack_cooldown = 999 SECONDS //да-да, костыли

	. = ..()

/mob/living/simple_animal/hostile/rafama/do_special_attack(atom/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)

	do_windup_animation(A, leap_warmup)
	sleep(leap_warmup)

	status_flags |= LEAPING
	visible_message(SPAN_DANGER("\The [src] leaps at \the [A]!"))
	throw_at(get_step(get_turf(A), get_turf(src)), special_attack_max_range+1, 1, src)
	playsound(src, leap_sound, 75, 1)

	sleep(5)

	if(status_flags & LEAPING)
		status_flags &= ~LEAPING

	var/turf/T = get_turf(src)

	. = FALSE

	var/mob/living/victim = null
	for(var/mob/living/L in T)
		if(L == src)
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.check_shields(damage = 0, damage_source = src, attacker = src, def_zone = null, attack_text = "the leap"))
				continue

		victim = L
		break

	if(victim)
		victim.Weaken(2)
		victim.visible_message(SPAN_DANGER("\The [src] knocks down \the [victim]!"))
		to_chat(victim, "<span class='critical'>\The [src] jumps on you!</span>")
		. = TRUE

	set_AI_busy(FALSE)
