/obj/item/artefact/gravi
	name = "Something"
	desc = "Вы чувствуете лёгкость."
	icon_state = "gravi"
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	cargo_price = 75

/obj/item/artefact/gravi/lick_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("На вкус как камень."))

/obj/item/artefact/gravi/shake_interaction(mob/living/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Вы не регистрируете чего-либо необычного."))
	else
		to_chat(user,SPAN_GOOD("Потреяся обьект вы почувствовали, что при попытке быстро сдвинуть объект ближе к земле, он явно сопротивляется, не давая сдвинуться так быстро и вашим рукам.."))




/obj/item/artefact/gravi/bite_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("Ощущается зубами как камень. Ничего необычного."))

/obj/item/artefact/gravi/knock_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("При попытке постучать или ударить, рука словно отпружинивает."))

/obj/item/artefact/gravi/compress_interaction(mob/living/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не поддаётся сдавливанию."))
	else
		to_chat(user,SPAN_NOTICE("Обьект словно камень, вообще не поддаётся сдавливанию."))

/obj/item/artefact/gravi/rub_interaction(mob/living/user)
	if(isrobot(user))
		to_chat(user,SPAN_NOTICE("Обьект не реагирует."))
	else
		to_chat(user,SPAN_NOTICE("При попытке погладить ощущается текстура камня."))

/obj/item/artefact/gravi/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/gravi/urm_laser(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/gravi/urm_electro(mob/living/user)
	return "Обьект не реагирует"

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
	var/obj/item/artefact/gravi/artefact = locate(/obj/item/artefact/gravi) in src
	if (istype(artefact))
		return
	.=..()
