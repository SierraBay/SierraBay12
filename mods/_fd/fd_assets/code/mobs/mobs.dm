/mob/living/simple_animal/fd/wendigo
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/wendigobig_-_Copy.dmi'
	icon_state = "wendigo_noblood"
	maxHealth = 5000
	health = 5000
	pixel_x = -15

/mob/living/simple_animal/fd/observer
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/SCPCommissionPackage.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "scp-specimen8"

/mob/living/simple_animal/fd/robot
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/posthuman.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "android_sp"

/mob/living/simple_animal/fd/robot2
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/lobotomy/32x48.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "green_bot"

/mob/living/simple_animal/fd/robot3
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/lobotomy/32x48.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "indigo_dawn"

/mob/living/simple_animal/fd/creature
	name = "???"
	desc = "???"
	icon = 'mods/_fd/fd_assets/icons/animals/lobotomy/32x48.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "fragment_breach"

/mob/living/simple_animal/fd/mnogonojka
	name = "???"
	desc = "???"
	icon = 'icons/mob/simple_animal/nightmaremonsters.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "lesser_ling"

/mob/living/simple_animal/hostile/alien_facehugger
	name = "???"
	desc = "What is this thing even?..."
	icon = 'mods/_fd/fd_assets/icons/animals/facehugger.dmi'
	maxHealth = 500
	health = 500
	icon_state = "facehugger"
	item_state = "facehugger"
	icon_living = "facehugger"
	icon_dead = "facehugger_dead"
	pass_flags = PASS_FLAG_TABLE
	see_in_dark = 10
	density = FALSE
	universal_speak = FALSE
	universal_understand = TRUE

	mob_size = MOB_MINISCULE
	can_escape = TRUE
	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_NONE

	min_gas = null
	max_gas = null
	minbodytemp = 0
	movement_cooldown = 1
	move_to_delay = -1
	speed = -1

	heat_damage_per_tick = 50
	cold_damage_per_tick = 0

	bleed_colour = "#7dda5a"

/mob/living/simple_animal/hostile/alien_facehugger/New()
	..()

	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

/mob/living/simple_animal/hostile/alien_ravager
	name = "???"
	desc = "JUST RUN!"
	icon = 'mods/_fd/fd_assets/icons/animals/ravager.dmi'
	maxHealth = 5000
	health = 5000
	icon_state = "ravager"
	item_state = "ravager"
	icon_living = "ravager"
	icon_dead = "ravager_dead"
	pass_flags = PASS_FLAG_TABLE
	see_in_dark = 10
	universal_speak = FALSE
	universal_understand = TRUE

	can_pull_size = ITEM_SIZE_NORMAL
	can_pull_mobs = MOB_PULL_LARGER

	natural_weapon = /obj/item/natural_weapon/giant/lunge

	min_gas = null
	max_gas = null
	minbodytemp = 0
	movement_cooldown = 2
	move_to_delay = 1
	speed = 1
	pry_time = 5 SECONDS
	pry_desc = "clawing"

	heat_damage_per_tick = 100
	cold_damage_per_tick = 0

	skin_material = MATERIAL_SKIN_CHITIN
	bleed_colour = "#7dda5a"

/obj/item/natural_weapon/giant/lunge
	lunge_dist = 6

/mob/living/simple_animal/hostile/alien_ravager/New()
	..()

	verbs += /mob/living/proc/ventcrawl

/obj/decal/cleanable/acid
	name = "acid"
	desc = "Do NOT touch it."
	gender = PLURAL
	icon = 'mods/_fd/fd_assets/icons/Effects.dmi'
	icon_state = "acid2-weak"
	mouse_opacity = 0
	persistent = FALSE

/obj/structure/fd/alien_egg
	name = "strange egg"
	desc = "strange shaped egg"
	icon = 'mods/_fd/fd_assets/icons/Effects.dmi'
	icon_state = "opened"
	anchored = TRUE

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'mods/_fd/fd_assets/icons/Effects.dmi'
	icon_state = "nest"
	base_icon = "nest"

/obj/structure/bed/nest/New(newloc)
	base_icon = icon_state
	..(newloc,MATERIAL_LEATHER_GENERIC)
