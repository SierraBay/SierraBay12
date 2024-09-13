/obj/item/artefact
	var/connected_to_anomaly = TRUE
	///Здесь будет лист взаимодействий, но который артефакт всё таки реагирует
	var/list/rect_to_interactions = list()
	var/turf/prev_loc

//Подбор артефакта

/obj/item/artefact/Initialize()
	. = ..()
	prev_loc = get_turf(src)

/obj/item/artefact/attack_hand(mob/user as mob)
	if(inmech_sec(user))
		to_chat(user, SPAN_WARNING("Вы недотягиваетесь."))
		return
	else if(connected_to_anomaly)
		if(AnomaliesAmmountInTurf(get_turf(src)) == 0)
			connected_to_anomaly = FALSE
		else
			for(var/obj/anomaly/anomka in src.loc.contents)
				if(prob(25 * user.get_skill_value(SKILL_SCIENCE)))
					to_chat(user, SPAN_GOOD("[desc]"))
					connected_to_anomaly = FALSE
				else
					to_chat(user, SPAN_WARNING("Обьект уплывает из ваших рук"))
					if(istype(anomka, /obj/anomaly/part))
						var/obj/anomaly/part/anomka_part = anomka
						if(anomka_part.core.isready())
							anomka_part.core.activate_anomaly()
					else
						if(anomka.isready())
							anomka.activate_anomaly()
					return
	react_to_touched(user)

	.=..()



/obj/item/artefact/Move()
	..()
	if(connected_to_anomaly)
		src.forceMove(prev_loc)

//Интерактив с артефактом
/obj/item/artefact/attack_self(mob/living/user)
	. = ..()
	var/list/interaction_variations = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	var/choosed_interaction = input(usr, "What to do","It's time to chose") as null|anything in interaction_variations
	if(!user.Adjacent(src))
		return FALSE
	if(choosed_interaction == "Lick" && rect_to_interactions.Find(choosed_interaction))
		if(!ishuman(user))
			to_chat(user, SPAN_NOTICE("У меня нет рта, но я должен кричать."))
			return
		var/mob/living/carbon/human/tester = user
		var/obj/item/blocked = tester.check_mouth_coverage()
		if(blocked)
			to_chat(user, SPAN_NOTICE("Мой рот закрыт, я не могу лизнуть его."))
			return
		lick_interaction(user)
		return
	else if(choosed_interaction == "Shake" && rect_to_interactions.Find(choosed_interaction))
		shake_interaction(user)
		return
	else if(choosed_interaction == "Bite" && rect_to_interactions.Find(choosed_interaction))
		if(!ishuman(user))
			to_chat(user, SPAN_NOTICE("У меня нет рта, но я должен кричать."))
			return
		var/mob/living/carbon/human/tester = user
		var/obj/item/blocked = tester.check_mouth_coverage()
		if(blocked)
			to_chat(user, SPAN_NOTICE("Мой рот закрыт, я не могу укусить его."))
			return
		bite_interaction(user)
		return
	else if(choosed_interaction == "Knock" && rect_to_interactions.Find(choosed_interaction))
		knock_interaction(user)
		return
	else if(choosed_interaction == "Compress" && rect_to_interactions.Find(choosed_interaction))
		compress_interaction(user)
		return
	else if(choosed_interaction == "Rub" && rect_to_interactions.Find(choosed_interaction))
		rub_interaction(user)
		return

	to_chat(user, SPAN_NOTICE("Ничего не произошло."))

///ВЗАИМОДЕЙСТВИЯ ОТ ЛЮДЕЙ НАПРЯМУЮ
/obj/item/artefact/proc/lick_interaction(mob/living/user)
	return

/obj/item/artefact/proc/shake_interaction(mob/living/user)
	return

/obj/item/artefact/proc/bite_interaction(mob/living/user)
	return

/obj/item/artefact/proc/knock_interaction(mob/living/user)
	return

/obj/item/artefact/proc/compress_interaction(mob/living/user)
	return

/obj/item/artefact/proc/rub_interaction(mob/living/user)
	return


///ВЗАИМОДЕЙСТВИЯ ОТ МАШИНЫ ДЛЯ ИЗУЧЕНИЙ И АНАЛИЗА
/obj/item/artefact/proc/urm_radiation(mob/living/user)
	return

/obj/item/artefact/proc/urm_laser(mob/living/user)
	return

/obj/item/artefact/proc/urm_electro(mob/living/user)
	return

/obj/item/artefact/proc/urm_plasma(mob/living/user)
	return

/obj/item/artefact/proc/urm_phoron(mob/living/user)
	return

/obj/item/artefact/proc/urm_microscope(mob/living/user)
	return

/obj/item/artefact/proc/angry_activity(mob/living/user)
	return
