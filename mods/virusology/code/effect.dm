////////////////////////////////////////////////////////////////
////////////////////////EFFECTS/////////////////////////////////
////////////////////////////////////////////////////////////////
/proc/get_random_virus2_effect(stage, badness, exclude)
	var/list/datum/disease2/effect/candidates = list()
	for(var/T in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/E = T
		if(E in exclude)
			continue
		if(initial(E.badness) > badness)	//we don't want such strong effects
			continue
		if(initial(E.stage) <= stage)
			candidates += T
	var/type = pick(candidates)
	var/datum/disease2/effect/effect = new type
	effect.generate()
	effect.chance = rand(0,effect.chance_max)
	effect.multiplier = rand(1,effect.multiplier_max)
	return effect

/datum/disease2/effect
	var/name = "Blanking effect"
	var/chance			//probality to fire every tick
	var/chance_max = 50
	var/multiplier = 1	//effect magnitude multiplier
	var/multiplier_max = 1
	var/stage = 4		//minimal stage
	var/badness = VIRUS_MILD	//Used in random generation to limit how bad result should come out.
	var/data = null 	//For semi-procedural effects; this should be generated in generate() if used
	var/oneshot
	var/delay = 5 SECONDS	//minimal time between activations
	var/hold_until		//can only fire after this worldtime
	var/allow_multiple	//allow to have more than 1 effect of this type in the same virus

/datum/disease2/effect/proc/get_effect_info(verbose = 1)
	. = list()
	if(verbose)
		. += "([stage]) [name]    "
		. += "<small><u>Strength:</u> [multiplier >= 3 ? "Severe" : multiplier > 1 ? "Above Average" : "Average"]    "
		. += "<u>Verosity:</u> [chance * 10]</small><br>"
	else
		. += name
	return JOINTEXT(.)

/datum/disease2/effect/proc/fire(mob/living/carbon/human/mob,current_stage)
	if(oneshot == -1)
		return
	if(hold_until > world.time)
		return
	if(mob.chem_effects[CE_ANTIVIRAL] >= badness)
		return
	if(stage <= current_stage && prob(chance))
		hold_until = world.time + delay
		activate(mob)
		if(oneshot == 1)
			oneshot = -1

/datum/disease2/effect/proc/minormutate()
	switch(pick(1,2,3,4,5))
		if(1)
			chance = rand(0,chance_max)
		if(2)
			multiplier = rand(1,multiplier_max)

/datum/disease2/effect/proc/activate(mob/living/carbon/human/mob)
/datum/disease2/effect/proc/deactivate(mob/living/carbon/human/mob)
/datum/disease2/effect/proc/generate(copy_data) // copy_data will be non-null if this is a copy; it should be used to initialise the data for this effect if present

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4
	badness = VIRUS_COMMON
/datum/disease2/effect/killertoxins/activate(mob/living/carbon/human/mob, multiplier)
	mob.adjustToxLoss(15*multiplier)

/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
/datum/disease2/effect/dna/activate(mob/living/carbon/human/mob, multiplier)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble(0,mob,10)
	mob.apply_damage(10, DAMAGE_GENETIC)

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
/datum/disease2/effect/organs/activate(mob/living/carbon/human/mob, multiplier)
	var/organ = pick(list(BP_R_ARM,BP_L_ARM,BP_R_LEG,BP_L_LEG))
	var/obj/item/organ/external/E = mob.organs_by_name[organ]
	if (!(E.status & ORGAN_DEAD))
		E.status |= ORGAN_DEAD
		to_chat(mob, "<span class='notice'>You can't feel your [E.name] anymore...</span>")
		for (var/obj/item/organ/external/C in E.children)
			C.status |= ORGAN_DEAD
	mob.update_body(1)
	mob.adjustToxLoss(15*multiplier)

/datum/disease2/effect/organs/deactivate(mob/living/carbon/human/mob, multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.status &= ~ORGAN_DEAD
		for (var/obj/item/organ/external/C in E.children)
			C.status &= ~ORGAN_DEAD
	mob.update_body(1)

/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
/datum/disease2/effect/immortal/activate(mob/living/carbon/human/mob, multiplier)
	for (var/external in mob.organs)
		var/obj/item/organ/external/E = external
		if (E.status & ORGAN_BROKEN && prob(30))
			to_chat(mob, "<span class='notice'>Your [E.name] suddenly feels much better!</span>")
			E.status ^= ORGAN_BROKEN
			break
	for (var/internal in mob.internal_organs)
		var/obj/item/organ/internal/I = internal
		if (I.damage && prob(30))
			to_chat(mob, "<span class='notice'>Your [mob.get_organ(I.parent_organ)] feels a bit warm...</span>")
			I.take_internal_damage(-2*multiplier)
			break
	var/heal_amt = -5*multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(mob/living/carbon/human/mob, multiplier)
	to_chat(mob, "<span class='notice'>You suddenly feel hurt and old...</span>")
	mob.age += 8
	var/backlash_amt = 5*multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)

/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 4
	badness = VIRUS_ENGINEERED
/datum/disease2/effect/bones/activate(mob/living/carbon/human/mob, multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = max(5, E.min_broken_damage - 30)

/datum/disease2/effect/bones/deactivate(mob/living/carbon/human/mob, multiplier)
	for (var/obj/item/organ/external/E in mob.organs)
		E.min_broken_damage = initial(E.min_broken_damage)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	multiplier_max = 3
	badness = VIRUS_COMMON
/datum/disease2/effect/toxins/activate(mob/living/carbon/human/mob, multiplier)
	mob.adjustToxLoss((2*multiplier))

/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	multiplier_max = 3
/datum/disease2/effect/shakey/activate(mob/living/carbon/human/mob, multiplier)
	shake_camera(mob,5*multiplier)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3
	badness = VIRUS_COMMON
/datum/disease2/effect/mind/activate(mob/living/carbon/human/mob, multiplier)
	var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
	if (B && B.damage < B.min_broken_damage)
		B.take_internal_damage(5)

/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	stage = 3
/datum/disease2/effect/deaf/activate(mob/living/carbon/human/mob, multiplier)
	mob.ear_deaf = 5

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	stage = 3
/datum/disease2/effect/confusion/activate(mob/living/carbon/human/M, multiplier)
	to_chat(M, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
	M.mod_confused(40)

/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	badness = VIRUS_COMMON
/datum/disease2/effect/mutation/activate(mob/living/carbon/human/mob, multiplier)
	mob.apply_damage(2, DAMAGE_GENETIC)

/datum/disease2/effect/chem_synthesis
	name = "Chemical Synthesis"
	stage = 3
	badness = VIRUS_COMMON
	chance_max = 25

/datum/disease2/effect/chem_synthesis/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick(/datum/reagent/bicaridine, /datum/reagent/kelotane, /datum/reagent/dylovene, /datum/reagent/inaprovaline, /datum/reagent/drugs/psilocybin, /datum/reagent/sugar,
					/datum/reagent/tramadol, /datum/reagent/dexalin, /datum/reagent/drugs/cryptobiolin, /datum/reagent/impedrezene, /datum/reagent/hyperzine, /datum/reagent/ethylredoxrazine,
					/datum/reagent/drugs/mindbreaker, /datum/reagent/nutriment/glucose)
	var/datum/reagent/R = data
	name = "[initial(name)] ([initial(R.name)])"

/datum/disease2/effect/chem_synthesis/activate(mob/living/carbon/human/mob, multiplier)
	if (mob.reagents.get_reagent_amount(data) < 5)
		mob.reagents.add_reagent(data, 2)

/datum/disease2/effect/nothing
	name = "Nil Syndrome"
	stage = 1
	badness = VIRUS_MILD
	chance_max = 0
	allow_multiple = 1

////////////////////////STAGE 2/////////////////////////////////
/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	stage = 2
/datum/disease2/effect/drowsness/activate(mob/living/carbon/human/mob, multiplier)
	mob.drowsyness = min(mob.drowsyness + 10, 50)

/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	stage = 2
	chance_max = 15
	delay = 35 SECONDS
/datum/disease2/effect/sleepy/activate(mob/living/carbon/human/mob, multiplier)
	mob.emote("collapse")

/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2
	badness = VIRUS_COMMON
/datum/disease2/effect/blind/activate(mob/living/carbon/human/mob, multiplier)
	mob.eye_blind = max(mob.eye_blind, 4)

/datum/disease2/effect/cough
	name = "Anima Syndrome"
	stage = 2
	delay = 25 SECONDS
/datum/disease2/effect/cough/activate(mob/living/carbon/human/mob, multiplier)
	mob.emote("cough")
	if (mob.wear_mask)
		return
	for(var/mob/living/carbon/human/M in oview(2,mob))
		mob.spread_disease_to(M)

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	stage = 2
/datum/disease2/effect/hungry/activate(mob/living/carbon/human/mob, multiplier)
	mob.adjust_nutrition(-200)

/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	chance_max = 25
	delay = 25 SECONDS
/datum/disease2/effect/fridge/activate(mob/living/carbon/human/mob, multiplier)
	mob.emote("shiver")

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	stage = 2
	badness = VIRUS_COMMON
/datum/disease2/effect/stimulant/activate(mob/living/carbon/human/mob, multiplier)
	to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
	if (mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
		mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
	if (prob(30))
		mob.jitteriness = min(mob.jitteriness + 10, 500)

////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1
	delay = 15 SECONDS

/datum/disease2/effect/sneeze/activate(mob/living/carbon/human/mob, multiplier)
	if (prob(30))
		to_chat(mob, "<span class='warning'>You feel like you are about to sneeze!</span>")
	sleep(5)
	mob.emote("sneeze")
	for(var/mob/living/carbon/human/M in get_step(mob,mob.dir))
		mob.spread_disease_to(M)
	if (prob(50) && !mob.wear_mask)
		var/obj/decal/cleanable/mucus/M = new(get_turf(mob))
		M.virus2 = virus_copylist(mob.virus2)

/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1
	delay = 25 SECONDS
/datum/disease2/effect/gunck/activate(mob/living/carbon/human/mob, multiplier)
	to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")

/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1
	chance_max = 25
	delay = 25 SECONDS
/datum/disease2/effect/drool/activate(mob/living/carbon/human/mob, multiplier)
	mob.emote("drool")

/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1
	chance_max = 25
	delay = 25 SECONDS
/datum/disease2/effect/twitch/activate(mob/living/carbon/human/mob, multiplier)
	mob.emote("twitch")

/datum/disease2/effect/headache
	name = "Headache"
	stage = 1
	delay = 25 SECONDS
/datum/disease2/effect/headache/activate(mob/living/carbon/human/mob, multiplier)
	mob.custom_pain("Your head hurts a bit.", 20)

/datum/disease2/effect/itch
	name = "Itches"
	stage = 1
	delay = 25 SECONDS
/datum/disease2/effect/itch/activate(mob/living/carbon/human/mob, multiplier)
	var/obj/O = pick(mob.organs)
	to_chat(mob, "<span class='warning'>Your [O.name] itches like hell.</span>")

/datum/disease2/effect/stomach
	name = "Upset stomach"
	stage = 1
	delay = 25 SECONDS
/datum/disease2/effect/stomach/activate(mob/living/carbon/human/mob, multiplier)
	to_chat(mob, "<span class='warning'>Your stomach feels heavy.</span>")
