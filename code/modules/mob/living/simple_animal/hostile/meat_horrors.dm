/mob/living/simple_animal/hostile/meat
	name = "horror"
	desc = "A monstrously huge wall of flesh, it looks like you took who knows how many humans and put them together..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 250
	health = 250
	movement_cooldown = 7
	natural_weapon = /obj/item/natural_weapon/meatbits
	heat_damage_per_tick = 20
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 4 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

	ai_holder = /datum/ai_holder/simple_animal/melee/meat
	say_list = /datum/say_list/meat

/obj/item/natural_weapon/meatbits
	force = 30
	sharp = TRUE
	edge = TRUE
	attack_cooldown = 1.5 SECONDS
	attack_verb = list("mauled", "slashed")

/mob/living/simple_animal/hostile/meat/abomination
	name = "abomination"
	desc = "A monstrously huge wall of flesh, it looks like you took who knows how many humans and put them together..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "abomination"
	icon_living = "abomination"
	icon_dead = "abomination_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 250
	health = 250
	movement_cooldown = 8
	natural_weapon = /obj/item/natural_weapon/meatbits
	heat_damage_per_tick = 20
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 4 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

/mob/living/simple_animal/hostile/meat/horror
	name = "horror"
	desc = "A monstrously huge wall of flesh, it looks like you took two humans and put them together..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 150
	health = 150
	natural_weapon = /obj/item/natural_weapon/claws
	heat_damage_per_tick = 100
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 8 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

/mob/living/simple_animal/hostile/meat/strippedhuman
	name = "turned human"
	desc = "What's left of a human. Their body's chest cavity is ripped open, their organs spilling out. It twitches, ready for it's next victim..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "horror_alt"
	icon_living = "horror_alt"
	icon_dead = "horror_alt_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 100
	health = 100
	movement_cooldown = 5
	natural_weapon = /obj/item/natural_weapon/claws/weak
	heat_damage_per_tick = 100
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 8 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

	say_list = /datum/say_list/meat/human

/mob/living/simple_animal/hostile/meat/humansecurity
	name = "turned security"
	desc = "What's left of a SAARE security guard. The only way you can tell is by the tatters of their uniform. That armor they wore in life now gives them a bit of hardiness in death..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "horror_security"
	icon_living = "horror_security"
	icon_dead = "horror_security_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 200
	health = 200
	movement_cooldown = 5
	natural_weapon = /obj/item/natural_weapon/claws
	heat_damage_per_tick = 100
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 8 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

/mob/living/simple_animal/hostile/meat/horrorminer
	name = "turned miner"
	desc = "What's left of a miner. Their head is hanging off the back by a few scraps of fabric."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "horror_miner"
	icon_living = "horror_miner"
	icon_dead = "horror_miner_dead"
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 150
	health = 150
	movement_cooldown = 5
	natural_weapon = /obj/item/natural_weapon/claws
	heat_damage_per_tick = 100
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 8 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

/mob/living/simple_animal/hostile/meat/horrorsmall
	name = "smaller horror"
	desc = "A creature with more legs than it could possibly need. It has multiple sets of eyes, though they're all human..."
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	icon_state = "lesser_ling"
	icon_living = "lesser_ling"
	icon_dead = ""
	speak_emote = list("twitches.")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 50
	health = 50
	movement_cooldown = 2
	natural_weapon = /obj/item/natural_weapon/claws
	heat_damage_per_tick = 100
	cold_damage_per_tick = 0
	faction = "meat"
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 3
	speed = 0.5
	bleed_colour = "#5c0606"
	break_stuff_probability = 25
	pry_time = 8 SECONDS
	pry_desc = "clawing"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	natural_armor = list(
		melee = ARMOR_MELEE_KNIVES
		)

/datum/ai_holder/simple_animal/melee/meat
	speak_chance = 5

/datum/say_list/meat
	emote_hear = list("roars!", "groans..")
	emote_see = list("snaps it's head at something..", "twitches", "stops suddenly")

/datum/say_list/meat/human
	emote_hear = list("roars!", "groans...")
	emote_see = list("turns to the sound..", "twitches", "stops suddenly", "stops suddenly, it's intestines slowly spilling out")



//meat station mobs
//mobs

/mob/living/simple_animal/hostile/meatstation
	name = "meatstation mob"
	desc = "it's meaty!"
	icon = 'maps/away/meatstation/meatstation_sprites.dmi'
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "stomps"
	flash_vulnerability = 0 //eyeless
	turns_per_move = 5
	natural_weapon = /obj/item/natural_weapon/bite/weak
	faction = "meat"
	min_gas = null
	minbodytemp = 0
	meat_type = /obj/item/reagent_containers/food/snacks/meat/meatstationmeat
	meat_amount = 1
	can_escape = TRUE

	ai_holder = /datum/ai_holder/simple_animal/melee/meatstation

/mob/living/simple_animal/hostile/meatstation/meatworm
	name = "flesh worm"
	desc = "A toothy little thing. It won't stop gnashing and thrashing!"
	icon_state = "meatworm"
	icon_living = "meatworm"
	icon_dead = "meatworm_dead"
	turns_per_move = 3
	speed = -2
	maxHealth = 20
	health = 20
	natural_weapon = /obj/item/natural_weapon/bite/weak
	mob_size = MOB_SMALL
	meat_amount = 2
	can_escape = FALSE

	say_list_type = /datum/say_list/meatstation/meatworm

/mob/living/simple_animal/hostile/meatstation/meatball
	name = "animated meat"
	desc = "A crude creature of meat and teeth."
	icon_state = "meatball"
	icon_living = "meatball"
	icon_dead = "meatball_dead"
	speed = 2
	maxHealth = 50
	health = 50
	natural_weapon = /obj/item/natural_weapon/meatball
	meat_amount = 2
	can_escape = FALSE

	say_list_type = /datum/say_list/meatstation/meatball

/obj/item/natural_weapon/meatball
	force = 12
	attack_verb = list("thwacked")

/mob/living/simple_animal/hostile/meatstation/wormscientist
	name = "infested scientist"
	desc = "A scientist infested with some sort of parasitic worms."
	icon_state = "wormscientist"
	icon_living = "wormscientist"
	icon_dead = "wormscientist_dead"
	speed = 7
	maxHealth = 90
	health = 90
	natural_weapon = /obj/item/natural_weapon/wormscience
	meat_amount = 3

	say_list_type = /datum/say_list/meatstation/meat_human

/obj/item/natural_weapon/wormscience
	force = 15
	attack_verb = list("whacked")

/mob/living/simple_animal/hostile/meatstation/wormguard
	name = "infested guard"
	desc = "An armed guard infested with some sort of parasitic worms. It looks like their hands have melded with their weapon."
	icon_state = "wormguard"
	icon_living = "wormguard"
	icon_dead = "wormguard_dead"
	speed = 7
	maxHealth = 60
	health = 60
	natural_weapon = /obj/item/natural_weapon/wormguard
	meat_amount = 3
	projectilesound = 'sound/weapons/Laser.ogg'
	ranged = 1
	projectiletype = /obj/item/projectile/beam/smalllaser

	say_list_type = /datum/say_list/meatstation/meat_human
/obj/item/natural_weapon/wormguard
	force = 17
	attack_verb = list("slammed")

/mob/living/simple_animal/hostile/meatstation/meatmound
	name = "meat horror"
	desc = "A gnashing mound of flesh and teeth."
	icon_state = "meatmound"
	icon_living = "meatmound"
	icon_dead = "meatmound_dead"
	flash_vulnerability = 1
	speed = 10
	maxHealth = 160
	health = 160
	natural_weapon = /obj/item/natural_weapon/meatmound
	meat_amount = 4
	mob_size = MOB_LARGE

	say_list_type = /datum/say_list/meatstation/meatmound
