/obj/item/artefact/flyer
	name = "Something"
	desc = "Обьект абсолютно невесом, выглядит как какой-то плотный кусок воздуха."
	icon_state = "flyer"
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
	cargo_price = 1500
	rnd_points = 7000
	need_to_process = TRUE

/obj/item/artefact/flyer/lick_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("На вкус как воздух."))

/obj/item/artefact/flyer/shake_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("При тряске вы на мгновение отпускаете обьект, и тот зависает в воздухе."))
	else
		to_chat(user,SPAN_GOOD("При тряске вы на мгновение отпускаете обьект, и тот зависает в воздухе, словно застряв в нём."))




/obj/item/artefact/flyer/bite_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Материя словно раступается перед вашими зубами."))

/obj/item/artefact/flyer/knock_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Стукнув по нему рукой, тот упрыгивает из ваших рук."))
	//jump_away() TODO

/obj/item/artefact/flyer/compress_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект легко сдавливается, превращаясь в мини шарик, но после моментально возвращает свою форму."))
	else
		to_chat(user,SPAN_NOTICE("Обьект легко сдавливается, превращаясь в мини шарик, но после моментально возвращает свою форму. Очень мягкий по ощущениям."))

/obj/item/artefact/flyer/rub_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не реагирует."))
	else
		to_chat(user,SPAN_NOTICE("Ощущения словно водишь рукой по воздуху."))

/obj/item/artefact/flyer/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/flyer/urm_laser(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/flyer/urm_electro(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/flyer/urm_plasma(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/flyer/urm_phoron(mob/living/user)
	return "Обьект не реагирует"



/obj/item/artefact/flyer/process_artefact_effect_to_user()
	if(current_user.stamina < 85)
		current_user.adjust_stamina(5)

/mob/living/carbon/human/can_fall(anchor_bypass, turf/location_override)
	var/list/result_effects = calculate_artefact_reaction(src, "Возможность упасть")
	if(result_effects)
		if(result_effects.Find("Держит в воздухе"))
			return
	.=..()


/obj/item/artefact/flyer/react_at_tramplin(mob/living/user)
	. = ..()
	return "Усиливает дальность полёта"

/obj/item/artefact/flyer/react_at_rvach_gib(mob/living/user)
	return "Усиливает дальность полёта"

/obj/item/artefact/flyer/react_at_can_fall(mob/living/user)
	return "Держит в воздухе"
