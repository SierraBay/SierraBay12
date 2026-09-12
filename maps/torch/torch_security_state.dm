#ifndef PSI_IMPLANT_AUTOMATIC
#define PSI_IMPLANT_AUTOMATIC "Security Level Derived"
#endif
#ifndef PSI_IMPLANT_SHOCK
#define PSI_IMPLANT_SHOCK     "Issue Neural Shock"
#endif
#ifndef PSI_IMPLANT_WARN
#define PSI_IMPLANT_WARN      "Issue Reprimand"
#endif
#ifndef PSI_IMPLANT_LOG
#define PSI_IMPLANT_LOG       "Log Incident"
#endif
#ifndef PSI_IMPLANT_DISABLED
#define PSI_IMPLANT_DISABLED  "Disabled"
#endif

/datum/map/torch // setting the map to use this list
	security_state = /singleton/security_state/default/torchdept

//Torch map alert levels. Refer to security_state.dm.
/singleton/security_state/default/torchdept
	all_security_levels = list(/singleton/security_level/default/torchdept/code_green, /singleton/security_level/default/torchdept/code_violet, /singleton/security_level/default/torchdept/code_orange, /singleton/security_level/default/torchdept/code_blue, /singleton/security_level/default/torchdept/code_red, /singleton/security_level/default/torchdept/code_delta)

/singleton/security_level/default/torchdept
	icon = 'maps/torch/icons/security_state.dmi'

/singleton/security_level/default/torchdept/code_green
	name = "code green"
	icon = 'icons/misc/security_state.dmi'
	alarm_level = "off"

	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_GREEN
	light_color_status_display = COLOR_GREEN

	overlay_alarm = "alarm_green"
	overlay_status_display = "status_display_green"
	alert_border = "alert_border_green"

	var/static/datum/announcement/priority/security/security_announcement_green = new(do_log = 0, do_newscast = 1, new_sound = sound('sound/misc/notice2.ogg'))

/singleton/security_level/default/torchdept/code_green/switching_down_to()
	security_announcement_green.Announce("Угрозы для судна и его экипажа отсутствуют. \
	Персоналу следует вернуться к выполнению рабочих обязанностей в штатном режиме.", "Внимание! Зелёный код")
	notify_station()

/singleton/security_level/default/torchdept/code_violet
	name = "code violet"
	alarm_level = "on"

	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_VIOLET
	light_color_status_display = COLOR_VIOLET

	psionic_control_level = PSI_IMPLANT_LOG

	overlay_alarm = "alarm_violet"
	overlay_status_display = "status_display_violet"
	alert_border = "alert_border_violet"

	up_description = "На судне находятся нелокализованные вредоносные патогены. Всему медицинскому персоналу требуется обратиться к вышестоящим сотрудникам для получения инструкций. Не-медицинскому персоналу следует выполнять инструкции от медицинского персонала."
	down_description = "На судне находятся нелокализованные вредоносные патогены. Всему медицинскому персоналу требуется обратиться к вышестоящим сотрудникам для получения инструкций. Не-медицинскому персоналу следует выполнять инструкции от медицинского персонала."

/singleton/security_level/default/torchdept/code_orange
	name = "code orange"
	alarm_level = "on"

	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_ORANGE
	light_color_status_display = COLOR_ORANGE
	overlay_alarm = "alarm_orange"
	overlay_status_display = "status_display_orange"
	alert_border = "alert_border_orange"

	psionic_control_level = PSI_IMPLANT_LOG

	up_description = "Тяжелые нарушения в работе оборудования и повреждение переборок. Всему инженерному персоналу требуется обратиться к вышестоящим сотрудникам для получения инструкций. Весь не-инженерный персонал должен покинуть затронутые повреждениями отсеки. Рекомендуется ношение скафандров и следование указаниям инженерного персонала."
	down_description = "Тяжелые нарушения в работе оборудования и повреждение переборок. Всему инженерному персоналу требуется обратиться к вышестоящим сотрудникам для получения инструкций. Весь не-инженерный персонал должен покинуть затронутые повреждениями отсеки. Рекомендуется ношение скафандров и следование указаниям инженерного персонала."


/singleton/security_level/default/torchdept/code_blue
	name = "code blue"
	icon = 'icons/misc/security_state.dmi'
	alarm_level = "on"

	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_BLUE
	light_color_status_display = COLOR_BLUE
	overlay_alarm = "alarm_blue"
	overlay_status_display = "status_display_blue"
	alert_border = "alert_border_blue"

	psionic_control_level = PSI_IMPLANT_LOG

	up_description = "Согласно полученной информации на судне может присутствовать угроза для безопасности экипажа. Всей охране требуется обратиться к вышестоящим сотрудникам для получения указаний; разрешено обыскивать сотрудников и отсеки, а также держать оружие на виду."
	down_description = "Потенциальная угроза для экипажа. Всей охране требуется обратиться к вышестоящим сотрудникам для получения указаний; разрешено обыскивать сотрудников и отсеки, а также держать оружие на виду."

/singleton/security_level/default/torchdept/code_red
	name = "code red"
	icon = 'icons/misc/security_state.dmi'
	alarm_level = "on"
	alarm_sound = 'sound/obj/machinery/rotating_alarm/alert_red.ogg'

	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_RED
	overlay_alarm = "alarm_red"
	overlay_status_display = "status_display_red"
	alert_border = "alert_border_red"

	up_description = "На судно объявлено чрезвычайное положение. Весь экипаж должен обратиться к главам для получения инструкций. Охране разрешено обыскивать сотрудников и отсеки, а так же держать оружие на виду."
	psionic_control_level = PSI_IMPLANT_DISABLED

	var/static/datum/announcement/priority/security/security_announcement_red = new(do_log = 0, do_newscast = 1, new_sound = sound('sound/misc/redalert1.ogg'))

/singleton/security_level/default/torchdept/code_red/switching_up_to()
	security_announcement_red.Announce(up_description, "Внимание! Красный код")
	notify_station()
	GLOB.using_map.unbolt_saferooms()

/singleton/security_level/default/torchdept/code_red/switching_down_to()
	security_announcement_red.Announce("Взрывное устройство было обезврежено. Весь экипаж должен обратиться к главам для получения инструкций. Охране разрешено обыскивать сотрудников и отсеки, а так же держать оружие на виду.", "Внимание! Код угрозы понижен до Красного")
	notify_station()

/singleton/security_level/default/torchdept/code_delta
	name = "code delta"
	icon = 'icons/misc/security_state.dmi'
	alarm_level = "on"
	alarm_sound = 'sound/obj/machinery/rotating_alarm/alert_red.ogg'

	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_NAVY_BLUE

	overlay_alarm = "alarm_delta"
	overlay_status_display = "status_display_delta"
	alert_border = "alert_border_delta"

	var/static/datum/announcement/priority/security/security_announcement_delta = new(do_log = 0, do_newscast = 1, new_sound = sound('sound/effects/siren.ogg'))

/singleton/security_level/default/torchdept/code_delta/switching_up_to()
	security_announcement_delta.Announce("Внимание всему персоналу! Код Дельта. Устройство самоуничтожения судна приведено в боевую готовность. Это не учебная тревога.", "Внимание! Код Дельта")
	notify_station()

#undef PSI_IMPLANT_AUTOMATIC
#undef PSI_IMPLANT_SHOCK
#undef PSI_IMPLANT_WARN
#undef PSI_IMPLANT_LOG
#undef PSI_IMPLANT_DISABLED
