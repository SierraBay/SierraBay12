/mob/living/simple_animal/hostile/bluespace
	name = "bluespace figment"
	desc = "A fragmented spectre from another dimension."
	icon = 'icons/mob/simple_animal/bluespace.dmi'
	icon_state = "figment"
	icon_living = "figment"
	icon_dead = "figment_dead"
	faction = "bluespace"
	speak_emote = list("echoes")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	maxHealth = 65
	health = 65
	ai_holder = /datum/ai_holder/simple_animal/melee/bluespace
	say_list_type = /datum/say_list/bluespace
	natural_weapon = /obj/item/natural_weapon/bluespace
	light_color = "#4da6ff"
	light_range = 2
	light_power = 1
	bleed_colour = "#0000ff"

/mob/living/simple_animal/hostile/bluespace/Process_Spacemove(allow_movement)
	return TRUE

/obj/item/natural_weapon/bluespace
	name = "fractal touch"
	attack_verb = list("slashed", "phased through", "drained")
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 10
	sharp = TRUE
	edge = TRUE

/mob/living/simple_animal/hostile/bluespace/death()
	..(null, "fizzles into nothingness.")
	playsound(src.loc, 'sound/magic/summon_carp.ogg', 50, 1)
	qdel(src)
	return

/datum/ai_holder/simple_animal/melee/bluespace
	speak_chance = 15
	wander = TRUE

/datum/say_list/bluespace
	speak = list(
		"Help me... Somebody...",
		"Is - is someone there...?",
		"It's so cold...",
		"I - I can't get warm...",
		"Where is everyone? Why does everything hurt!?")
	emote_hear = list("wails","screeches", "cries", "lets out an agonized scream")
	emote_see = list("warps in and out of reality", "flickers", "stops suddenly", "twitches unaturally")

//passive variant
/mob/living/simple_animal/hostile/bluespace/neutral
	ai_holder = /datum/ai_holder/simple_animal/passive/bluespace
	density = FALSE

/datum/ai_holder/simple_animal/passive/bluespace
	speak_chance = 5
	wander = TRUE

/**
 * # Bluespace Doppelganger
 *
 * A hostile echo-clone created when the bluespace drive's rift pulls a crewmember into the
 * interlude. It wears the victim's appearance and attacks nearby crew until the BSD's rift
 * closes or it is destroyed.
 *
 * Spawned by /obj/machinery/bluespace_drive/proc/pull_player_into_rift().
 */
/mob/living/simple_animal/hostile/bluespace/doppelganger
	name = "bluespace echo"
	desc = "A perfect copy torn from the bluespace rift. Its eyes are wrong."
	maxHealth = 75
	health = 75
	light_color = "#6688ff"
	light_range = 3
	light_power = 1.2
	say_list_type = /datum/say_list/bluespace/doppelganger


/mob/living/simple_animal/hostile/bluespace/doppelganger/death()
	..(null, "dissolves into bluespace static.")
	playsound(src.loc, 'sound/magic/summon_carp.ogg', 50, 1)
	qdel(src)
	return

/datum/say_list/bluespace/doppelganger
	speak = list(
		"Я настоящий...",
		"Тебе не следовало возвращаться...",
		"Держись подальше от привода!",
		"Это тело теперь моё.")
	emote_hear = list("издаёт искажённый крик", "сильно мерцает", "глючит")
	emote_see = list("временно выходит из существования", "смотрит пустыми глазами", "неестественно дергается")
