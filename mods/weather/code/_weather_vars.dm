/mob/living
	var/last_monitor_message = 0

//Наложит игроку на экран эффект, уберёт его, а так же может дополнительно начать влиять на существо.
/obj/weather
	//Путь до эффекта накладываемого на экран
	var/effect_icon_type
	icon = 'mods/weather/icons/weather_effects.dmi'
	var/sound_type = list()
	///Должнен ли монитор эффект реагировать на пересечение с кем-либо или чем-либо
	var/must_react_at_enter = FALSE
	anchored = TRUE
	invisibility = TRUE
	layer = EFFECTS_LAYER
	vis_flags = VIS_INHERIT_ID
	var/trigger_message_cooldown = 10 MINUTES
	mouse_opacity = FALSE //Погода должна быть непрокликиваемой
