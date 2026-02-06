/// Tier Three Hivemind mobs
/// Мини-боссы, способные убить одинокого игрока, появляются редко или при специфических условиях

/////////////////////////////////////MECHIVER/////////////////////////////////
//Mech + Hive + Driver
//Special ability: Picking up a victim. Sends hallucinations and harm sometimes, then release
//Can picking up corpses too, rebuild them to living hive mobs, like it wires do
//Default malfunction chance
//Default speaking chance, can take pilot and speak with him
//Very rarely can appears from infested machinery and from mecha wreckage
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/mechiver
	name = "Robotic Horror"
	desc = "A weird-looking machinery Frankenstein"
	icon = 'mods/hivemind/icons/hivemind.dmi'
	icon_state = "mechiver-closed"
	icon_dead = "mechiver-dead"
	health = 450
	maxHealth = 450
	harm_intent_damage = 0
	mob_size = MOB_LARGE
	attacktext = "tramples"
	ability_cooldown = 1 MINUTE
	speak_chance = 5
	speed = 16
	//internals
	var/pilot						//Yes, there's no pilot, so we just use var
	var/mob/living/passenger
	var/hatch_closed = TRUE
	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile
	say_list_type = /datum/say_list/mechiver

	mob_flags = MOB_FLAG_UNPINNABLE
	can_be_buckled = FALSE

	natural_weapon = /obj/item/natural_weapon/juggernaut
	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_RESISTANT,
		"bullet" = ARMOR_BALLISTIC_RESISTANT,
		"laser" = ARMOR_LASER_MAJOR,
		"energy" = ARMOR_ENERGY_RESISTANT,
		"bomb" = ARMOR_BOMB_RESISTANT,
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)

/datum/say_list/mechiver
	//default speaking
	speak = list(
				"Somebody, just tell him to shut up...",
				"Bzew-zew-zewt. Th-this way!",
				"Wha-a-at? When I'm near this cargo, I feel... fe-fe-fea-fear-er.")
	say_got_target = list(
				"Come here, jo-jo-join me. Join us-s.",
				"Time to be-to be-to be whole.",
				"Enter me, i'm be-best mech among all of these rusty buckets.",
				"I'm dying. I can't see my ha-hands! I'm scared, hu-hu-hug me.",
				"Get in! I've got a seat just for you.",
				"I'm not done, it can't be... Hey! Hey you, enter me!")


/mob/living/simple_animal/hostile/hivemind/mechiver/Life()
	. = ..()
	queue_icon_update()

	//when we have passenger, we torture him
	if(passenger && prob(15))
		passenger.apply_damage(rand(5, 10), pick(DAMAGE_BRUTE, DAMAGE_BURN, DAMAGE_TOXIN))
		passenger.visible_message(SPAN_DANGER(pick(
								"Something grabs your neck!", "You hear whisper: \" It's okay, now you're sa-sa-safe! \"",
								"You've been hit by something metal", "You almost can't feel your leg!", "Something liquid covers you!",
								"You feel awful and smell something rotten", "Something sharp cut your cheek!",
								"You feel something worm-like trying to wriggle into your skull through your ear...")))
		anim_shake(src)
		playsound(src, 'sound/effects/clang.ogg', 70, 1)


	//corpse ressurection
	if(!target_mob && !passenger)
		for(var/mob/living/Corpse in view(src))
			if(Corpse.stat == DEAD)
				if(get_dist(src, Corpse) <= 1)
					special_ability(Corpse)
				else
					walk_to(src, Corpse, 1, 1, 4)
				break


//animations
//updates every life tick
/mob/living/simple_animal/hostile/hivemind/mechiver/queue_icon_update()
	. = ..()
	if(target_mob && !passenger && (get_dist(target_mob, src) <= 4) && !is_on_cooldown())
		if(!hatch_closed)
			return
		CutOverlays()
		if(pilot)
			flick("mechiver-opening", src)
			icon_state = "mechiver-chief"
			AddOverlays("mechiver-hands")
		else
			flick("mechiver-opening_wires", src)
			icon_state = "mechiver-welcome"
			AddOverlays("mechiver-wires")
		hatch_closed = FALSE
	else
		CutOverlays()
		hatch_closed = TRUE
		icon_state = "mechiver-closed"
		if(passenger)
			AddOverlays("mechiver-process")


/mob/living/simple_animal/hostile/hivemind/mechiver/attack_target(target_mob)
	if(!Adjacent(target_mob))
		return

	if(world.time > special_ability_cooldown && !passenger && target_mob != /mob/living/exosuit)
		special_ability(target_mob)

	..()


//picking up our victim for good 20 seconds of best road trip ever
/mob/living/simple_animal/hostile/hivemind/mechiver/special_ability(mob/living/target)
	if(!target_mob && hatch_closed) //when we picking up corpses
		if(pilot)
			flick("mechiver-opening", src)
		else
			flick("mechiver-opening_wires", src)
	passenger = target
	target.loc = src
	target.incapacitated(incapacitation_flags = INCAPACITATION_BUCKLED_FULLY)
	target.visible_message(SPAN_DANGER("You've gotten inside that thing! It's hard to see inside, there's something here, it moves around you!"))
	playsound(src, 'sound/effects/blobattack.ogg', 70, 1)
	addtimer(new Callback(src, PROC_REF(release_passenger)), 40 SECONDS, TIMER_UNIQUE)



/mob/living/simple_animal/hostile/hivemind/mechiver/proc/release_passenger(safely = FALSE)
	if(passenger)
		if(pilot)
			flick("mechiver-opening", src)
		else
			flick("mechiver-opening_wires", src)

		if(istype(passenger, /mob/living/carbon/human))
			if(!safely) //that was stressful
				var/mob/living/carbon/human/H = passenger
				if(!pilot && H.stat == DEAD)
					destroy_passenger()
					pilot = TRUE
					return

				H.hallucination(30,90)
		//if mob is dead, we just rebuild it
		if(passenger.stat == DEAD && !safely)
			dead_body_restoration(passenger)

		if(passenger) //if passenger still here, then just release him
			passenger.visible_message(SPAN_DANGER("[src] released you!"))
			passenger.incapacitated(incapacitation_flags = INCAPACITATION_NONE)
			passenger.loc = get_turf(src)
			passenger = null
			special_ability_cooldown = world.time + ability_cooldown
		playsound(src, 'sound/effects/blobattack.ogg', 70, 1)


/mob/living/simple_animal/hostile/hivemind/mechiver/proc/dead_body_restoration(mob/living/corpse)
	var/picked_mob
	if(passenger.mob_size <= MOB_SMALL && !client && prob(50))
		picked_mob = pick(/mob/living/simple_animal/hostile/hivemind/stinger, /mob/living/simple_animal/hostile/hivemind/bomber)
	else
		if(pilot)
			if(istype(corpse, /mob/living/carbon/human))
				picked_mob = /mob/living/simple_animal/hostile/hivemind/himan
			else if(istype(corpse, /mob/living/silicon/robot))
				picked_mob = /mob/living/simple_animal/hostile/hivemind/hiborg
	if(picked_mob)
		new picked_mob(get_turf(src))
	else
		var/mob/living/simple_animal/hostile/hivemind/resurrected/fixed_mob = new(get_turf(src))
		fixed_mob.take_appearance(corpse)
	destroy_passenger()


/mob/living/simple_animal/hostile/hivemind/mechiver/proc/destroy_passenger()
	qdel(passenger)
	passenger = null


//we're not forgot to release our victim safely after death
/mob/living/simple_animal/hostile/hivemind/mechiver/Destroy()
	release_passenger(TRUE)
	..()

/mob/living/simple_animal/hostile/hivemind/mechiver/death()
	release_passenger(TRUE)
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	if(pilot)
		gibs(loc, null, /obj/gibspawner/human)
	qdel(src)


/////////////////////////////////////TYRANT///////////////////////////////////
//Special ability: Superposition. Phaser exists at four locations. But, actually he vulnerable only at one. Other is just a copies
//Moves with teleportation only, can stun victim if he land on it
//Also can hide in closets
//Can't speak, no malfunctions
//Appears from dead human body
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant
	name = "Hivemind Tyrant"
	desc = "Hivemind's will, manifested in flesh and metal."

	faction = "hive"
	mob_size = MOB_LARGE
	icon = 'mods/hivemind/icons/64x64.dmi'
	icon_state = "hivemind_tyrant"
	icon_living = "hivemind_tyrant"
	icon_dead = "hivemind_tyrant"
	pixel_x = -16
	ranged = TRUE

	mob_flags = MOB_FLAG_UNPINNABLE
	can_be_buckled = FALSE

	health = 1850
	maxHealth = 1850 //Only way for it to show up right now is via adminbus OR Champion call (which gives it 150hp).
	break_stuff_probability = 95

	projectiletype = /obj/item/projectile/goo
	natural_weapon = /obj/item/natural_weapon/juggernaut/behemoth
	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_MAJOR,
		"bullet" = ARMOR_BALLISTIC_RESISTANT,
		"laser" = ARMOR_LASER_MAJOR,
		"energy" = ARMOR_ENERGY_RESISTANT,
		"bomb" = ARMOR_BOMB_RESISTANT,
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)

/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant/death()
	..()
	if(GLOB.hive_data_bool["tyrant_death_kills_hive"])
		delhivetech()
	qdel(src)

/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant/proc/delhivetech()
	var/othertyrant = 0
	for(var/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant/HT in world)
		if(HT != src)
			othertyrant = 1
	if(othertyrant == 0)
		for(var/obj/machinery/hivemind_machine/NODE in world)
			NODE.destruct()

/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant/Life()

	. = ..()
	if(!.)
		walk(src, 0)
		return 0
	if(client)
		return 0
