GLOBAL_TYPED_NEW(aliens, /datum/antagonist/alien)

/datum/antagonist/alien
	id = MODE_ALIEN
	role_text = "Alien"
	role_text_plural = "Aliens"
	welcome_text = "Вы - Чужой, существо из далекого космоса, идеальный организм. Ваша первостепенная задача - остаться в живых."
	flags =  ANTAG_RANDOM_EXCEPTED | ANTAG_OVERRIDE_JOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_OVERRIDE_MOB | ANTAG_IMPLANT_IMMUNE
	antaghud_indicator = "hudalien"
	skill_setter = null

	faction = "alien"

	no_prior_faction = TRUE
	landmark_id = "xeno"
	mob_path = /mob/living/carbon/human/alien

	spawn_announcement_title = "Lifesign Alert"
	spawn_announcement_delay = 50

/datum/antagonist/alien/get_welcome_text(mob/recipient)
	return replacetext(welcome_text, "%LANGUAGE_PREFIX%", recipient?.get_prefix_key(/singleton/prefix/language) || ",")

/datum/antagonist/alien/create_objectives()
	return

/datum/antagonist/alien/update_antag_mob(datum/mind/player)
	..()
	player.current.make_alien()
