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
	//Если цель клика - лестница
	if(istype(A, /obj/structure/ladder))
		var/obj/structure/ladder/L = A
		L.climb(src)

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

///Мех атакует обьект/предмет лапой.
/mob/living/exosuit/proc/attack_with_fists(atom/click_target, mob/living/pilot)
	setClickCooldown(active_arm ? active_arm.action_delay : 7) // You've already commited to applying fist, don't turn and back out now!
	playsound(src.loc, L_leg.mech_step_sound, 60, 1)
	var/arms_local_damage = active_arm.melee_damage
	src.visible_message(SPAN_DANGER("\The [src] steps back, preparing for a strike!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
	if (do_after(src, 1.2 SECONDS, get_turf(src), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && src)
		add_heat(active_arm.heat_generation)
		//Если расстояние между целью оказалось слишком большой (больше 1 тайла) - мы мажем
		if (get_dist(src, click_target) > 1.5)
			src.visible_message(SPAN_DANGER(" [src] misses with his attack!"))
			setClickCooldown(active_arm ? active_arm.action_delay : 7)
			playsound(src.loc, active_arm.punch_sound, 50, 1)
			return
		//Проверяем обьект на момент особых взаимодействий. Если их нет - атакуем.
		if(!click_target.mech_fist_interaction(src, pilot, arms_local_damage, active_arm))
			click_target.attack_generic(src, arms_local_damage, "strikes", DAMAGE_BRUTE) //Мех именно атакует своей лапой обьект
			var/turf/T = get_turf(click_target)
			if(ismob(click_target))
				var/mob/target = click_target
				if(!target.lying && target.mob_size < mob_size)
					target.throw_at(get_ranged_target_turf(target, get_dir(src, target), 1),1, 1, src, TRUE)
					target.Weaken(1)
			do_attack_effect(T, "smash")
			playsound(src.loc, active_arm.punch_sound, 50, 1)
			setClickCooldown(active_arm ? active_arm.action_delay : 7)




/*Функция вызываемая, когда обьект атакуется лапами меха
*TRUE - атаковать не нужно, мех уже как-то повзаимодействовал по особенному. К примеру, открыл шлюз.
*FALSE - нужно нанести удар, т.к нет особого взаимодействия (Условно нельзя раскрыть шлюз)
*/
/atom/proc/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	return

//Аир лок
/obj/machinery/door/firedoor/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(!blocked)
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/door/firedoor, toggle), TRUE), 0)
		return TRUE
	return FALSE

//Крепкие бласты(оружейка СБ)
/obj/machinery/door/blast/regular/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/door/blast, force_toggle), TRUE), 0)
		return TRUE
	//Всё равно возвращаем TRUE, чтоб мех не ударял
	to_chat(pilot, SPAN_NOTICE("This structure too reinforced for being damaged by [src]!"))
	return TRUE

/obj/machinery/door/blast/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/door/blast, force_toggle), TRUE), 0)
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE

//Обычные бласты(в карго)
/obj/machinery/door/blast/shutters/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/door/blast/shutters, force_toggle), TRUE), 0)
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE

//Шлюз. Откроет, если выбита/не работает.
/obj/machinery/door/mech_fist_interaction(mob/living/exosuit/mech, mob/living/pilot, mech_fist_damage, obj/item/mech_component/manipulators/active_arm)
	if(inoperable() || !is_powered())
		mech.setClickCooldown(mech.active_arm ? mech.active_arm.action_delay : 7)
		addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/door, toggle), TRUE), 0)
		return TRUE
	mech_fist_damage = mech_fist_damage * 2
	return FALSE

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
	return FALSE

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
	//if(adj)
	resolved = temp_system.resolve_attackby(click_target, src)
	if(!resolved && click_target && temp_system)
		var/mob/ruser = src
		if(!system_moved) //It's more useful to pass along clicker pilot when logic is fully mechside
			ruser = pilot
			temp_system.afterattack(click_target,ruser,adj)
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
