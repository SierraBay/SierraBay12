/obj/effect/temp_visual/pulse
	icon ='icons/effects/effects.dmi'
	icon_state = "emppulse"
	duration = 10

/obj/effect/temp_visual/sparkles
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 8

// Real runtime cat

var/global/cat_number = 0
/mob/living/simple_animal/passive/cat/real_runtime
	name = "Tracy"
	desc = "Мурлыкающая жертва экспериментов. Пробирается в наше измерение, когда сама вуаль реальности разрывается на части."
	icon = 'mods/bluespace_kitty/runtimecat.dmi'
	icon_state = "runtimecat"
	density = FALSE
	universal_speak = TRUE

	a_intent = I_HURT

	status_flags = GODMODE // Bluespace cat
	min_oxy = 0
	minbodytemp = 0
	maxbodytemp = INFINITY

	attacktext = "slashed"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	var/const/cat_life_duration = 1 MINUTES


/mob/living/simple_animal/passive/cat/real_runtime/Initialize(mapload, runtime_line)
	. = ..()
	cat_number += 1
	playsound(loc, 'sound/magic/blink.ogg', 50)
	new /obj/effect/temp_visual/pulse(loc)
	new /obj/effect/temp_visual/sparkles(loc)

	addtimer(new Callback(src, .proc/back_to_bluespace), cat_life_duration)
	addtimer(new Callback(src, .proc/say_runtime, runtime_line), 5 SECONDS)

	for(var/i in rand(1, 3))
		step(src, pick(GLOB.alldirs))

/mob/living/simple_animal/passive/cat/real_runtime/attackby(obj/item/O, mob/living/user)
	. = ..()
	if(.)
		visible_message(SPAN_DANGER("[user]'s [O.name] harmlessly passes through \the [src]."))
		strike_back(user)


// It's easier to do this than to climb into a combos
/mob/living/simple_animal/passive/cat/real_runtime/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)

		if(I_HELP)
			M.visible_message(SPAN_NOTICE("[M] pets \the [src]."))

		if(I_DISARM)
			M.visible_message(SPAN_NOTICE("[M]'s hand passes through \the [src]."))
			M.do_attack_animation(src)

		if(I_GRAB)
			if(M == src)
				return
			if(!(status_flags & CANPUSH))
				return

			M.visible_message(SPAN_NOTICE("[M]'s hand passes through \the [src]."))
			M.do_attack_animation(src)

		if(I_HURT)
			M.visible_message(SPAN_WARNING("[M] tries to kick \the [src] but [M.gender == FEMALE ? "her" : "his"] foot passes through."))
			M.do_attack_animation(src)
			visible_message(SPAN_WARNING("\The [src] hisses."))
			strike_back(M)

/mob/living/simple_animal/passive/cat/real_runtime/proc/say_runtime(runtime_line)
	if(!runtime_line)
		return
	var/text = "Зафиксирована аномалия #'[runtime_line]'. Пожалуйста, отойдите подальше."
	say(text)

/mob/living/simple_animal/passive/cat/real_runtime/proc/back_to_bluespace()
	qdel(src)

/mob/living/simple_animal/passive/cat/real_runtime/proc/strike_back(mob/living/target_mob)
	if(!Adjacent(target_mob))
		return
	target_mob.attack_generic(src)

/mob/living/simple_animal/passive/cat/real_runtime/bullet_act(obj/item/projectile/proj)
	return PROJECTILE_FORCE_MISS

/mob/living/simple_animal/passive/cat/real_runtime/ex_act(severity)
	return

/mob/living/simple_animal/passive/cat/real_runtime/singularity_act()
	return

/mob/living/simple_animal/passive/cat/real_runtime/MouseDrop(atom/over_object)
	return
