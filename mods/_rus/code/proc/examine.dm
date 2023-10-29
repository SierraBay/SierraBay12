/atom/examine(mob/user, distance, is_adjacent, infix = "", suffix = "")
	//if(FALSE /*client.get_preference_value(умнаяхуйня/language) == GLOB.PREF_LANG_EN*/ ) return ..()
	var/f_name = "<b>[name_rus][infix].</b>"
	if(blood_color && !istype(src, /obj/decal))
		f_name = "[name_rus][infix]. Видны следы крови!"

	to_chat(user, "[icon2html(src, user)] Это [f_name] [suffix]")
	to_chat(user, desc_rus)
	if (get_max_health())
		examine_damage_state(user)

	if (IsFlameSource())
		to_chat(user, SPAN_DANGER("Виден открытый огонь."))
	else if (distance <= 1 && IsHeatSource())
		to_chat(user, SPAN_WARNING("Слишком горячо для касания."))

	return TRUE
