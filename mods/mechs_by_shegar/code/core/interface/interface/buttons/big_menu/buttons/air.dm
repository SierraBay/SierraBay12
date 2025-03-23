/obj/screen/exosuit/menu_button/air
	name = "Подача воздуха"
	icon_state = "air"
	button_desc = "Герметизирует кабину и начинает подачу чистого воздуха. <br> WARNING: Без этой кнопки, вы будете страдать от внешней атмосферы <br> -Shift + ЛКМ Выводит информацию о безопасной температуры внешней среды для меха <br> -Alt + ЛКМ анализирует внешнюю среду вне меха <br> -Cntrl + ЛКМ заменяет воздух в мехе форсированно на чистый и безопасный."
	switchable = TRUE

/obj/screen/exosuit/menu_button/air/switch_on()
	owner.use_air = TRUE
	to_chat(usr, SPAN_NOTICE("Auxiliary atmospheric system enabled."))
	playsound(src.loc, 'sound/effects/turret/open.wav', 50, 1, -6)
	return TRUE

/obj/screen/exosuit/menu_button/air/switch_off()
	owner.use_air = FALSE
	to_chat(usr, SPAN_NOTICE("Auxiliary atmospheric system disabled."))
	playsound(src.loc, 'sound/effects/turret/open.wav', 50, 1, -6)
	return TRUE

/obj/screen/exosuit/menu_button/air/Click(location, control, params)
	press_animation()
	var/modifiers = params2list(params)
	if(modifiers["shift"])
		if(owner && owner.material)
			usr.show_message(SPAN_NOTICE("Your mech's safe operating limit ceiling is [("[owner.material.melting_point - T0C] °C")]."), VISIBLE_MESSAGE)
		return
	if(modifiers["alt"])
		if(owner && owner.body && owner.body.diagnostics?.is_functional() && owner.loc)
			usr.show_message(SPAN_NOTICE("The life support panel blinks several times as it updates:"), VISIBLE_MESSAGE)
			usr.show_message(SPAN_NOTICE("Chassis heat probe reports temperature of [("[owner.bodytemperature - T0C] °C" )]."), VISIBLE_MESSAGE)
			if(owner.material.melting_point < owner.bodytemperature)
				usr.show_message(SPAN_WARNING("Warning: Current chassis temperature exceeds operating parameters."), VISIBLE_MESSAGE)
			var/air_contents = owner.loc.return_air()
			if(!air_contents)
				usr.show_message(SPAN_WARNING("The external air probe isn't reporting any data!"), VISIBLE_MESSAGE)
			else
				usr.show_message(SPAN_NOTICE("External probes report: [jointext(atmosanalyzer_scan(owner.loc, air_contents), "<br>")]"), VISIBLE_MESSAGE)
		else
			usr.show_message(SPAN_WARNING("The life support panel isn't responding."), VISIBLE_MESSAGE)
		return
	if(modifiers["ctrl"])
		owner.body.atmos_clear_protocol(usr)
		return
	.=..()
