/obj/item/artefact/crystal
	name = "Something"
	desc = "Кристалл фиолетового цвета, который словно разбирается и собирается вновь в едино"
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
	cargo_price = 1200
	rnd_points = 5000

/obj/item/artefact/crystal/lick_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("Блять, язык порезался!"))
	user.apply_damage(5, DAMAGE_BRUTE, BP_MOUTH)

/obj/item/artefact/crystal/shake_interaction(mob/living/carbon/human/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Вы не регистрируете чего-либо необычного."))
	else
		to_chat(user,SPAN_GOOD("Потреяся обьект вы почувствовали, что при попытке быстро сдвинуть объект ближе к земле, он явно сопротивляется, не давая сдвинуться так быстро и вашим рукам.."))




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
