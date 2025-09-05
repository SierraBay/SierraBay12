/mob/living/simple_animal/hostile/electra_wolf
	name = "shantak"
	desc = "A piglike creature with a bright iridiscent mane that sparkles as though lit by an inner light. Don't be fooled by its beauty though."
	faction = "shantak"
	icon = 'icons/mob/simple_animal/animal.dmi'
	icon_state = "shantak"
	icon_living = "shantak"
	icon_dead = "shantak_dead"
	move_to_delay = 1
	maxHealth = 75
	health = 75
	speed = 1
	natural_weapon = /obj/item/natural_weapon/claws
	cold_damage_per_tick = 0

	ai_holder = /datum/ai_holder/simple_animal/shantak/electra_wolf
	say_list_type = /datum/say_list/shantak

/datum/ai_holder/simple_animal/shantak/electra_wolf
	hostile = TRUE
