///Premade Viruses
/datum/disease2/disease/cold
	infectionchance = 50
	speed = 1
	spreadtype = "Airborne"
	max_stage = 3


/datum/disease2/disease/cold/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	effects += E1
	E1.multiplier = rand(1,E1.multiplier_max)
	var/datum/disease2/effect/fridge/E2 = new()
	E2.stage = 2
	effects += E2
	E2.multiplier = rand(1,E2.multiplier_max)
	var/datum/disease2/effect/shakey/E3 = new()
	E3.stage = 3
	effects += E3
	E3.multiplier = rand(1,E3.multiplier_max)

/datum/disease2/disease/spider
	infectionchance = 60
	speed = 5
	spreadtype = "Contact"
	max_stage = 3
	affected_species = list(HUMAN_SPECIES,SPECIES_UNATHI,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_TRITONIAN,SPECIES_RESOMI,SPECIES_NABBER,SPECIES_MONKEY)

/datum/disease2/disease/spider/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	infectionchance = rand(10,50)
	var/datum/disease2/effect/headache/E1 = new()
	E1.chance = 2
	E1.stage = 1
	effects += E1
	E1.multiplier = rand(1,E1.multiplier_max)
	var/datum/disease2/effect/blind/E2 = new()
	E2.chance = 2
	E2.stage = 2
	effects += E2
	E2.multiplier = rand(1,E2.multiplier_max)
	var/datum/disease2/effect/confusion/E3 = new()
	E3.stage = 3
	E3.chance = 2
	effects += E3
	E3.multiplier = rand(1,E3.multiplier_max)
	var/datum/disease2/effect/spiderfication/E4 = new()
	E4.stage = 4
	E4.chance = 2
	effects += E4
	E4.multiplier = rand(1,E4.multiplier_max)



/mob/living/simple_animal/hostile/giant_spider
	var/datum/disease2/disease/spider/spider = new()


/mob/living/simple_animal/hostile/giant_spider/Destroy()
	. = ..()
	QDEL_NULL(spider)

/mob/living/simple_animal/hostile/giant_spider/apply_melee_effects(mob/living/carbon/human/M)
	. = ..()
	if(Adjacent(M))//if it's human who can be infected standing nearby
		if (prob(3))
			infect_virus2(M, spider, 0)


/datum/disease2/disease/livingmeat

	infectionchance = 70
	speed = 3
	spreadtype = "Contact"
	max_stage = 3
	affected_species = list(HUMAN_SPECIES,SPECIES_UNATHI,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_TRITONIAN,SPECIES_RESOMI,SPECIES_NABBER,SPECIES_MONKEY)

/mob/living/simple_animal/hostile/meatstation
	var/datum/disease2/disease/livingmeat/livingmeat = new()

/mob/living/simple_animal/hostile/meatstation/Destroy()
	. = ..()
	QDEL_NULL(livingmeat)

/mob/living/simple_animal/hostile/meatstation/apply_melee_effects(mob/living/carbon/human/M)
	. = ..()
	if(Adjacent(M))//if it's human who can be infected standing nearby
		if (prob(10))
			infect_virus2(M, livingmeat, 0)

/datum/disease2/disease/livingmeat/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	infectionchance = rand(10,50)
	var/datum/disease2/effect/stomach/E1 = new()
	E1.stage = 1
	E1.chance = 2
	effects += E1
	E1.multiplier = rand(1,E1.multiplier_max)
	var/datum/disease2/effect/hungry/E2 = new()
	E2.stage = 2
	E2.chance = 2
	effects += E2
	E2.multiplier = rand(1,E2.multiplier_max)
	var/datum/disease2/effect/mutation/E3 = new()
	E3.stage = 3
	E3.chance = 2
	effects += E3
	E3.multiplier = rand(1,E3.multiplier_max)
	var/datum/disease2/effect/gibbingtons/E4 = new()
	E4.stage = 4
	E4.chance = 2
	effects += E4
	E4.multiplier = rand(1,E4.multiplier_max)




/datum/disease2/disease/zombie

	infectionchance = 80
	speed = 6
	spreadtype = "Contact"
	max_stage = 4
	affected_species = list(HUMAN_SPECIES,SPECIES_UNATHI,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_TRITONIAN,SPECIES_RESOMI,SPECIES_MONKEY)


/datum/disease2/disease/zombie/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	infectionchance = rand(50,100)
	var/datum/disease2/effect/gunck/E1 = new()
	E1.stage = 1
	E1.chance = 2
	effects += E1
	E1.multiplier = rand(1,E1.multiplier_max)
	var/datum/disease2/effect/hungry/E2 = new()
	E2.stage = 2
	E2.chance = 2
	effects += E2
	E2.multiplier = rand(1,E2.multiplier_max)
	var/datum/disease2/effect/mind/E3 = new()
	E3.stage = 3
	E3.chance = 2
	effects += E3
	E3.multiplier = rand(1,E3.multiplier_max)
	var/datum/disease2/effect/zombie/E4 = new()
	E4.stage = 4
	E4.chance = 2
	effects += E4
	E4.multiplier = rand(1,E4.multiplier_max)


////////ЕСЛИ ЗАХОТИМ НА ДЕРЕЛИКТ ДЕЛАТЬ СИМПЛМОБОВ ЗАРАЖЕННЫХ ВИРУСОМ ЗОМБЕЙ, ТО СЮДА ПРОПИСЫВАЕМ ИХ, САМ ПРЕМЕЙД ЕСТЬ ВЫШЕ/////

/// ПРЯМ СЮДА 	^
//				|

/mob/living/carbon/human/zombify()
	if (!(species.name in GLOB.zombie_species) || is_species(SPECIES_DIONA) || is_zombie() || isSynthetic())
		return

	adjustHalLoss(100)
	adjustBruteLoss(50)
	make_jittery(300)

	var/turf/T = get_turf(src)
	new /obj/decal/cleanable/vomit(T)
	playsound(T, 'sound/effects/splat.ogg', 20, 1)

	var/obj/item/held_l = get_equipped_item(slot_l_hand)
	var/obj/item/held_r = get_equipped_item(slot_r_hand)
	if(held_l)
		drop_from_inventory(held_l)
	if(held_r)
		drop_from_inventory(held_r)
	if(prob(70))
		addtimer(new Callback(src, PROC_REF(transform_zombie)), 20)
	else
		addtimer(new Callback(src, PROC_REF(transform_zombie_smart)), 20)


/singleton/species/zombie/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	natural_armour_values = list(
		melee = ARMOR_MELEE_KNIVES,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	species_flags += SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED
