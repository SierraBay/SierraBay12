/singleton/psionic_power/shaymanism/ventriloquism
	name =            "Ventriloquism"
	cost =            10
	cooldown =        15
	use_ranged =      TRUE
	use_manifest =    FALSE
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по отдалённом объекту выбрав захват рта чтобы говорить его абстрактным голосом."
	admin_log = TRUE

/singleton/psionic_power/shaymanism/ventriloquism/invoke(mob/living/user, atom/target)
	if((user.zone_sel.selecting != BP_MOUTH))
		return FALSE
	if(user.a_intent != I_GRAB)
		return FALSE
	if(!isturf(target) && !isobj(target))
		return FALSE
	if(!(target in view()))
		return FALSE
	. = ..()
	if(.)
		var/distance = get_dist(user, target)
		if(distance > user.psi.get_rank(PSI_SHAYMANISM) * 3)
			to_chat(user, SPAN_OCCULT("Мой заговор не слышен так далеко."))
			return FALSE

		var/phrase =  input(user, "Что ты хочешь произнести?", "Говори", "") as null|text
		if(!phrase)
			return FALSE
		var/mob/living/ventriloquist_decoy/D = new(get_turf(target), user, target, phrase)
		D.icon = null

// ВОРНИНГ ВПЕРЕДИ КОСТЫЛЬ
/mob/living/ventriloquist_decoy
	name = "Doll"
	icon = 'mods/psionics/icons/psi.dmi'
	icon_state = "blank"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/mob/living/ventriloquist_decoy/Initialize(mapload, mob/living/user, atom/target, phrase)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/ventriloquist_decoy/LateInitialize(mapload, mob/living/user, atom/target, phrase)
	if(!target)
		qdel(src)
		return
	name = target.name
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y
	var/datum/language/lang = user.get_default_language() || all_languages[LANGUAGE_HUMAN_EURO]
	say(phrase, lang, whispering = FALSE)
	QDEL_IN(src, 5 SECONDS)

/mob/living/ventriloquist_decoy/death()
	return
