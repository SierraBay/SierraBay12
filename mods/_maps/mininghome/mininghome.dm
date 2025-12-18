/datum/map_template/ruin/away_site/mininghome
	prefix = "mods/_maps/mininghome/"
	suffixes = list("mininghome.dmm")

/mob/living/simple_animal/hostile/sand_lurker
	name = "cosmopterid"
	desc = "Huge segmented creature with sharp fearsome claws. It's almost perfectly disguises itself in sand. Isn't it an arthropod-like incarnation of paranoia itself?"
	icon = 'mods/_maps/mininghome/sand_lurker.dmi'
	icon_state = "sand_lurker_sand"
	icon_living = "sand_lurker_sand"
	icon_dead = "sand_lurker_dead_sand"
	icon_gib = "sand_lurker_dead_sand"
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	maxHealth = 50
	health = 50
	movement_cooldown = 2
	natural_weapon = /obj/item/natural_weapon/bite
	min_gas = null
	max_gas = null
	minbodytemp = 0
