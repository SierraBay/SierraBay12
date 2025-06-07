/mob/living/exosuit
	var/obj/item/mech_component/manipulators/active_arm

//Здесь весь код отвечающий за то как пилот управляет мехом(Кликами). Кода много, потому всё определено в отдельный файл.
/mob/living/exosuit/ClickOn(atom/A, params, mob/user)
	//Пилот в состоянии действовать?
	if(!user || incapacitated() || user.incapacitated())
		return

	//Обработаем параметры(Альт, Шифт, Контрол и т.д) клика
	if(handle_click_params(A, params, user))
		return

	//Проверим то, может ли мех вообще действовать в текущих условиях?
	if(!check_exosuit_able_to_act(A, user))
		return

	if(user != src)
		mech_update_intent(user)

	if(A == src)
		setClickCooldown(5)
		return attack_self(user)

	//Перед вызовом использования модуля проверим, а не возникнет ли техническая неисправность
	if(selected_system)
		var/failed = FALSE
		check_click_fail(A, user,failed)
		mech_module_use_attempt(A, user,failed)
		return

	//В случае если интент стоит на ХАРМ - переходим к попытке атаковать лапой
	else if(A.Adjacent(src) && user.a_intent == I_HURT)
		attack_with_fists(A, user, active_arm)
	return


/mob/living/exosuit/proc/check_exosuit_able_to_act(atom/click_target, mob/living/user)
	if(click_target.loc != src && !(get_dir(src, click_target) & dir) || !loc)
		return FALSE
	//Юзера(Пилота) нет в пилотах, чего быть не может(Или может???).
	if(!(user in pilots) && user != src)
		return
	//Мех не имеет права кликать. К примеру, действует click cooldown
	if(!canClick())
		return
	//Теперь определимся какой конечностью мех пытается манипулировать
	var/L_arm_chosen = FALSE
	var/R_arm_chosen = FALSE
	var/body_chosen = FALSE
	if(selected_hardpoint == HARDPOINT_LEFT_HAND)
		L_arm_chosen = TRUE
	else if(selected_hardpoint == HARDPOINT_RIGHT_HAND)
		R_arm_chosen = TRUE
	else if(selected_hardpoint == HARDPOINT_BACK || selected_hardpoint == HARDPOINT_HEAD || selected_hardpoint == HARDPOINT_LEFT_SHOULDER || selected_hardpoint == HARDPOINT_RIGHT_SHOULDER)
		body_chosen = TRUE
	//Если у меха выбиты сервоприводы в руках и он пытается работать руками - пишем ему об этом
	if(L_arm_chosen && (!L_arm.motivator || !L_arm.motivator.is_functional()))
		to_chat(user, SPAN_WARNING("Left arm motivator damaged and can't be used"))
		setClickCooldown(15)
		return FALSE
	if(R_arm_chosen && (!R_arm.motivator || !R_arm.motivator.is_functional()))
		to_chat(user, SPAN_WARNING("Right arm motivator damaged and can't be used"))
		setClickCooldown(15)
		return FALSE
	//Любые модули которые ставятся НЕ на руки не могут быть применены, если состояние груди меха == 0
	if((!body || body.current_hp <= 0) && body_chosen)
		to_chat(user, SPAN_WARNING("Your cockpit too damaged, additional hardpoints control system damaged, you can't use this module!"))
		setClickCooldown(15)
		return FALSE
	//В случае если мех обесточен - не даём действовать
	if(!get_cell()?.checked_use(L_arm.power_use * CELLRATE))
		to_chat(user, power == MECH_POWER_ON ? SPAN_WARNING("Error: Power levels insufficient.") :  SPAN_WARNING("\The [src] is powered off."))
		return FALSE

	//Теперь, пройдя все проверки, можем продолжить главный код
	return TRUE

/mob/living/exosuit/proc/handle_click_params(atom/click_target, params, mob/living/pilot)
	//TRUE - обработали как надо и идти дальше по коду не нужно
	//FALSE - нужно продолжить обработку кода
	var/modifiers = params2list(params)
	//Быстрая смена текущего модуля меха. Смотри swap_hardpoint()
	if(modifiers["middle"])
		swap_hardpoint(pilot)
		return TRUE
	//Осмотр обьекта/моба/АТОМА
	else if(modifiers["shift"])
		examinate(pilot, click_target)
		return TRUE
	//Контрл клик по модулю
	else if(modifiers["ctrl"])
		if(selected_system)
			if(selected_system == click_target)
				selected_system.CtrlClick(pilot)
				setClickCooldown(3)
			return TRUE
	//Альт клик по модулю
	else if(modifiers["alt"])
		if(istype(click_target, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(click_target == hardpoints[hardpoint])
					click_target.AltClick(pilot)
					setClickCooldown(3)
					return TRUE
	else if(!show_right_click_menu)
		if(modifiers["right"])
			handle_right_and_left_click("right")
		else if(modifiers["left"])
			handle_right_and_left_click("left")
	return FALSE

//Задача функции сменить хардпоинт на левый или правый в зависимости от текущего состояния
/mob/living/exosuit/proc/handle_right_and_left_click(mouse_type)
	var/obj/screen/movable/exosuit/hardpoint = hardpoint_hud_elements[selected_hardpoint]
	if(!hardpoint) //Никакой модуль не выбран, тобишь мех хочет использовать лапы
		hardpoint = hardpoint_hud_elements[selected_hardpoint]
		return
	var/obj/screen/movable/exosuit/hardpoint/previous_hardpoint = hardpoint
	if(mouse_type == "left")
		if(!selected_hardpoint)
			set_hardpoint("left hand")
		if(selected_hardpoint == "right hand")
			set_hardpoint("left hand")
		else if(selected_hardpoint == "right shoulder")
			if(hardpoints.Find("left shoulder"))
				set_hardpoint("left shoulder")
	else if(mouse_type == "right")
		if(!selected_hardpoint)
			set_hardpoint("right hand")
		if(selected_hardpoint == "left hand" )
			set_hardpoint("right hand")
		else if(selected_hardpoint == "left shoulder")
			if(hardpoints.Find("right shoulder"))
				set_hardpoint("right shoulder")
	hardpoint = hardpoint_hud_elements[selected_hardpoint]
	update_selected_hardpoint(do_sound = FALSE, hardpoint = hardpoint, prev_hardpoint = previous_hardpoint)


///Обновит интент меха, взяв оный с последнего пилота.
/mob/living/exosuit/proc/mech_update_intent(mob/living/pilot)
	a_intent = pilot.a_intent
	if(pilot.zone_sel)
		zone_sel.set_selected_zone(pilot.zone_sel.selecting)
	else
		zone_sel.set_selected_zone(BP_CHEST)

///Проверим, возникла ли ошибка/неисправность при попытке использовать меха (Плохой скилл/ЭМИ)
/mob/living/exosuit/proc/check_click_fail(atom/movable/click_target, mob/living/pilot, input_var_failed)
	var/fail_prob = (pilot != src && istype(click_target) && click_target.loc != src) ? (pilot.skill_check(SKILL_MECH, HAS_PERK) ? 0: 15 ) : 0
	if(prob(fail_prob))
		to_chat(pilot, SPAN_DANGER("Your incompetence leads you to target the wrong thing with the exosuit!"))
		input_var_failed = TRUE
	else if(emp_damage > EMP_ATTACK_DISRUPT && prob(emp_damage*2))
		to_chat(pilot, SPAN_DANGER("The wiring sparks as you attempt to control the exosuit!"))
		input_var_failed = TRUE

/mob/living/exosuit/proc/mech_module_use_attempt(atom/movable/click_target, mob/living/pilot, input_failed_var)
	if(input_failed_var)
		var/list/other_atoms = orange(1, click_target)
		click_target = null
		while(LAZYLEN(other_atoms))
			var/atom/picked = pick_n_take(other_atoms)
			if(istype(picked) && picked.simulated)
				click_target = picked
				break
		if(!click_target)
			click_target = src
	//Если мы ошиблись - код сверху сменит цель.
	if(selected_system)
		//Проверка на СКИЛЛ
		if(selected_system.need_combat_skill())
			//Если мы не имеем права использовать боевое снаряжение - это конец
			if(!pilot.skill_check(SKILL_MECH, SKILL_TRAINED))
				to_chat(pilot, SPAN_WARNING("I don't know how to use combat modules!"))
				return
		if(selected_system == click_target)
			selected_system.attack_self(pilot) //Клик по самому модулю - самоатака у модуля(Смотри attack_self)
			setClickCooldown(5)
			return
	// Mounted non-exosuit systems have some hacky loc juggling
	// to make sure that they work.
	var/system_moved = FALSE
	var/obj/item/temp_system
	var/obj/item/mech_equipment/ME
	if(istype(selected_system, /obj/item/mech_equipment))
		ME = selected_system
		temp_system = ME.get_effective_obj()
		if(temp_system in ME)
			system_moved = TRUE
			temp_system.forceMove(src)
		else
			temp_system = selected_system


	var/adj = click_target.Adjacent(src)
	var/resolved
	if(adj)
		resolved = temp_system.resolve_attackby(click_target, src)
	if(!resolved && click_target && temp_system)
		temp_system.afterattack(click_target, src, adj)
	if(system_moved) //We are using a proxy system that may not have logging like mech equipment does
		admin_attack_log(pilot, click_target, "Attacked using \a [temp_system] (MECH)", "Was attacked with \a [temp_system] (MECH)", "used \a [temp_system] (MECH) to attack")
	//Mech equipment subtypes can add further click delays
	var/extra_delay = 0
	if(!isnull(selected_system))
		ME = selected_system
		extra_delay = ME.equipment_delay
	setClickCooldown(active_arm ? active_arm.action_delay + extra_delay : 15 + extra_delay)
	if(system_moved)
		temp_system.forceMove(selected_system)
		return
