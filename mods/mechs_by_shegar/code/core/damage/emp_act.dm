/mob/living/exosuit/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if (status_flags & GODMODE)
		return
	//В случае если у меха есть ЭНЕРГОЩИТ - мы передадим ЭМИ по нему и перестанем идти дальше по коду
	for(var/obj/aura/mechshield/thing in auras)
		if(thing.active)
			thing.emp_attack(severity)
			return
	var/ratio = get_blocked_ratio(null, DAMAGE_BURN, null, (3-severity) * 20) // HEAVY = 40; LIGHT = 20
	//Добавит игроку на экран глитчей из-за ЭМИ.
	add_glitch_effects()
	//В зависимости от типа брони меха - выведем в чат сообщение
	if(ratio >= 0.5)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding absorbed the pulse!"))
	else if(ratio > 0)
		for(var/mob/living/m in pilots)
			to_chat(m, SPAN_NOTICE("Your Faraday shielding mitigated the pulse!"))
	//ЭМИ на меха работает лишь в том случае, если он запитан
	if(power == MECH_POWER_ON)
		setClickCooldown(10) //Орудия и модули на КД
		current_speed = min_speed //Убьём скорость меха
		for(var/obj/item/mech_component/thing in list(head, body, L_arm, R_arm, L_leg, R_leg))
			//Выполнение этой функции с результатом TRUE Означает что мех вследствии перегрева этой части перегрелся.
			if(thing.emp_heat(severity, ratio, src)) //Греем конечности
				break
	//Если кабина меха не закрыта - воздействуем и на пилота.
	if(!hatch_closed || !prob(body.pilot_coverage))
		for(var/thing in pilots)
			var/mob/pilot = thing
			pilot.emp_act(severity)
