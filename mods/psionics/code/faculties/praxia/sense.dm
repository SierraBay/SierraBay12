/singleton/psionic_power/praxia/psionics/sense
	use_intent =      I_HELP
	name =            "Sense"
	cost =            10
	cooldown =        100
	use_ranged =      TRUE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Выберите руки или кисти на зелёном интенте и нажмите куда угодно на расстоянии, чтобы почувствовать псиоников поблизости. Подавленные ощущаются слабее."

/singleton/psionic_power/praxia/psionics/sense/invoke(mob/living/user, atom/target)
	var/list/perevod_napravlenya = list(
		"north" = "севере",
		"south" = "юг",
		"east" = "восток",
		"west" = "запад",
		"northeast" = "северо-восток",
		"southeast" = "юго-востоке",
		"northwest" = "северо-западе",
		"southwest" = "юго-западе"
	)
	if(user.a_intent != I_HELP || !(user.zone_sel.selecting in BP_ARMS_HANDS))
		return FALSE
	. = ..()
	if(.)
		var/radius = 6 + 3 * (user.psi.get_rank(PSI_PRAXIA))
		var/found = 0
		for(var/thing in SSpsi.processing)
			var/datum/psi_complexus/psychic = thing
			var/mob/living/M = psychic.owner
			if(!M || M == user || M.z != user.z)
				continue
			var/reach = psychic.suppressed ? round(radius / 2) : radius
			var/dist = get_dist(user, M)
			if(dist > reach)
				continue
			found++
			user.psi.psi_show_marker(user, M)
			to_chat(user, SPAN_OCCULT("Ты ощущаешь [psychic.suppressed ? "приглушённую" : "яркую"] псионическую искру: [dist] шагов на [perevod_napravlenya[dir2text(get_dir(user, M))]]."))
		if(!found)
			to_chat(user, SPAN_NOTICE("Вокруг тихо: ни одной искры в радиусе [radius] шагов."))
		return TRUE
