/// Tier Two Hivemind mobs
/// Опасные в бою 1 на 1, но редкие и, чаще всего, требующие для своего появления, трупов экипажа

////hive brings us here to////////////////////////////////////////////////////
////////////////////////////////////BIG GUYS/////////////////////////////////
/////////////////////////////////////////////////////fright and destroy/////



/////////////////////////////////////HIBORG///////////////////////////////////
//Hive + Cyborg
//Special ability: none...
//Have a few types of attack: Default one.
//							  Claw, that press down the victims.
//							  Splash attack, that slash everything around!
//High chance of malfunction
//Default speaking chance
//Appears from dead cyborgs
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/hiborg
	name = "cyborg"
	desc = "A cyborg covered with something... something alive."
	icon_state = "hiborg"
	icon_dead = "hiborg-dead"
	health = 220
	maxHealth = 220
	harm_intent_damage = 20
	attacktext = "claws"
	speed = 12
	malfunction_chance = 15
	mob_size = MOB_MEDIUM
	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile
	say_list_type = /datum/say_list/hiborg

	natural_weapon = /obj/item/natural_weapon/hivebot/strong
	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_RESISTANT,
		"bullet" = ARMOR_BALLISTIC_PISTOL,
		"laser" = ARMOR_LASER_SMALL,
		"energy" = ARMOR_ENERGY_MINOR,
		"bomb" = ARMOR_BOMB_MINOR,
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)

/datum/say_list/hiborg
	speak = list("Everytime something breaks apart. Hell, I hate this job!",
				"What? I hear something. Just mice? Just mice, phew...",
				"I'm too tired, man, too tired. This job is... Awful.",
				"These people know nothing about this work or about me. I can surprise them.",
				"Blue wire is bolts, green is safety. Just... Pulse it here, okay? Right...")
	say_got_target = list(
						"I know what's wrong, just let me fix that.",
						"You need my help? What's wrong? Gimme that thing, I can fix that.",
						"Si-i-ir... Sir. Sir. It's better to... Stop here! Stop i said, what are you!?",
						"Wait! Hey! Can i fix that!? I'm an engineer, you fuck! Sto-op-op-p here, i know what to do!"
						)


/mob/living/simple_animal/hostile/hivemind/hiborg/do_special_attack(target_mob)
	if(!Adjacent(target_mob))
		return

	//special attacks
	if(prob(10))
		splash_slash()
		return

	if(prob(40))
		stun_with_claw()
		return

	return ..() //default attack


/mob/living/simple_animal/hostile/hivemind/hiborg/proc/splash_slash()
	src.visible_message(SPAN_DANGER("[src] spins around and slashes in a circle!"))
	for(var/atom/target in range(1, src))
		if(target != src)
			target.attack_generic(src, rand(harm_intent_damage*1,5))
	if(!client && prob(speak_chance))
		say(pick("Get away from me!", "They are everywhere!"))


/mob/living/simple_animal/hostile/hivemind/hiborg/proc/stun_with_claw()
	if(isliving(target_mob))
		var/mob/living/victim = target_mob
		victim.Weaken(5)
		src.visible_message(SPAN_WARNING("[src] holds down [victim] to the floor with his claw."))
		if(!client && prob(speak_chance))
			say(pick("Stand still, I'll make it fast!",
					"I will fix you! Don't resist! Don't resist you rat!",
					"I just want to replace that broken thing!"))



/////////////////////////////////////HIMAN////////////////////////////////////
//Hive + Man
//Special ability: Shriek, that stuns victims
//Can fool his enemies and pretend to be dead
//A little bit higher chance of malfunction
//Default speaking chance
//Appears from dead human corpses
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/himan
	name = "human"
	desc = "This guy is totally not human. You can see tubes all across his body and metal where flesh should be."
	icon_state = "himan"
	icon_dead = "himan-dead"
	health = 120
	maxHealth = 120
	harm_intent_damage = 25
	attacktext = "slashes with claws"
	malfunction_chance = 10
	mob_size = MOB_MEDIUM
	speed = 8
	ability_cooldown = 30 SECONDS
	//internals
	var/fake_dead = FALSE
	var/fake_dead_wait_time = 0
	var/fake_death_cooldown = 0
	ai_holder = /datum/ai_holder/hivemind/himan
	say_list_type = /datum/say_list/himan

	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_SMALL,
		"bullet" = ARMOR_BALLISTIC_MINOR,
		"laser" = ARMOR_LASER_SMALL,
		"energy" = ARMOR_RAD_RESISTANT,
		"bomb" = ARMOR_BOMB_MINOR,
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)

/datum/say_list/himan
	speak = list(
				"Stop... It. Just... STOP IT!",
				"Why, honey? Why? Why-hy-hy?",
				"That noise... My head! Shit!",
				"There must be an... An esca-cape!",
				"Come on, you ba-ba-bastard, I know what you really want.",
				"How much fun!"
				)
	say_got_target = list(
						"Are you... Are you okay? Wa-wait, wait a minu-nu-nute.",
						"Come on, you ba-ba-bastard, i know what you really want to.",
						"How much fun!",
						"Are you try-trying to escape? That is how you plan to do it? Then run... Run...",
						"Wait! Can you just... Just pull out this thing from my he-head? Wait...",
						"Hey! I'm friendly! Wait, it's just a-UGH"
						)

/datum/ai_holder/hivemind/himan
	pointblank = FALSE
	cooperative = FALSE

/mob/living/simple_animal/hostile/hivemind/himan/Life()
	. = ..()

	//shriek
	if(target_mob && world.time > special_ability_cooldown && !fake_dead)
		special_ability()


	//low hp? It's time to play dead
	if(health < 60 && !fake_dead && world.time > fake_death_cooldown)
		fake_death()

	//shhhh, there an ambush
	if(fake_dead)
		stance = STANCE_DISABLED
		speak_chance = 0

/mob/living/simple_animal/hostile/hivemind/himan/mulfunction()
	if(fake_dead)
		return
	..()

/*
/mob/living/simple_animal/hostile/hivemind/himan/MoveToTarget()
	if(!fake_dead)
		..()
	else
		if(!target_mob || SA_attackable(target_mob))
			stance = STANCE_IDLE
		if(target_mob in ListTargets(10))
			if(get_dist(src, target_mob) > 1)
				stance = STANCE_ATTACKING


/datum/ai_holder/hivemind/himan/post_melee_attack()
	if(holder.fake_dead)
		if(!holder.Adjacent(target_mob))
			return
		if(target_mob && (world.time > holder.fake_dead_wait_time))
			awake()
	else
		..()
*/
//Shriek stuns our victims and make them deaf for a while
/mob/living/simple_animal/hostile/hivemind/himan/special_ability()
	visible_emote("screams!")
	playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 90, 1)
	for(var/mob/living/victim in view(src))
		if(isdeaf(victim))
			continue
		if(istype(victim, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) && istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
		victim.Weaken(5)
		victim.ear_deaf = 40
		victim.visible_message(SPAN_WARNING("You hear loud and terrible scream!"))
	special_ability_cooldown = world.time + ability_cooldown


//Insidiously
/mob/living/simple_animal/hostile/hivemind/himan/proc/fake_death()
	src.visible_message("<b>[src]</b> dies!")
	fake_dead = TRUE
	walk(src, FALSE)
	icon_state = icon_dead
	fake_dead_wait_time = world.time + 10 SECONDS


/mob/living/simple_animal/hostile/hivemind/himan/proc/awake()
	var/mob/living/L = target_mob
	if(L)
		L.attack_generic(src, rand(15, 25)) //stealth attack
		L.Weaken(5)
		visible_emote("grabs [L]'s legs and force them down to the floor!")
		var/msg = pick("SEU-EU-EURPRAI-AI-AIZ-ZT!", "I'M NOT DO-DONE!", "HELL-L-LO-O-OW!", "GOT-T YOU HA-HAH!")
		say(msg)
	icon_state = "himan-damaged"
	fake_dead = FALSE
	stance = STANCE_IDLE
	fake_death_cooldown = world.time + 2 MINUTES
