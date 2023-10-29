/atom/examine(mob/user, distance, is_adjacent, infix = "", suffix = "")
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

/obj/examine(mob/user)
	. = ..()
	if((obj_flags & OBJ_FLAG_ROTATABLE))
		to_chat(user, SPAN_SUBTLE("Может быть повернут при нажатии ALT + ЛКМ."))

/obj/item/examine(mob/user, distance, is_adjacent)
	var/size
	switch(src.w_class)
		if(ITEM_SIZE_TINY)
			size = "крошечного"
		if(ITEM_SIZE_SMALL)
			size = "маленького"
		if(ITEM_SIZE_NORMAL)
			size = "среднеого"
		if(ITEM_SIZE_LARGE)
			size = "большого"
		if(ITEM_SIZE_HUGE)
			size = "массивного"
		if(ITEM_SIZE_HUGE + 1 to INFINITY)
			size = "гигантского"
	var/desc_comp = ""
	desc_comp += "Этот предмет [size] размера."

	if(hasHUD(user, HUD_SCIENCE))
		desc_comp += "<BR>*--------* <BR>"

		if(origin_tech)
			desc_comp += "[SPAN_NOTICE("Тестирование потенциала:")]<BR>"
			for(var/T in origin_tech)
				desc_comp += "Технологический уровень: [origin_tech[T]] [CallTechName(T)] <BR>"
		else
			desc_comp += "Технологической ценности не имеет.<BR>"

		if(LAZYLEN(matter))
			desc_comp += "[SPAN_NOTICE("Получаемые материалы:")]<BR>"
			for(var/mat in matter)
				desc_comp += "[SSmaterials.get_material_by_name(mat)]<BR>"
		else
			desc_comp += "[SPAN_DANGER("Материалов для получения не обнаружено.")]<BR>"
		desc_comp += "*--------*"`

	return ..(user, distance, is_adjacent, "", desc_comp)
