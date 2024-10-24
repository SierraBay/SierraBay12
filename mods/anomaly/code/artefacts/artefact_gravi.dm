/obj/item/artefact/gravi
	name = "Something"
	desc = "Вы чувствуете лёгкость."
	icon_state = "gravi"
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
	cargo_price = 800
	rnd_points = 5000
	need_to_process = TRUE

/obj/item/artefact/gravi/lick_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("На вкус как камень."))

/obj/item/artefact/gravi/shake_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Вы не регистрируете чего-либо необычного."))
	else
		to_chat(user,SPAN_GOOD("Потреяся обьект вы почувствовали, что при попытке быстро сдвинуть объект ближе к земле, он явно сопротивляется, не давая сдвинуться так быстро и вашим рукам.."))




/obj/item/artefact/gravi/bite_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Ощущается зубами как камень. Ничего необычного."))

/obj/item/artefact/gravi/knock_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("При попытке постучать или ударить, рука словно отпружинивает."))

/obj/item/artefact/gravi/compress_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не поддаётся сдавливанию."))
	else
		to_chat(user,SPAN_NOTICE("Обьект словно камень, вообще не поддаётся сдавливанию."))

/obj/item/artefact/gravi/rub_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не реагирует."))
	else
		to_chat(user,SPAN_NOTICE("При попытке погладить ощущается текстура камня."))

/obj/item/artefact/gravi/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/gravi/urm_laser(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/gravi/urm_electro(mob/living/user)
	stored_in_urm.last_interaction_id = "gravi_jumped_electro"
	stored_in_urm.last_interaction_reward = 1000
	return "Обьект отскакивает от места контакта в противоположную сторону."

/obj/item/artefact/gravi/urm_plasma(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/gravi/urm_phoron(mob/living/user)
	return "Обьект не реагирует"









/obj/item/artefact/gravi/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover, /obj/item/projectile/bullet))
		new /obj/item/material/shard/shrapnel/steel(get_turf(src))
		qdel(mover)
	return 1


/mob/living/carbon/human/handle_fall_effect(turf/landing)
	var/list/result_effects = calculate_artefact_reaction(src, "Падение с высоты")
	if(result_effects)
		if(result_effects.Find("Защищает от падения"))
			return
	.=..()

/obj/item/artefact/gravi/process_artefact_effect_to_user()
	if(current_user.stamina < 85)
		current_user.adjust_stamina(5)

//Грави заставляет отлететь в направление, противположное текущее. Так смешнее.
/obj/item/artefact/gravi/react_at_electra(mob/living/user)
	. = ..()
	var/turf/target_turf = get_turf(user)
	var/throw_dir = turn(user.dir, 180) //Противоположное направление моба
	for(var/i = 1, i < 2, i++)
		target_turf = get_edge_target_turf(user, throw_dir)
	user.throw_at(target_turf, 2, 1)

/obj/item/artefact/gravi/react_at_tramplin(mob/living/user)
	. = ..()
	return "Не даёт кинуть"

/obj/item/artefact/gravi/react_at_rvach_gib(mob/living/user)
	return "Защищает от гиба рвачом"

/obj/item/artefact/gravi/react_at_failing(mob/living/user)
	return "Защищает от падения"
