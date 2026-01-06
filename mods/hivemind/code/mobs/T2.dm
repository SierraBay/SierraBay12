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

////////////////////////Treader///////////////////
//Ranged just like the lobber, (deals more damage but needs longer to recharge, but given that ranged_cooldown does nothing not implemented yet)
//When damaged, "releases a cloud of nanites" that heal all allies in view
//A bit tanky, but moves slow
//Death releases a EMP pulse
/////////////////////////////////////////////////
/mob/living/simple_animal/hostile/hivemind/treader
	name = "Treader"
	desc = "A human head with a screen shoved in its mouth, connected to a large column with another screen displaying a human face."
	icon_state = "treader"
	attacktext = "slapped"
	health = 100
	maxHealth = 100
	malfunction_chance = 10
	speak_chance = 2
	speed = 6
	ranged = TRUE
	projectiletype = /obj/item/projectile/goo
	projectilesound = 'sound/effects/blobattack.ogg'
	mob_size = MOB_MEDIUM
	ability_cooldown = 20 SECONDS

	say_list_type = /datum/say_list/lobber

/datum/say_list/lobber
	speak = list(
				"Hey, at least I got my head.",
				"I can\'t... I can\'t feel my arms...",
				"Oh god... my legs... where are my legs..."
				)

	say_got_target = list(
				"You there! Cut off my head!",
				"So sorry! Can\'t exactly control my head anymore.",
				"S-shoot the screen! God I hope it won\'t hurt."
				)

/mob/living/simple_animal/hostile/hivemind/treader/Initialize()
	..()
	set_light(2, 1, COLOR_BLUE_LIGHT)

/mob/living/simple_animal/hostile/hivemind/treader/Life()
	if(!..())
		return

	if(maxHealth > health && world.time > special_ability_cooldown)
		special_ability()


/mob/living/simple_animal/hostile/hivemind/treader/special_ability()
	visible_emote("vomits out a burst of rejuvenating nanites!")

	for(var/mob/living/simple_animal/hostile/hivemind/ally in view(src))
		ally.heal_overall_damage(10, 0)

	special_ability_cooldown = world.time + ability_cooldown


/mob/living/simple_animal/hostile/hivemind/treader/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	empulse(get_turf(src), 1, 3)
	qdel(src)


/////////////////////////////////////PHASER///////////////////////////////////
//Special ability: Superposition. Phaser exists at four locations. But, actually he vulnerable only at one. Other is just a copies
//Moves with teleportation only, can stun victim if he land on it
//Also can hide in closets
//Can't speak, no malfunctions
//Appears from dead human body
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/phaser
	name = "Phaser"
	desc = "A twisted human with a strange device on its head. Or for its head."
	icon_state = "phaser"
	health = 160
	maxHealth = 160
	attacktext = "warps"
	speak_chance = 0
	malfunction_chance = 0
	mob_size = MOB_MEDIUM
	ability_cooldown = 2 MINUTES

	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_MINOR,
		"bullet" = ARMOR_BALLISTIC_MINOR,
		"laser" = ARMOR_LASER_MAJOR,
		"energy" = ARMOR_RAD_RESISTANT,
		"bomb" = ARMOR_BOMB_MINOR,
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)

	movement_cooldown = 0 // Hunters are FAST.

	ai_holder = /datum/ai_holder/hivemind/phaser

	// Leaping is a special attack, so these values determine when leap can happen.
	// Leaping won't occur if its on cooldown.
	special_attack_min_range = 2
	special_attack_max_range = 4
	special_attack_cooldown = 10 SECONDS

	var/leap_warmup = 1 SECOND // How long the leap telegraphing is.
	var/leap_sound = 'sound/effects/ghost2.ogg'

// Multiplies damage if the victim is stunned in some form, including a successful leap.
/mob/living/simple_animal/hostile/hivemind/phaser/apply_bonus_melee_damage(atom/A, damage_amount)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incapacitated(INCAPACITATION_DISABLED))
			return damage_amount * 1.5
	return ..()

/mob/living/simple_animal/hostile/hivemind/phaser/New()
	..()
	filters += filter(type="blur", size = 0)

// The actual leaping attack.
/mob/living/simple_animal/hostile/hivemind/phaser/do_special_attack(atom/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)

	// Telegraph, since getting stunned suddenly feels bad.
	do_windup_animation(A, leap_warmup)
	sleep(leap_warmup) // For the telegraphing.

	// Do the actual leap.
	status_flags |= LEAPING // Lets us pass over everything.
	visible_message(SPAN_DANGER("\The [src] phases out at \the [A]!"))
	throw_at(get_step(get_turf(A), get_turf(src)), special_attack_max_range+1, 1, src)
	playsound(src, leap_sound, 75, 1)

	sleep(5) // For the throw to complete. It won't hold up the AI ticker due to waitfor being false.

	if(status_flags & LEAPING)
		status_flags &= ~LEAPING // Revert special passage ability.

	var/turf/T = get_turf(src) // Where we landed. This might be different than A's turf.

	. = FALSE

	// Now for the stun.
	var/mob/living/victim = null
	for(var/mob/living/L in T) // So player-controlled spiders only need to click the tile to stun them.
		if(L == src)
			continue

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.check_shields(damage = 0, damage_source = src, attacker = src, def_zone = null, attack_text = "the leap"))
				continue // We were blocked.

		victim = L
		break

	if(victim)
		victim.Weaken(2)
		victim.visible_message(SPAN_DANGER("\The [src] knocks down \the [victim]!"))
		to_chat(victim, SPAN_CLASS("critical", "\The [src] teleports right in front of you!"))
		. = TRUE

	set_AI_busy(FALSE)


//second part - is jump to target
/mob/living/simple_animal/hostile/hivemind/phaser/proc/phase_jump(turf/place)
	playsound(place, 'sound/effects/phasein.ogg', 60, 1)
	animate(filters[1], size = 0, time = 5)
	icon_state = "phaser-[rand(1,4)]"
	src.loc = place
	for(var/mob/living/L in loc)
		if(L != src)
			visible_message("<b>[src]</b> land on <b>[L]</b>!")
			playsound(place, 'sound/effects/ghost2.ogg', 70, 1)
			L.Weaken(3)

/mob/living/simple_animal/hostile/hivemind/phaser/death()
	..()
	gibs(loc, null, /obj/gibspawner/human)
	qdel(src)

/datum/ai_holder/hivemind/phaser
	can_flee = TRUE

/datum/ai_holder/hivemind/phaser/post_melee_attack(atom/A)
	if(holder.Adjacent(A))
		holder.IMove(get_step(holder, pick(GLOB.alldirs)))
		holder.face_atom(A)
