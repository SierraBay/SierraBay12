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
	speed = 8
	spreadtype = DISEASE_SPREAD_BLOOD
	max_stage = 4
	affected_species = list(HUMAN_SPECIES,SPECIES_TAJARA,SPECIES_RESOMI,SPECIES_MONKEY,SPECIES_SPACER,SPECIES_GRAVWORLDER,SPECIES_VATGROWN,SPECIES_VOX,SPECIES_FARWA,SPECIES_MULE,SPECIES_STOK,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_TRITONIAN,SPECIES_RESOMI,SPECIES_MONKEY,SPECIES_ZOMBIE)


/datum/disease2/disease/zombie/New()
	.=..()
	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	infectionchance = rand(50,100)
	var/datum/disease2/effect/gunck/E1 = new()
	E1.stage = 1
	E1.chance = 20
	effects += E1
	E1.multiplier = rand(1,E1.multiplier_max)
	var/datum/disease2/effect/hungry/E2 = new()
	E2.stage = 2
	E2.chance = 25
	effects += E2
	E2.multiplier = rand(1,E2.multiplier_max)
	var/datum/disease2/effect/hiv/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3
	E3.multiplier = rand(3,E3.multiplier_max)
	var/datum/disease2/effect/zombie/E4 = new()
	E4.stage = 4
	E4.chance = 80
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

/mob/living/carbon/human/transform_zombie()
	.=..()
	for(var/obj/item/organ/O in src.organs)
		O.species.species_flags += SPECIES_FLAG_NO_PAIN

/singleton/species/zombie/

	var/datum/disease2/disease/zombie/zombie = new()


/singleton/species/zombie/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	natural_armour_values = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
		)
	infect_virus2(H, zombie, 1)
	H.immunity = 10
	H.immunity_norm = 10


/singleton/species/zombie/handle_environment_special(mob/living/carbon/human/H)
	if (H.stat == CONSCIOUS)
		if (prob(5))
			playsound(H.loc, 'sound/hallucinations/far_noise.ogg', 15, 1)
		else if (prob(5))
			playsound(H.loc, 'sound/hallucinations/veryfar_noise.ogg', 15, 1)
		else if (prob(5))
			playsound(H.loc, 'sound/hallucinations/wail.ogg', 15, 1)

	if (H.stat != DEAD)
		for(var/obj/item/organ/organ in (H.organs + H.internal_organs))
			if (organ.damage > 0)
				organ.heal_damage(heal_rate, heal_rate, 1)
		if (H.getToxLoss())
			H.adjustToxLoss(-heal_rate)
		if (prob(5))
			H.resuscitate()
		H.vessel.add_reagent(/datum/reagent/blood, min(heal_rate * 20, blood_volume - H.vessel.total_volume))

	else
		var/list/victims = ohearers(rand(1, 2), H)
		for(var/mob/living/carbon/human/M in victims) // Post-mortem infection
			if (H == M || M.is_zombie())
				continue
			if (M.isSynthetic() || M.is_species(SPECIES_DIONA) || !(M.species.name in GLOB.zombie_species))
				continue
			if (M.wear_mask && (M.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT)) // If they're protected by a mask
				continue
			if (M.head && (M.head.item_flags & ITEM_FLAG_AIRTIGHT)) // If they're protected by a helmet
				continue

			var/vuln = 1 - M.get_blocked_ratio(BP_HEAD, DAMAGE_TOXIN, damage_flags = DAMAGE_FLAG_BIO) // Are they protected by hazmat clothing?
			if (vuln > 0.10 && prob(8))
				infect_virus2(H, zombie, 1)


/datum/unarmed_attack/bite/sharp/zombie/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target, attack_damage, zone)
	..()
	admin_attack_log(user, target, "Bit their victim.", "Was bitten.", "bit")
	if (!istype(target, /mob/living/carbon/human) || !(target.species.name in GLOB.zombie_species) || target.is_species(SPECIES_DIONA) || target.isSynthetic()) //No need to check infection for FBPs
		return

	target.adjustHalLoss(12) //To help bring down targets in voidsuits
	var/vuln = 1 - target.get_blocked_ratio(zone, DAMAGE_TOXIN, damage_flags = DAMAGE_FLAG_BIO) //Are they protected from bites?
	if (vuln > 0.05)
		if (prob(vuln * 100)) //Protective infection chance
			if (prob(min(100 - target.get_blocked_ratio(zone, DAMAGE_BRUTE) * 100, 30))) //General infection chance
				infect_virus2(target, pick(user.virus2), 1) //Infect 'em
