//СКАЛОЛАЗАНЬЕ
/turf/simulated
	//Можно ли по данной стене взобраться вверх
	var/climbable = FALSE
	var/busy_by_climber = FALSE
	var/pickaxe_helps_in_climbing = FALSE

/turf/simulated/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(climbable)
		to_chat(user, SPAN_GOOD("Перетащите спрайт персонажа на гору для скалолазанья."))

/turf/simulated/MouseDrop_T(mob/living/target, mob/living/user)
	if(climbable)
		if(user.can_overcome_gravity() || user.is_floating)
			to_chat(user, SPAN_NOTICE("Мне не требуется."))
			return
		if(busy_by_climber)
			to_chat(user, SPAN_BAD("Кто-то тут уже лезет."))
			return
		if(!user || !ishuman(user) || target != user)
			return
		var/mob/living/carbon/human/human = user
		if(human.get_stamina() < 50)
			to_chat(human, SPAN_BAD("Я слишком устал!"))
			return
		visible_message(message = "[user] начинает взбираться вверх по склону.", range =  5)
		var/teamplay = check_teamplay(user)
		if(teamplay)
			to_chat(human, SPAN_GOOD("С протянутой рукой помощи, взбираться куда проще!"))
		if(!do_after(user, (6 SECONDS - (1 SECONDS *user.get_skill_value(SKILL_HAULING)))))
			climb_fail(user)
			busy_by_climber = FALSE
			return
		climb_to_wall(user)
		return
	. = ..()

/turf/simulated/proc/climb_to_wall(mob/user)
	if(!calculate_climbing_chances(user))
		climb_fail(user) //Увы не смог
	else //смог
		user.forceMove(src)
		to_chat(user, SPAN_GOOD("Вы успешно взбираетесь по склону."))
	busy_by_climber = FALSE

/turf/simulated/proc/try_move_from_wall(mob/user, turf/new_turf)
	if(busy_by_climber)
		to_chat(user, SPAN_NOTICE("Кто-то тут уже поднимается."))
		return
	busy_by_climber = TRUE
	if(!do_after(user, (6 SECONDS - (1 SECONDS *user.get_skill_value(SKILL_HAULING)))))
		return
	climb_from_wall(user, new_turf)

/turf/simulated/proc/climb_from_wall(mob/user, turf/new_turf)
	busy_by_climber = FALSE
	user.forceMove(new_turf) //Перс в любом случае спустится


/turf/simulated/mineral/ice/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(ishuman(mover))
		var/mob/living/carbon/human/human = mover
		if(istype(get_turf(mover), /turf/simulated/mineral/ice) && !human.can_overcome_gravity() && !human.is_floating)
			return FALSE
		else if(human.can_overcome_gravity() || human.is_floating)
			return TRUE
	. = ..()

/turf/simulated/mineral/ice/use_tool(obj/item/W, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return

/turf/simulated/mineral/ice/Exit(O, newloc)
	if(ishuman(O))
		var/mob/living/carbon/human/human = O
		if(!istype(newloc, /turf/simulated/mineral/ice) && !human.can_overcome_gravity() && !human.is_floating)
			try_move_from_wall(human, newloc)
			return
		else
			human.forceMove(newloc)
			return
	.=..()

/turf/simulated/proc/climb_fail(mob/living/carbon/human/user)
	to_chat(user, SPAN_BAD("Вы срываетесь вниз со скалы."))
	user.adjust_stamina(-50)
	for(var/picked_organ in list(BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT))
		user.apply_damage(5, DAMAGE_BRUTE, picked_organ, used_weapon="Gravitation")

//Проверяет помогает ли кто-то взбирающемуся по горе
/turf/simulated/proc/check_teamplay(mob/user)
	for(var/mob/living/carbon/human/helper in src) //На турф лезут, на нём и чекают
		if(helper.a_intent == I_HELP && turn(user.dir, 180) == helper.dir)
			return TRUE

/turf/simulated/proc/calculate_climbing_chances(mob/user, silent = FALSE)
	var/result = 0
	var/result_output
	//ПОМОЩЬ
	if(check_teamplay(user))
		result += 100 //Напарник гарантированно затянет к себе вверх
		result_output += SPAN_GOOD("<br> С протянутой рукой помощи, сложно не взобраться!")
	else
		result_output += SPAN_BAD("<br> Рука помощи бы тут не помешала...")
	//КИРКА
	if(pickaxe_helps_in_climbing && user.IsHolding(/obj/item/pickaxe))
		result += 70
		result_output += SPAN_GOOD("<br>Куда легче взбираться вверх с киркой!")
	else
		result_output += SPAN_BAD("<br> Кирка бы тут не помешала...")
	//АТЛЕТИКА
	result += (10 * user.get_skill_value(SKILL_HAULING))
	if(!silent)
		to_chat(user, result_output)
	if(prob(result))
		return TRUE
	else
		return FALSE

/turf/simulated/proc/do_climb_animation(mob/user, turf/new_turf)
	var/x_anim
	var/y_anim
	switch(get_dir(user, new_turf))
		if(NORTH)
			y_anim = 16
		if(SOUTH)
			y_anim = -16
		if(WEST)
			x_anim = -16
		if(EAST)
			x_anim = 16
	animate(user, time = 1 SECONDS, pixel_x = x_anim, pixel_y = y_anim, easing = LINEAR_EASING )

/turf/simulated/mineral/ice
	climbable = TRUE
	pickaxe_helps_in_climbing = TRUE
