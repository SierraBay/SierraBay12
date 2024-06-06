//quality code theft -- Remap, GTC - Grand Theft Code
/obj/overmap/visitable/sector/arcticplanet
	name = "arctic planetoid"
	desc = "Sensor array detects an arctic planet with a small vessle on the planet's surface. Scans further indicate strange energy levels below the planet's surface."
	sector_flags = OVERMAP_SECTOR_KNOWN
	icon_state = "hoxxes"
	initial_generic_waypoints = list(
		"nav_blueriv_1",
		"nav_blueriv_2",
		"nav_blueriv_3",
		"nav_blueriv_antag"
	)

/obj/overmap/visitable/sector/arcticplanet/New(nloc, max_x, max_y)
	name = "[generate_planet_name()], \a [name]"
	..()

/datum/map_template/ruin/away_site/blueriver
	name = "Bluespace River"
	id = "awaysite_blue"
	spawn_cost = 2
	description = "Two z-level map with an arctic planet and an alien underground surface"
	prefix = "mods/_fd/_maps/blueriver/maps/"
	suffixes = list("blueriver-1.dmm", "blueriver-2.dmm")
	generate_mining_by_z = list(1,2)
	area_usage_test_exempted_root_areas = list(/area/map_template/bluespaceriver)
	apc_test_exempt_areas = list(
		/area/map_template/bluespaceriver/underground = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/map_template/bluespaceriver/surface = NO_SCRUBBER|NO_VENT|NO_APC
	)
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/horizon)

//This is ported from /vg/ and isn't entirely functional. If it sees a threat, it moves towards it, and then activates it's animation.
//At that point while it sees threats, it will remain in it's attack stage. It's a bug, but I figured it nerfs it enough to not be impossible to deal with
/mob/living/simple_animal/hostile/hive_alien/defender
	name = "hive defender"
	desc = "A terrifying monster resembling a massive, bloated tick in shape. Hundreds of blades are hidden underneath its rough shell."
	icon = 'maps/away/blueriver/blueriver.dmi'
	icon_state = "hive_executioner_move"
	icon_living = "hive_executioner_move"
	icon_dead = "hive_executioner_dead"
	move_to_delay = 5
	speed = -1
	health = 280
	maxHealth = 280
	can_escape = TRUE

	harm_intent_damage = 8
	natural_weapon = /obj/item/natural_weapon/defender_blades
	ai_holder = /datum/ai_holder/simple_animal/melee/defender
	var/attack_mode = FALSE

	var/transformation_delay_min = 4
	var/transformation_delay_max = 8

/datum/ai_holder/simple_animal/melee/defender/lose_target()
	. = ..()
	var/mob/living/simple_animal/hostile/hive_alien/defender/D = holder
	if(D.attack_mode && !find_target()) //If we don't immediately find another target, switch to movement mode
		D.mode_movement()

	return ..()

/datum/ai_holder/simple_animal/melee/defender/lose_target()
	. = ..()
	var/mob/living/simple_animal/hostile/hive_alien/defender/D = holder
	if(D.attack_mode && !find_target()) //If we don't immediately find another target, switch to movement mode
		D.mode_movement()

	return ..()

/datum/ai_holder/simple_animal/melee/defender/engage_target()
	. = ..()
	var/mob/living/simple_animal/hostile/hive_alien/defender/D = holder
	if(!D.attack_mode)
		return D.mode_attack()

	flick("hive_executioner_attacking", src)

	return ..()
/obj/item/natural_weapon/defender_blades
	name = "blades"
	attack_verb = list("eviscerated")
	force = 30
	edge = TRUE
	hitsound = 'sound/weapons/slash.ogg'

/mob/living/simple_animal/hostile/hive_alien/defender/proc/mode_movement() //Slightly broken, but it's alien and unpredictable so w/e
	set waitfor = 0
	icon_state = "hive_executioner_move"
	flick("hive_executioner_movemode", src)
	sleep(rand(transformation_delay_min, transformation_delay_max))
	anchored = FALSE
	speed = -1
	move_to_delay = 8
	. = FALSE

	//Immediately find a target so that we're not useless for 1 Life() tick!
	ai_holder.find_target()

/mob/living/simple_animal/hostile/hive_alien/defender/proc/mode_attack()
	set waitfor = 0
	icon_state = "hive_executioner_attack"
	flick("hive_executioner_attackmode", src)
	sleep(rand(transformation_delay_min, transformation_delay_max))
	anchored = TRUE
	speed = 0
	attack_mode = TRUE
	walk(src, 0)

/mob/living/simple_animal/hostile/hive_alien/defender/wounded
	name = "wounded hive defender"
	health = 80
	can_escape = FALSE

/obj/shuttle_landmark/nav_blueriv/nav1
	name = "Arctic Planet Landing Point #1"
	landmark_tag = "nav_blueriv_1"
	base_area = /area/map_template/bluespaceriver/surface
	base_turf = /turf/simulated/floor/exoplanet/snow

/obj/shuttle_landmark/nav_blueriv/nav2
	name = "Arctic Planet Landing Point #2"
	landmark_tag = "nav_blueriv_2"
	base_area = /area/map_template/bluespaceriver/surface
	base_turf = /turf/simulated/floor/exoplanet/snow

/obj/shuttle_landmark/nav_blueriv/nav3
	name = "Arctic Planet Landing Point #3"
	landmark_tag = "nav_blueriv_3"
	base_area = /area/map_template/bluespaceriver/surface
	base_turf = /turf/simulated/floor/exoplanet/snow

/obj/shuttle_landmark/nav_blueriv/nav4
	name = "Arctic Planet Navpoint #4"
	landmark_tag = "nav_blueriv_antag"
	base_area = /area/map_template/bluespaceriver/surface
	base_turf = /turf/simulated/floor/exoplanet/snow

/turf/simulated/floor/away/blueriver/alienfloor
	name = "glowing floor"
	desc = "The floor glows without any apparent reason."
	icon = 'maps/away/blueriver/riverturfs.dmi'
	icon_state = "floor"
	temperature = 233

/turf/simulated/floor/away/blueriver/alienfloor/Initialize()
	.=..()

	set_light(0.7, 1, 5, l_color = "#0066ff")

/turf/unsimulated/wall/away/blueriver/livingwall
	name = "alien wall"
	desc = "You feel a sense of dread from just looking at this wall. Its surface seems to be constantly moving, as if it were breathing."
	icon = 'maps/away/blueriver/riverturfs.dmi'
	icon_state = "evilwall_1"
	opacity = 1
	density = TRUE
	temperature = 233

/turf/unsimulated/wall/away/blueriver/livingwall/Initialize()
	.=..()

	if(prob(80))
		icon_state = "evilwall_[rand(1,8)]"

/turf/unsimulated/wall/supermatter/no_spread
	name = "weird liquid"
	desc = "The viscous liquid glows and moves as if it were alive."
	icon='maps/away/blueriver/blueriver.dmi'
	icon_state = "bluespacecrystal1"
	layer = SUPERMATTER_WALL_LAYER
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	opacity = 0
	dynamic_lighting = 0

/turf/unsimulated/wall/supermatter/no_spread/Initialize()
	.=..()

	icon_state = "bluespacecrystal[rand(1,3)]"
	set_light(0.7, 1, 5, l_color = "#0066ff")

/turf/unsimulated/wall/supermatter/no_spread/Process()
	return PROCESS_KILL

/obj/structure/deity
	icon = 'icons/obj/cult.dmi'
	icon_state = "tomealtar"
	health_max = 10
	density = TRUE
	anchored = TRUE

/obj/structure/deity/use_tool(obj/item/W as obj, mob/user as mob)
	SHOULD_CALL_PARENT(FALSE)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(src)
	playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 50, 1)
	user.visible_message(
		"<span class='danger'>[user] hits \the [src] with \the [W]!</span>",
		"<span class='danger'>You hit \the [src] with \the [W]!</span>",
		"<span class='danger'>You hear something breaking!</span>"
		)
	damage_health(W.force, W.damtype)

/obj/structure/deity/on_death()
	visible_message(SPAN_DANGER("\The [src] crumbles!"))
	qdel(src)

/obj/structure/deity/bullet_act(obj/item/projectile/P)
	damage_health(P.get_structure_damage(), P.damage_type)

/obj/item/book/random //just empty books for design
	name = "book"
	icon_state ="book"

/obj/item/book/random/New()
	name = "[pick("old", "ancient", "strange", "normal", "note", "fancy", "memoirs")] book"
	icon_state = pick("book", "book1", "book2", "book3", "book4", "book5", "book6", "book7")
	..()


/obj/machinery/computer/shuttle_control/explore/horizon //HORIZON
	name = "Horizon control console"
	req_access = list()
	shuttle_tag = "Horizon"

/obj/overmap/visitable/ship/landable/horizon
	name = "EV - Horizon"
	shuttle = "Horizon"
	fore_dir = NORTH
	dir = NORTH
	color = "#a131ce"
	alpha = 240
	vessel_mass = 950
	vessel_size = SHIP_SIZE_TINY

/datum/shuttle/autodock/overmap/horizon
	name = "Horizon"
	warmup_time = 10
	current_location = "nav_horizon"
	range = 0
	fuel_consumption = 0.5
	shuttle_area = /area/map_template/bluespaceriver/horizon
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_BASIC
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/torch

/obj/shuttle_landmark/horizon
	name = "Horizon LZ"
	landmark_tag = "nav_horizon"
	base_area = /area/map_template/bluespaceriver/surface
	base_turf = /turf/simulated/floor/exoplanet/snow
	movable_flags = MOVABLE_FLAG_EFFECTMOVE
