/mob/living
	var/last_monitor_message = 0

//Наложит игроку на экран эффект, уберёт его, а так же может дополнительно начать влиять на существо.
/obj/monitor_effect_triger
	//Путь до эффекта накладываемого на экран
	var/effect_icon_type
	var/sound_type = list()
	///Должнен ли монитор эффект реагировать на пересечение с кем-либо или чем-либо
	var/must_react_at_enter = FALSE
	anchored = TRUE
	invisibility = TRUE
	layer = EFFECTS_LAYER
	vis_flags = VIS_INHERIT_ID
	//Лист сообщений выводимые в чат игроку при входе в зону
	var/list/trigger_messages_list = list()
	var/trigger_message_cooldown = 10 MINUTES
	mouse_opacity = FALSE //Погода должна быть непрокликиваемой
