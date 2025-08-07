/singleton/species/tajaran/proc/add_tajaran_verbs()
	var/list/tajaran_verbs = list(
		/mob/living/carbon/human/tajaran/verb/swish,
		/mob/living/carbon/human/tajaran/verb/wag,
		/mob/living/carbon/human/tajaran/verb/qwag,
		/mob/living/carbon/human/tajaran/verb/swag,
		/mob/living/carbon/human/tajaran/verb/hiss,
		/mob/living/carbon/human/tajaran/verb/cat_purr,
		/mob/living/carbon/human/tajaran/verb/cat_purrlong,
		/mob/living/carbon/human/tajaran/verb/cat_purrstrong
	)
	LAZYADD(inherent_verbs, tajaran_verbs)

/singleton/species/tajaran/New()
	. = ..()
	add_tajaran_verbs()

/mob/living/carbon/human/tajaran/verb/hiss()
	set name = "X - Шипеть"
	set category = "Emote"
	emote("hiss")

/mob/living/carbon/human/tajaran/verb/cat_purr()
	set name = "X - Мурчать"
	set category = "Emote"
	emote("purr")

/mob/living/carbon/human/tajaran/verb/cat_purrlong()
	set name = "X - Долго мурчать"
	set category = "Emote"
	emote("purrl")

/mob/living/carbon/human/tajaran/verb/cat_purrstrong()
	set name = "X - Сильно мурчать"
	set category = "Emote"
	emote("purrs")
  
/mob/living/carbon/human/tajaran/verb/swish()
	set name = "X - Взмахнуть хвостом"
	set category = "Emote"
	emote("swish")

/mob/living/carbon/human/tajaran/verb/wag()
	set name = "X - Вилять хвостом"
	set category = "Emote"
	emote("wag")

/mob/living/carbon/human/tajaran/verb/qwag()
	set name = "X - Быстро вилять хвостом"
	set category = "Emote"
	emote("qwag")

/mob/living/carbon/human/tajaran/verb/swag()
	set name = "X - Остановить хвост"
