/singleton/psionic_power/consciousness/invis
	name =            "Invisibility"
	cost =            50
	cooldown =        250
	use_ranged =     TRUE
	use_melee =      TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Выберите глаза на зелёном интенте, и затем нажмите по себе, чтобы временно сделать его невидимым для остальных."

/mob/living/carbon/human/attack_hand() // Увы, у мобья мало проков на атаку, поэтому инвиз будет себя проявлять только ударом кулаком
	var/mob/living/carbon/human/user = usr
	if(user.psi?.is_invisible)
		animate(usr, alpha = 255, time = 3, easing = BOUNCE_EASING)
		sleep(3)
		animate(usr, alpha = 0, time = 5, easing = EASE_IN | BOUNCE_EASING)
	. = ..()


/datum/psi_complexus
	var/is_invisible = FALSE

/datum/psi_complexus/proc/run_timer_invisibility(time)
	set waitfor = 0
	var/mob/living/carbon/human/user = owner
	var/currentbrute = user.getBruteLoss()
	var/currentburn = user.getFireLoss()
	is_invisible = TRUE

	var/T = time
	while(T > 0)
		sleep(1 SECOND)
		if(currentbrute < user.getBruteLoss() || currentburn < user.getFireLoss())
			T--
			currentbrute = user.getBruteLoss()
			currentburn = user.getFireLoss()
			animate(user, alpha = 255, time = 5, easing = BOUNCE_EASING)
			sleep(3)
			animate(user, alpha = 0, time = 5, easing = EASE_IN | BOUNCE_EASING)
		T--
	user.visible_message(SPAN_WARNING("[user] внезапно проявляется!"))
	animate(user, alpha = 255, time = 3 SECONDS, easing = EASE_IN | BOUNCE_EASING)
	is_invisible = FALSE

/singleton/psionic_power/consciousness/invis/invoke(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/con_rank_user = user.psi.get_rank(PSI_CONSCIOUSNESS)
	if(user.zone_sel.selecting != BP_EYES || user.a_intent != I_HELP)
		return FALSE

	if(target == user)
		user.visible_message(SPAN_WARNING("[user] исчезает!"))
		animate(target, alpha = 0, time = 10 SECONDS / con_rank_user, easing = BOUNCE_EASING)
		target.psi.run_timer_invisibility(con_rank_user * 3)
		return TRUE
