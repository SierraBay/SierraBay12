/mob/living/exosuit/proc/add_pilot(mob/user)
	if (LAZYISIN(pilots, user))
		return
	user.forceMove(src)
	user.PushClickHandler(/datum/click_handler/default/mech)
	LAZYADD(pilots, user)
	if (user.client)
		user.client.screen |= hud_elements
		if(menu_status)
			user.client.screen |= menu_hud_elements
		if(hardpoints_menu_status)
			for(var/picked_hardpoint in hardpoint_hud_elements)
				var/obj/screen/movable/exosuit/hardpoint/hardpoint_screen_obj = hardpoint_hud_elements[picked_hardpoint]
				user.client.screen |= hardpoint_screen_obj
				if(hardpoint_screen_obj.holding)
					user.client.screen |= hardpoint_screen_obj.holding
		if(downside_menu_status)
			user.client.screen |= downside_menu_elements
	LAZYDISTINCTADD(user.additional_vision_handlers, src)
	GLOB.destroyed_event.register(user, src, .proc/remove_pilot)
	sync_access()
	update_pilots()
	need_update_sensor_effects = TRUE
	if(LAZYLEN(pilots) >= 0 )
		process_mech_vision = TRUE
	to_chat(user,SPAN_NOTICE("<b><font color = green> Нажмите СКМ для быстрой смены текущего модуля. </font></b>"))
	to_chat(user,SPAN_NOTICE("<b><font color = green> Нажмите ПРОБЕЛ для переключения режима стрейфа. </font></b>"))
	to_chat(user,SPAN_NOTICE("<b><font color = green> Основные органы управления скрыты в контекстном меню. Нажмите на кнопку ниже рук персонажа, кнопку слева сверху и кнопку справа (Состояние меха) для раскрытия контекстных меню меха. </font></b>"))


/// Removes a mob from the pilots list and destroyed event handlers. Called by the destroyed event.
/mob/living/exosuit/proc/remove_pilot(mob/user)
	if (!LAZYISIN(pilots, user))
		return
	user.RemoveClickHandler(/datum/click_handler/default/mech)
	if (!QDELETED(user))
		user.dropInto(loc)
	if (user.client)
		user.client.screen -= hud_elements
		if(hardpoints_menu_status == TRUE)
			for(var/picked_hardpoint in hardpoint_hud_elements)
				var/obj/screen/movable/exosuit/hardpoint/hardpoint_screen_obj = hardpoint_hud_elements[picked_hardpoint]
				user.client.screen -= hardpoint_screen_obj
				user.client.screen -=hardpoint_screen_obj.holding
		if(downside_menu_status)
			user.client.screen -= downside_menu_elements
		if(menu_status)
			user.client.screen -= menu_hud_elements
		user.client.eye = user
	LAZYREMOVE(user.additional_vision_handlers, src)
	LAZYREMOVE(pilots, user)
	GLOB.destroyed_event.unregister(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()
	clear_sensors_effects(user)
	//Отключаем процессинг зрения меха, если пилотов внутри нет
	if(LAZYLEN(pilots) <= 0 )
		process_mech_vision = FALSE

/mob/living/exosuit/proc/eject(mob/user, silent)
	if(!user || !(user in src.contents))
		return
	if(hatch_closed)
		if(hatch_locked)
			if(!silent)
				to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
			return
		open_hatch()
		update_icon()

	//Начинаем вылезать
	visible_message("\the [user] starts climbing out from [src].")
	if(!do_after(src, 3.5 SECONDS, src, DO_PUBLIC_UNIQUE))
		to_chat(user, SPAN_WARNING("Dont move when you trying leave mech."))
		return FALSE

	if(hatch_locked)
		return

	hatch_closed = FALSE
	update_icon()
	if(!silent)
		to_chat(user, SPAN_NOTICE("You climb out of \the [src]."))

	remove_pilot(user)
	return TRUE
