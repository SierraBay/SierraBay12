/obj/item/artefact/crystal
	name = "Something"
	desc = "Кристалл фиолетового цвета, который словно разбирается и собирается вновь в едино."
	admin_name = "Кристалл"
	icon_state = "crystal"
	need_to_process = TRUE
	//В артефакте нет энергии/она неограничена
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	stored_energy = 0
	max_energy = 0
	cargo_price = 2000
	rnd_points = 5000
	//У каждого камня есть 2 заряда
	var/remain_charges = 2
	var/time_to_full_recharge = 10 MINUTES

/obj/item/artefact/crystal/lick_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Блять, язык порезался!"))
	user.apply_damage(5, DAMAGE_BRUTE, BP_MOUTH)

/obj/item/artefact/crystal/shake_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Вы не регистрируете чего-либо необычного."))
	else
		to_chat(user,SPAN_GOOD("Ощущение словно внутри что-то есть."))

/obj/item/artefact/crystal/user_bumped_at_atom(mob/living/user, atom/bump_atom)
	if(!remain_charges)
		return
	var/turf/temp_turf = get_turf(bump_atom)
	for(var/atom/movable/effected_atom in temp_turf)
		if(istype(effected_atom, /turf/unsimulated/wall) || istype(effected_atom, /mob/living))
			return
	for(var/atom/movable/effected_atom in temp_turf)
		effected_atom.affect_anomaly_crystal()
	temp_turf.affect_anomaly_crystal()
	remain_charges--
	current_user.forceMove(temp_turf)
	if(remain_charges == 0)
		addtimer(new Callback(src, PROC_REF(update_charges)), time_to_full_recharge)

/obj/item/artefact/crystal/proc/update_charges()
	remain_charges = initial(remain_charges)

///Делает обьект временно прозрачным и фиолетовым.
/atom/proc/affect_anomaly_crystal()
	return

/atom/proc/start_crystal_timer()
	addtimer(new Callback(src, PROC_REF(stop_affect_anomaly_crystal)), 2 MINUTES)


/obj/structure/affect_anomaly_crystal()
	color = "#6e1459"
	density = FALSE
	opacity = FALSE
	start_crystal_timer()

/turf/simulated/wall/affect_anomaly_crystal()
	color = "#6e1459"
	density = FALSE
	opacity = FALSE
	start_crystal_timer()

/obj/machinery/affect_anomaly_crystal()
	color = "#6e1459"
	density = FALSE
	opacity = FALSE
	start_crystal_timer()

/atom/proc/stop_affect_anomaly_crystal()
	color = initial(color)
	density = initial(density)
	opacity = initial(opacity)


/obj/item/artefact/crystal/bite_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Твёрдый как алмаз, без вкусов."))

/obj/item/artefact/crystal/knock_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Обьект не реагирует."))

/obj/item/artefact/crystal/compress_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Фиксируются вибрации."))
	else
		to_chat(user,SPAN_NOTICE("Кажется, он вибрирует!"))

/obj/item/artefact/crystal/rub_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не реагирует."))
	else
		to_chat(user,SPAN_NOTICE("Очень гладкий и приятный на ощупь, словно стекло, но куда более поддатливый для руки."))

/obj/item/artefact/crystal/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/crystal/urm_laser(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/crystal/urm_electro(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/crystal/urm_plasma(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/crystal/urm_phoron(mob/living/user)
	return "Обьект не реагирует"
