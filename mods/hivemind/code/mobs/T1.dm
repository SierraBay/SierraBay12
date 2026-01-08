/// Tier One Hivemind mobs
/// Не самые сильные, но надоедливые и опасные в больших количествах

///////////Hive mobs//////////
//Some of them can be too tough and dangerous, but they must be so. Also don't forget, they are really rare thing.
//Just bring corpses from wires away, and little mobs is not a problem
//Mechiver have 1% chance to spawn from machinery. With failure chance calculation, this is very raaaaaare
//But if players get some of these 'big guys', only teamwork, fast legs and trickery will works fine
//So combine all of that to defeat them

/datum/ai_holder/hivemind
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

	// Shooting
	firing_lanes = TRUE

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
		"bio" = ARMOR_BIO_SHIELDED,
		"rad" = ARMOR_RAD_SHIELDED
	)


	//internals
	var/obj/machinery/hivemind_machine/master
	var/special_ability_cooldown = 0		//use ability_cooldown, don't touch this
	ai_holder = /datum/ai_holder/hivemind

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
	explosion(get_turf(src), 2, EX_ACT_LIGHT, turf_breaker = FALSE)
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


/////////////////////////////////////HOUND//////////////////////////////////
//Special ability: none
//Fast and furious
//High chance of malfunction
//No speaking chance
//Appears from dead small mobs or from hive spawner
//////////////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/hivemind/hound
	name = "strange beast"
	desc = "A strange four-legged creature with a long trunk and many appendages on its back."
	icon_state = "hound"
	attacktext = "slice"
	density = FALSE
	speak_chance = 3
	malfunction_chance = 15
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	speed = 14
	movement_cooldown = 0
	natural_weapon = /obj/item/natural_weapon/claws

/mob/living/simple_animal/hostile/hivemind/hound/death()
	..()
	gibs(loc, null, /obj/gibspawner/robot)
	qdel(src)
