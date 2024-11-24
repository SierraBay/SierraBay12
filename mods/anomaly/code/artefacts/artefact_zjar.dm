/obj/item/artefact/zjar
	name = "Something"
	icon_state = "fire_ball"
	desc = "Тепло растекается по вашим рукам, от одного лишь вида вам становится теплее."
	need_to_process = TRUE
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	stored_energy = 1000
	max_energy = 1500
	cargo_price = 600
	rnd_points = 5000
	var/repaired = FALSE

/obj/item/artefact/zjar/lick_interaction(mob/living/carbon/human/user)
	if(istype(user, /mob/living/carbon/human ))
		to_chat(user,SPAN_GOOD("...он...вкусный...по вашему телу растекается тепло."))
		user.bodytemperature += 50

/obj/item/artefact/zjar/shake_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("...По ощущениям внутри словно что-то есть, но в тоже время он монолитный...шар...или овал..."))

/obj/item/artefact/zjar/bite_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_GOOD("...становится жарко, но голове становится куда легче, думается свободнее и проще."))
	user.bodytemperature += 100
	sub_energy(100)
	//Выдаёт реген мозга, обезбол, стимулятор
	user.add_chemical_effect(CE_BRAIN_REGEN, 100)
	user.add_chemical_effect(CE_PAINKILLER, 300)
	user.add_chemical_effect(CE_STIMULANT, 50)
	//Чинит все переломы
	var/list/parts = list(BP_HEAD, BP_CHEST, BP_L_LEG, BP_L_FOOT, BP_R_LEG, BP_R_FOOT, BP_L_ARM, BP_L_HAND, BP_R_ARM,BP_R_HAND)
	for(var/part in parts)
		var/obj/item/organ/external/affecting = user.get_organ(part)
		if(affecting.status &= ORGAN_BROKEN)
			if(affecting.mend_fracture())
				sub_energy(25)
				to_chat(user,SPAN_NOTICE("...острая боль в [affecting] проходит..."))

/obj/item/artefact/zjar/knock_interaction(mob/living/carbon/human/user)
	if(istype(user, /mob/living/carbon/human ))
		sub_energy(50)
		SSanom.bad_interactions_with_artefacts_by_players_ammount++
		to_chat(user,SPAN_BAD("Похоже, ему это не понравилось, вас неприятно ошпарило."))
		user.bodytemperature += 150
		user.apply_damage(15, DAMAGE_BURN, user.hand ? BP_L_HAND : BP_R_HAND)

/obj/item/artefact/zjar/compress_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_NOTICE("..Как желе, но не желе, очень странные ощущения!"))


/obj/item/artefact/zjar/rub_interaction(mob/living/carbon/human/user)
	to_chat(user,SPAN_GOOD("Тепло, и приятно. Не хочется убирать руки от него."))

/obj/item/artefact/zjar/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/zjar/urm_laser(mob/living/user)
	if(stored_energy != 0)
		sub_energy(200)
		SSanom.bad_interactions_with_artefacts_by_players_ammount++
		stored_in_urm.last_interaction_id = "zjar_damaged_by_laser"
		stored_in_urm.last_interaction_reward = 1500
		return "Луч лазера прожигает обьект, явно его повреждая"
	else
		delete_artefact()
		SSanom.bad_interactions_with_artefacts_by_players_ammount++
		stored_in_urm.artefact_inside =  null
		stored_in_urm.last_interaction_id = "zjar_destroyed_by_laser"
		stored_in_urm.last_interaction_reward = 2500
		return "Обьект прожигается на сквозь, после сдувается словно воздушный шар и пропадает."

/obj/item/artefact/zjar/urm_electro(mob/living/user)
	sub_energy(50)
	stored_in_urm.last_interaction_id = "zjar_electra"
	stored_in_urm.last_interaction_reward = 500
	return "Электрический удар был полностью поглощён обьектом."

/obj/item/artefact/zjar/urm_plasma(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/zjar/urm_phoron(mob/living/user)
	if(stored_energy != max_energy && !repaired)
		add_energy(1000)
		repaired = TRUE
		stored_in_urm.last_interaction_id = "zjar_repaired"
		stored_in_urm.last_interaction_reward = 2500
		return "Вы наблюдаете, как недостающие часть обьекта, словно отрастают обратно"
	else if(repaired)
		delete_artefact()
		SSanom.bad_interactions_with_artefacts_by_players_ammount++
		stored_in_urm.artefact_inside =  null
		stored_in_urm.last_interaction_id = "zjar_destroyed"
		stored_in_urm.last_interaction_reward = 3500
		return "После облучения фороном, обьект начинает рассыпаться на ваших глазах, и спустя момент, попросту исчез"
	return "Обьект не реагирует"



/obj/item/artefact/zjar/process_artefact_effect_to_user()
	if(current_user.bodytemperature < 350)
		current_user.bodytemperature = 350
	for(var/thing in current_user.internal_organs)
		var/obj/item/organ/internal/I = thing
		if(I.damage > 0)
			sub_energy(20)
			I.heal_damage(rand(1,5))


/obj/item/artefact/zjar/react_at_electra(mob/living/user)
	if(stored_energy != 0)
		sub_energy(100)
		visible_message(SPAN_GOOD("[src] вспыхивает красной вспышкой"),,7)
	else
		delete_artefact()
		visible_message(SPAN_BAD("[src] вспыхивает ярчайшей красной вспышкой и пропадает."),,7)
	to_chat(current_user, SPAN_GOOD("Вы чувствуете сильный, но приятный ЖАР в месте удара. Но не боль."))
	return "Впитывает электроудар"

/obj/item/artefact/zjar/react_at_rvach_gib(mob/living/user)
	delete_artefact()
	visible_message(SPAN_BAD("[src] вспыхивает ярчайшей красной вспышкой и пропадает."),,7)
	return "Защищает от гиба"

/obj/item/artefact/zjar/energy_changed()
	if(stored_energy > 1000)
		icon_state = icon_state = "fire_ball_active"
	else if(stored_energy <= 1000)
		icon_state = icon_state = "fire_ball"

/obj/item/artefact/zjar/additional_process()
	var/turf/my_turf = get_turf(src)
	if(my_turf.temperature >= 500)
		add_energy(100)
