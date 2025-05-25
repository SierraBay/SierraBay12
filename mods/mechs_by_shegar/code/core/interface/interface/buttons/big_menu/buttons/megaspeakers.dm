/obj/screen/exosuit/menu_button/megaspeakers
	name = "Громкоговорители"
	button_desc = "Позволяет громко и чётко говорить с помощью громкоговорителя меха. <br> -При нажатии ALT + ЛКм позволяет заранее записать фразу, -При нажатии ПКМ позволяет быстро проиграть записанную фразу. Работает и с быстрой кнопкой. Если пилот в интенте HARM, мех рыкнет при озвучке."
	icon_state = "megaspeakers"
	//Сообщение которое запомнил мех. Оно будет выводится при нажатии ПКМ по нему.
	var/remembered_message
	var/next_possible_rightclick
	var/rightclick_cooldown = 5 SECONDS

/obj/screen/exosuit/menu_button/megaspeakers/activated()
	if (usr.client)
		if(usr.client.prefs.muted & MUTE_IC)
			to_chat(usr, SPAN_WARNING("You cannot speak in IC (muted)."))
			return
	if(owner.power != MECH_POWER_ON)
		to_chat(usr, SPAN_WARNING("The power indicator flashes briefly."))
		return
	if(!(usr in owner.pilots))
		return
	var/message = sanitize(input(usr, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	do_message(message)

/obj/screen/exosuit/menu_button/megaspeakers/proc/do_message(message)
	message = capitalize(message)
	owner.audible_message("[FONT_GIANT("\ [owner] integrated megaspeaker speaks: [message]\"")]",10)
	runechat_message("[message]")


/obj/screen/exosuit/menu_button/megaspeakers/alt_press(mob/living/user)
	.=..()
	remember_message(user)


/obj/screen/exosuit/menu_button/megaspeakers/proc/remember_message(mob/living/user)
	remembered_message = sanitize(input(usr, "Что запомним?", "Megaphone", null)  as text)

/obj/screen/exosuit/menu_button/megaspeakers/right_click(mob/living/user)
	. = ..()
	if(!remembered_message)
		to_chat(user, SPAN_WARNING("Нет запомненных сообщений."))
		return
	if(next_possible_rightclick && next_possible_rightclick > world.time)
		to_chat(user, SPAN_WARNING("Слишком рано"))
		return
	next_possible_rightclick = world.time + rightclick_cooldown
	do_message(remembered_message)
	if(user.a_intent == I_HURT)
		owner.do_combat_scream()

/mob/living/exosuit/proc/do_combat_scream()
	var/sound = pick('mods/mechs_by_shegar/sounds/mech_warcry1.ogg', 'mods/mechs_by_shegar/sounds/mech_warcry2.ogg', 'mods/mechs_by_shegar/sounds/mech_warcry3.ogg')
	playsound(get_turf(src), sound, 150, TRUE)
