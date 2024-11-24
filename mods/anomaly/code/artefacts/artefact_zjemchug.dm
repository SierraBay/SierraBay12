// [WIP]
/obj/item/artefact/zjemchug
	name = "Something"
	icon_state = "zjemchug"
	desc = "Абсолютно гладкий шар с максимально правильной формой. Чем дольше смотришь на него, тем больше сознание затмевает туман. Что-то не так."
	need_to_process = TRUE
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	///Моб, к которому привязался артефакт
	var/mob/living/carbon/human/owner
	stored_energy = 10000
	max_energy = 10000
	cargo_price = 1500 //Это крайне ценный и редкий артефакт
	rnd_points = 10000

/obj/item/artefact/zjemchug/react_to_touched(mob/living/user)
	. = ..()
	if(!owner)
		deal_make_new_owner(user)
	else
		to_chat(user, SPAN_BAD("...Вы чувствуете, как внутри вас что-то противится..."))

/obj/item/artefact/zjemchug/Process()
	if(!(owner in get_turf(src))) //На нашем турфе нет хозяина
		for(var/mob/living/carbon/human/target in get_turf(src))
			to_chat(target, SPAN_BAD("Что-то пугает вас, заставляет отойти от [src]"))

/obj/item/artefact/zjemchug/proc/deal_make_new_owner(mob/living/user)
	//Предлагает человеку обьединить умы
	var/list/choices = list("Да","Нет")
	var/choice = input(usr, "Расслабить свой ум и прекратить сопротивление?") as null|anything in choices
	if(choice == "Нет")
		to_chat(user, SPAN_BAD("Вы решаете продолжить сопротивляться ему. Вы не поддадитесь."))
		return
	if(choice == "Да")
		make_new_owner(user)

/obj/item/artefact/zjemchug/proc/make_new_owner(mob/living/user)
	owner = user
	icon_state = "zjemchug_active"
	SSanom.good_interactions_with_artefacts_by_players_ammount++
	to_chat(user, SPAN_GOOD("Вы поддаётесь его влиянию...что-то в вас изменилось..."))
	var/list/faculties = list("[PSI_COERCION]", "[PSI_REDACTION]", "[PSI_ENERGISTICS]", "[PSI_PSYCHOKINESIS]")
	for(var/i = 1 to rand(2,3))
		var/mob/living/carbon/human/human_user = user
		human_user.set_psi_rank(pick_n_take(faculties), 5)
