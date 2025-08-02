/singleton/species/tajaran/proc/add_tajaran_verbs()
	var/list/tajaran_verbs = list(
		/mob/living/carbon/human/verb/swish,
		/mob/living/carbon/human/verb/wag,
		/mob/living/carbon/human/verb/qwag,
		/mob/living/carbon/human/verb/swag,
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
