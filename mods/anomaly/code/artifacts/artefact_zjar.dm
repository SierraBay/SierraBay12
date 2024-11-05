/obj/item/artefact/zjar
	name = "Something"
	desc = "Тепло растекается по вашим рукам, от одного лишь вида вам становится теплее."
	rect_to_interactions = list(
		"Lick",
		"Shake",
		"Bite",
		"Knock",
		"Compress",
		"Rub"
	)
	//у артефакта 5 "кусков"
	var/current_integrity = 5
	//Уже ремонтировался с помощью URM?
	var/repaired = FALSE
	cargo_price = 350
	var/datum/beam = null

/obj/item/artefact/zjar/lick_interaction(mob/living/user)
	if(istype(user, /mob/living/carbon/human ))
		to_chat(user,SPAN_GOOD("...он...вкусный...по вашему телу растекается тепло."))
		user.bodytemperature += 50

/obj/item/artefact/zjar/shake_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("...По ощущениям внутри словно что-то есть, но в тоже время он монолитный...шар...или овал..."))

/obj/item/artefact/zjar/bite_interaction(mob/living/user)
	to_chat(user,SPAN_GOOD("...становится жарко, но голове становится куда легче, думается свободнее и проще."))
	var/mob/living/carbon/victim = user
	victim.bodytemperature += 100
	victim.add_chemical_effect(CE_BRAIN_REGEN, 50)


/obj/item/artefact/zjar/knock_interaction(mob/living/user)
	if(istype(user, /mob/living/carbon/human ))
		to_chat(user,SPAN_BAD("Похоже, ему это не понравилось, вас неприятно ошпарило."))
		user.bodytemperature += 150
		user.apply_damage(15, DAMAGE_BURN, user.hand ? BP_L_HAND : BP_R_HAND)

/obj/item/artefact/zjar/compress_interaction(mob/living/user)
	to_chat(user,SPAN_NOTICE("..Как желе, но не желе, очень странные ощущения!"))


/obj/item/artefact/zjar/rub_interaction(mob/living/user)
	to_chat(user,SPAN_GOOD("Тепло, и приятно. Не хочется убирать руки от него."))

/obj/item/artefact/zjar/urm_radiation(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/zjar/urm_laser(mob/living/user)
	if(current_integrity > 1)
		current_integrity--
		stored_in_urm.last_interaction_id = "zjar_damaged_by_laser"
		stored_in_urm.last_interaction_reward = 1500
		return "Луч лазера прожигает обьект, явно его повреждая"
	else
		delete_artefact()
		stored_in_urm.artefact_inside =  null
		stored_in_urm.last_interaction_id = "zjar_destroyed_by_laser"
		stored_in_urm.last_interaction_reward = 2500
		return "Обьект прожигается на сквозь, после сдувается словно воздушный шар и пропадает."

/obj/item/artefact/zjar/urm_electro(mob/living/user)
	stored_in_urm.last_interaction_id = "zjar_electra"
	stored_in_urm.last_interaction_reward = 500
	return "Электрический удар был полностью поглощён обьектом."

/obj/item/artefact/zjar/urm_plasma(mob/living/user)
	return "Обьект не реагирует"

/obj/item/artefact/zjar/urm_phoron(mob/living/user)
	if(current_integrity < 5 && !repaired)
		current_integrity = 5
		repaired = TRUE
		stored_in_urm.last_interaction_id = "zjar_repaired"
		stored_in_urm.last_interaction_reward = 2500
		return "Вы наблюдаете, как недостающие часть обьекта, словно отрастают обратно"
	else if(repaired)
		delete_artefact()
		stored_in_urm.artefact_inside =  null
		stored_in_urm.last_interaction_id = "zjar_destroyed"
		stored_in_urm.last_interaction_reward = 3500
		return "После облучения фороном, обьект начинает рассыпаться на ваших глазах, и спустя момент, попросту исчез"
	return "Обьект не реагирует"




/obj/item/artefact/zjar/Process() //чуть подогреем
	for(var/mob/living/carbon/human/victim in get_turf(src))
		victim.heal_organ_damage(0, 6)
		if(victim.bodytemperature < 360)
			victim.bodytemperature = 360
		for(var/thing in victim.internal_organs)
			var/obj/item/organ/internal/I = thing
			I.heal_damage(rand(0,1))
