/obj/item/artefact/zjar
	name = "Что-то."
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
