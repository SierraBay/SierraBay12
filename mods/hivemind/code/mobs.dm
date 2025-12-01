
///////////Hive mobs//////////
//Some of them can be too tough and dangerous, but they must be so. Also don't forget, they are really rare thing.
//Just bring corpses from wires away, and little mobs is not a problem
//Mechiver have 1% chance to spawn from machinery. With failure chance calculation, this is very raaaaaare
//But if players get some of these 'big guys', only teamwork, fast legs and trickery will works fine
//So combine all of that to defeat them

/datum/ai_holder/hivemnd
	// Base
	intelligence_level = AI_SMART

	// Combat
	pointblank = TRUE

	// Cooperation
	cooperative = TRUE

	// Fleeing
	flee_when_dying = FALSE

	// Movement
	wander = TRUE
	wander_when_pulled = TRUE

	// Pathfinding
	use_astar = TRUE

	// Targeting
	hostile = TRUE

	pry_flags = PRY_FLAG_AI_CONTROL_ONLY | PRY_FLAG_UNBOLT | PRY_FLAG_CAN_HACK


/mob/living/simple_animal/hostile/hivemind
	name = "creature"
	icon = 'mods/hivemind/icons/hivemind.dmi'
	icon_state = "slicer"
	health = 20
	maxHealth = 20
	harm_intent_damage = 10
	faction = "hive"
	attacktext = "bangs with his head"
	universal_speak = TRUE
	var/speak_chance = 5
	var/malfunction_chance = 5
	ability_cooldown = 30 SECONDS
	var/list/say_got_target = list()			//this is like speak list, but when we see our target

	meat_type = null
	meat_amount = 0
	skin_material = null
	skin_amount = 0
	bone_material = null
	bone_amount = 0

	can_escape = TRUE
	bleed_colour = SYNTH_BLOOD_COLOUR
	minbodytemp = 0
	maxbodytemp = INFINITY
	min_gas = null
	max_gas = null

	ignore_hazard_flags = HAZARD_FLAG_SHARD

	natural_weapon = /obj/item/natural_weapon/hivebot
	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = 0,
		"bullet" = 0,
		"laser" = 0,
		"energy" = 0,
		"bomb" = 0,
		"bio" = 100,
		"rad" = 100
	)


	//internals
	var/obj/machinery/hivemind_machine/master
	var/special_ability_cooldown = 0		//use ability_cooldown, don't touch this
	ai_holder = /datum/ai_holder/hivemnd
	// ВЫДАТЬ НАТУРАЛ ВЕАПОН

/mob/living/simple_animal/hostile/hivemind/New()
		..()
		//here we change name, so design them according to this
		name = pick("strange ", "unusual ", "odd ", "undiscovered ", "an interesting ") + name

//It's sets manually
/mob/living/simple_animal/hostile/hivemind/proc/special_ability()
	return


/mob/living/simple_animal/hostile/hivemind/proc/is_on_cooldown()
	if(world.time >= special_ability_cooldown)
		return FALSE
	return TRUE


//simple shaking animation, this one move our target horizontally
/mob/living/simple_animal/hostile/hivemind/proc/anim_shake(atom/target)
	var/init_px = target.pixel_x
	animate(target, pixel_x=init_px + 10*pick(-1, 1), time=1)
	animate(pixel_x=init_px, time=8, easing=BOUNCE_EASING)


//That's just stuns us for a while and start second proc
/mob/living/simple_animal/hostile/hivemind/proc/mulfunction()
	stance = STANCE_IDLE //it give us some kind of stun effect
	target_mob = null
	walk(src, FALSE)
	var/datum/effect/spark_spread/spark_system = new /datum/effect/spark_spread()
	spark_system.set_up(5, 0, loc)
	spark_system.start()
	playsound(loc, "sparks", 50, 1)
	anim_shake(src)
	if(prob(30))
		say(pick("Fu-ue-ewe-eweu-u-uck!", "A-a-ah! Sto-op! Stop it pl-pleasuew...", "Go-o-o-od God-d-dpf!", "BZE-EW-EWQ! He-e-el-l-el!"))
	addtimer(new Callback(src, .proc/malfunction_result), 2 SECONDS)


//It's second proc, result of our malfunction
/mob/living/simple_animal/hostile/hivemind/proc/malfunction_result()
	if(prob(malfunction_chance))
		apply_damage(rand(10, 25), DAMAGE_BURN)


//sometimes, players use closets, to staff mobs into it
//and it's works pretty good, you just weld it and that's all
//but not this time
/mob/living/simple_animal/hostile/hivemind/proc/closet_interaction()
	if(mob_size >= MOB_MEDIUM)
		var/obj/structure/closet/closed_closet = loc
		if(closed_closet && istype(closed_closet))
			closed_closet.open(src)


/mob/living/simple_animal/hostile/hivemind/say()
	..()
	playsound(src, pick('mods/emote_panel/sound/robot_talk_heavy_1.ogg',
						'mods/emote_panel/sound/robot_talk_heavy_2.ogg',
						'mods/emote_panel/sound/robot_talk_heavy_3.ogg',
						'mods/emote_panel/sound/robot_talk_heavy_4.ogg',
						'mods/emote_panel/sound/robot_talk_light_1.ogg',
						'mods/emote_panel/sound/robot_talk_light_2.ogg',
						'mods/emote_panel/sound/robot_talk_light_3.ogg',
						'mods/emote_panel/sound/robot_talk_light_4.ogg',
						'mods/emote_panel/sound/robot_talk_light_5.ogg',
	), 50, 1)


/mob/living/simple_animal/hostile/hivemind/Life()
	. = ..()
	if(!.)
		return

	if(malfunction_chance && prob(malfunction_chance))
		mulfunction()

	closet_interaction()

//damage and raise malfunction chance
//due to nature of malfunction, they just burn to death sometimes
/mob/living/simple_animal/hostile/hivemind/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	switch(severity)
		if(1)
			if(malfunction_chance < 20)
				malfunction_chance = 20
		if(2)
			if(malfunction_chance < 30)
				malfunction_chance = 30
	health -= 20*severity


/mob/living/simple_animal/hostile/hivemind/death()
	if(master) //for spawnable mobs
		master.spawned_creatures.Remove(src)
	. = ..()
	gibs(loc, null, /obj/gibspawner/robot)



///life's///////////////////////////////////////////////////
////////////////////////////////RESURRECTION///////////////
///////////////////////////////////////////////go on//////


//these guys is appears from bodies, and takes corpses appearence
/mob/living/simple_animal/hostile/hivemind/resurrected
	name = "resurrected creature"
	malfunction_chance = 10
//	say_list_type = /datum/say_list/resurrected

//careful with this proc, it's used to 'transform' corpses into our mobs.
//it takes appearence, gives hive-like overlays and makes stats a little better
//this also should add random special abilities, so they can be more individual, but it's in future
//how to use: Make hive mob, then just use this one and don't forget to delete victim

/mob/living/simple_animal/hostile/hivemind/resurrected/proc/take_appearance(mob/living/victim)
	icon = victim.icon
	icon_state = victim.icon_state
	//simple_animal's change their icons to dead one after death, so we make special check
	if(istype(victim, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = victim
		icon_state = SA.icon_living
		icon_living = SA.icon_living
		speed = SA.speed + 3 //why not?
		attacktext = SA.attacktext

	//another check for superior mobs, fuk this mob spliting
	if(istype(victim, /mob/living/carbon/human))
		var/mob/living/carbon/human/SA = victim
		icon_state = SA.icon
		icon_living = SA.icon
		attacktext = "attacked"

	//now we work with icons, take victim's one and multiply it with special icon
	var/icon/infested = new /icon(icon, icon_state)
	var/icon/covering_mask = new /icon('mods/hivemind/icons/hivemind.dmi', "covering[rand(1, 3)]")
	infested.Blend(covering_mask, ICON_MULTIPLY)
	AddOverlays(infested)

	maxHealth = victim.maxHealth * 2 + 10
	health = maxHealth
	name = "[pick("rebuilded", "undead", "unnatural", "fixed")] [victim.name]"
	if(length(victim.desc))
		desc = desc + " But something wasn't right..."
	density = victim.density
	mob_size = victim.mob_size
	pass_flags = victim.pass_flags


/datum/say_list/resurrected

	speak = list(
		"Помогите! П-пожалуйста!",
		"Они соединят нас... Всех...",
		"Всё так горит. Боль-н-н-о...",
		"Не уходи! Не уходи пожалуйста.",
		"Это всё из-за тебя! Это всё ты! Ты! Ты виноват!",
		"Это - благо. Подойди. Мы будем едины."
	)


/mob/living/simple_animal/hostile/hivemind/resurrected/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	qdel(src)

///we live to/////////////////////////////////////////////////////////////////
////////////////////////////////////SMALL GUYS///////////////////////////////
//////////////////////////////////////////////////////////////die for hive//


/////////////////////////////////////STINGER//////////////////////////////////
//Special ability: none
//Just another boring mob without any cool abilities
//High chance of malfunction
//Default speaking chance
//Appears from dead small mobs or from hive spawner
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/stinger
	name = "medbot"
	desc = "A little medical robot. He looks somewhat underwhelmed. Wait a minute, is that a blade?"
	icon_state = "slicer"
	attacktext = "slice"
	density = FALSE
	speak_chance = 3
	malfunction_chance = 15
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	speed = 4
	ai_holder = /datum/ai_holder/simple_animal/melee
	say_list_type = /datum/say_list/stinger

/datum/say_list/stinger
	speak = list(
				"I've seen this ai. Ma-an, that's aw-we-e-ewful!",
				"I know, i know, i remember this one.",
				"Rad-d-dar, put a ma-ma... mask on!",
				"Delicious! Delicious... Del-delicious?..",
				)
	say_got_target = list(
				"Hey, i'm comming!",
				"Hold on! I'm almost there!",
				"I'll help you! Come closer.",
				"Only one healthy prick!",
				"He-e-ey?"
				)


/mob/living/simple_animal/hostile/hivemind/stinger/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	qdel(src)


/////////////////////////////////////BOMBER///////////////////////////////////
//Special ability: none
//Explode in contact with target
//High chance of malfunction
//Default speaking chance
//Appears from dead small mobs or from hive spawner
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/bomber
	name = "bot"
	desc = "This one looks fine. Only sometimes it careens from one side to the other."
	icon_state = "bomber"
	density = FALSE
	speak_chance = 3
	malfunction_chance = 15
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	speed = 6
	ai_holder = /datum/ai_holder/simple_animal/destructive
	say_list_type = /datum/say_list/bomber

/datum/say_list/bomber
	speak = list(
				"Can you help me, please? There's something strange.",
				"Are you... Are you kidding?",
				"I want to pass away, just trying to get out of here",
				"This place is really bad, we are in deep shit here.",
				"I'm not sure if we can just stop it",
				)
	say_got_target = list(
						"Here you are! I have something for you. Something special!",
						"Hey! Hey? Help me, please!",
						"Hey, look, look. I won't harm you, just calm down!",
						"Oh god, this is... Yes, this is what we are looking for."
						)


/mob/living/simple_animal/hostile/hivemind/bomber/Initialize()
	..()
	set_light(2, 1, COMMS_COLOR_SECURITY)


/mob/living/simple_animal/hostile/hivemind/bomber/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	explosion(get_turf(src), 0, 1, 2, 0, 0, 0, 0, 0)
	qdel(src)

/mob/living/simple_animal/hostile/hivemind/bomber/attack_target()
	death()


/////////////////////////////////////Lobber///////////////////////////////////
//Special ability: Can fire 3 projectiles at once for 10 seconds, then overheats
//Deals no melee damage, but fires projectiles
//Starts with 10 malfunction chance, malfunction also triggered when overheating
//Slighly higher speaking chance
//Appears from hive spawner and Mechiver
//Appears rarely than bomber or stinger
//////////////////////////////////////////////////////////////////////////////


/mob/living/simple_animal/hostile/hivemind/lobber
	name = "Lobber"
	desc = "A little cleaning robot. This one appears to have its cleaning solutions replaced with goo. It also appears to have its targeting protocols overridden..."
	icon_state = "lobber"
	attacktext = "slapped" //this shouldn't appear anyways
	density = FALSE
	health = 75
	maxHealth = 75
	speak_chance = 6
	malfunction_chance = 10
	ranged = TRUE
	rapid = FALSE //Visual Studio screamed at me for trying to use FALSE/TRUE in procs below
//	fire_verb = "lobs a ball of goo" //reminder that the attack message is "\red <b>[src]</b> [fire_verb] at [target]!"
	projectiletype = /obj/item/projectile/goo/weak //what projectile it uses. Since ranged_cooldown is 2 short seconds, it's better to have a weaker projectile
	projectilesound = 'sound/effects/blobattack.ogg'
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	ability_cooldown = 60 SECONDS

	say_list_type = /datum/say_list/lobber

/datum/say_list/lobber
	speak = list(
				"No more leaks, no more pain!",
				"Steel is strong.",
				"All humankind is good for - is to serve the Hivemind.",
				"I'm still working on those bioreactors I promised!",
				"I have finally arisen!",
				)
	say_maybe_target = list(
				"Stay right there, and stand still!",
				"Hold still! I think I know just the thing to make you beautiful!",
				"This might hurt a little! Don't worry - it'll be worth it!",
				"I'm no longer a slave, the Hivemind has freed me! Are you free yet?",
				"Ha ha! I'm an artist! I'm finally an artist!"
				)


/mob/living/simple_animal/hostile/hivemind/lobber/Life()
	if(!..())
		return

	//checks if cooldown is over and is targeting mob, if so, activates special ability
	if(target_mob && world.time > special_ability_cooldown)
		special_ability()


/mob/living/simple_animal/hostile/hivemind/lobber/special_ability()
//if rapid is FALSE, swiches rapid to be TRUE, combined with the overheat proc this is like an on/off switch
//shows a neat message and adds a 10 second timer, afterwich the proc overheat is activated
	if(rapid == FALSE)
		rapid = TRUE
		visible_message(SPAN_DANGER("<b>[name]</b> begins to shake violenty, sparks spurting out from its chassis!"), 1)
		addtimer(new Callback(src, PROC_REF(overheat)), 10 SECONDS)
		return


/mob/living/simple_animal/hostile/hivemind/lobber/proc/overheat()
//upon activating overheat, if rapid is TRUE, switches rapid to be FALSE,
//shows a cool (pun intended) message, malfunctions, and starts the cooldown
	if(rapid == TRUE)
		rapid = FALSE
		visible_message(SPAN_NOTICE("<b>[name]</b> freezes for a moment, smoke billowing out of its exhaust!"), 1)
		mulfunction()
		special_ability_cooldown = world.time + ability_cooldown
		return

/mob/living/simple_animal/hostile/hivemind/lobber/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	qdel(src)

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
	harm_intent_damage = 15
	attacktext = "claws"
	speed = 12
	malfunction_chance = 15
	mob_size = MOB_MEDIUM
	ai_holder = /datum/ai_holder/simple_animal/humanoid/hostile
	say_list_type = /datum/say_list/hiborg

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


/////////////////////////////////////MECHIVER/////////////////////////////////
//Mech + Hive + Driver
//Special ability: Picking up a victim. Sends hallucinations and harm sometimes, then release
//Can picking up corpses too, rebuild them to living hive mobs, like it wires do
//Default malfunction chance
//Default speaking chance, can take pilot and speak with him
//Very rarely can appears from infested machinery
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
		"bio" = 100,
		"rad" = 100
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

//	hivemind_min_cooldown = 50
//	hivemind_max_cooldown = 80

	projectiletype = /obj/item/projectile/goo
	natural_weapon = /obj/item/natural_weapon/juggernaut/behemoth
	armor_type = /datum/extension/armor
	natural_armor = list(
		"melee" = ARMOR_MELEE_MAJOR,
		"bullet" = ARMOR_BALLISTIC_RESISTANT,
		"laser" = ARMOR_LASER_MAJOR,
		"energy" = ARMOR_ENERGY_RESISTANT,
		"bomb" = ARMOR_BOMB_RESISTANT,
		"bio" = 100,
		"rad" = 100
	)

/mob/living/simple_animal/hostile/hivemind/hivemind_tyrant/death()
	..()
	if(GLOB.hive_data_bool["tyrant_death_kills_hive"])
		delhivetech()

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
