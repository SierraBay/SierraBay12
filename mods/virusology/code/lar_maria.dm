/datum/disease2/disease/lar_maria
	infectionchance = 90//very aggressive
	speed = 10
	spreadtype = "Airborne"
	affected_species = list(HUMAN_SPECIES,SPECIES_UNATHI,SPECIES_SKRELL,SPECIES_UNATHI,SPECIES_YEOSA,SPECIES_TRITONIAN,SPECIES_NABBER,SPECIES_MONKEY)

/datum/disease2/disease/lar_maria/New()
	..()
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	E1.chance = 3
	effects += E1
	var/datum/disease2/effect/stimulant/E2 = new()
	E2.stage = 2
	E2.chance = 3
	effects += E2
	var/datum/disease2/effect/stimulant/E3 = new()
	E3.stage = 3
	E3.chance = 3
	effects += E3
	var/datum/disease2/effect/rage/E4 = new()
	E4.stage = 4
	E4.chance = 3
	effects += E4

/datum/disease2/effect/rage //custom effect, fills PC with uncontrollable rage
	name = "Rampage Syndrome"
	stage = 4
	badness = VIRUS_EXOTIC
	delay = 20 SECONDS
	var/first_message_shown = FALSE

/datum/disease2/effect/rage/activate(mob/living/carbon/human/mob, multiplier)
	if (!first_message_shown)
		first_message_shown = TRUE
		to_chat(mob, "<span class='warning'>Your muscles start tensing up, and you can feel your pulse rising, throbbing at the back of your head. Your breathing increases, and you feel... angry. An urge wells up inside you. Everything is making you angry, and you want it to <i>pay</i> for it.</span>")
		return //nothing else happens first time giving chance to adjust RP
	if(prob(50))
		to_chat(mob, "<span class='warning'>You feel uncontrollable rage filling you! You want to hurt and destroy!</span>")
		if (mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
			mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
	if(prob(50) && mob.check_has_mouth())//go crazy and bite someone
		var/list/mouth_status = mob.can_eat_status()
		if (mouth_status[1] == 1)//if no mouth HUMAN_EATING_NBP_MOUTH
			to_chat(mob, "<span class='warning'>You angrily attempt to bite someone but you can't without a mouth!</span>")
			return
		if (mouth_status[1] == 2)//if something covers mouth HUMAN_EATING_BLOCKED_MOUTH
			to_chat(mob, "<span class='warning'>You angrily chew \the [mouth_status[2]] covering your mouth!</span>")
			return
		var/list/mobs_to_bite = list()
		for (var/mob/living/carbon/human/L in range(1))
			if (L == mob)
				continue
			mobs_to_bite += L
		if (LAZYLEN(mobs_to_bite) < 1)//nobody to bite
			return
		var/mob/living/carbon/human/Target = pick(mobs_to_bite)
		mob.visible_message("<span class='warning'>[mob] violently bites [Target]!</span>")
		Target.adjustBruteLoss(5)
		if (prob(50))
			infect_virus2(Target, src, 1)


/mob/living/simple_animal/hostile/lar_maria
	var/datum/disease2/disease/lar_maria/LMD = new()

/mob/living/simple_animal/hostile/lar_maria/Destroy()
	. = ..()
	QDEL_NULL(LMD)


/mob/living/simple_animal/hostile/lar_maria/death(gibbed, deathmessage, show_dead_message)
	.=..()
	for (var/mob/living/carbon/human/L in orange(3))//infect those who are around
		if (prob(infection_chance(L, "Airborne")))
			infect_virus2(L, LMD, 1)
	qdel(src)

/mob/living/simple_animal/hostile/lar_maria/do_special_attack()
	. = ..()
	if (!.)
		return
	if(ishuman(target_mob) && Adjacent(target_mob))//if it's human who can be infected standing nearby
		var/mob/living/L = target_mob
		if (prob(50))
			visible_message("<span class='alert'>[src] violently bites [L]!</span>")
			infect_virus2(L, LMD, 1)
