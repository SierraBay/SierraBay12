/singleton/species/skrell/proc/add_skrell_verbs()
	var/list/skrell_verbs = list(
		/mob/living/carbon/human/skrell/verb/skrell_anger,
		/mob/living/carbon/human/skrell/verb/skrell_anger1,
		/mob/living/carbon/human/skrell/verb/skrell_anger2,
		/mob/living/carbon/human/skrell/verb/skrell_laughter,
		/mob/living/carbon/human/skrell/verb/skrell_peep,
		/mob/living/carbon/human/skrell/verb/skrell_trill,
		/mob/living/carbon/human/skrell/verb/skrell_trill1,
		/mob/living/carbon/human/skrell/verb/skrell_trill2,
		/mob/living/carbon/human/skrell/verb/skrell_warble,
		/mob/living/carbon/human/skrell/verb/skrell_warble1,
		/mob/living/carbon/human/skrell/verb/skrell_warble2,
		/mob/living/carbon/human/skrell/verb/skrell_warble3
	)
	LAZYADD(inherent_verbs, skrell_verbs)

/singleton/species/skrell/New()
	. = ..()
	add_skrell_verbs()

/mob/living/carbon/human/skrell/verb/skrell_anger()
	set name = "X - Злость Случ."
	set category = "Emote"
	emote("skanger")

/mob/living/carbon/human/skrell/verb/skrell_anger1()
	set name = "X - Злость 1"
	set category = "Emote"
	emote("skanger1")

/mob/living/carbon/human/skrell/verb/skrell_anger2()
	set name = "X - Злость 2"
	set category = "Emote"
	emote("skanger2")

/mob/living/carbon/human/skrell/verb/skrell_laughter()
	set name = "X - Смех"
	set category = "Emote"
	emote("sklaugh")

/mob/living/carbon/human/skrell/verb/skrell_peep()
	set name = "X - Пиип"
	set category = "Emote"
	emote("skpeep")

/mob/living/carbon/human/skrell/verb/skrell_trill()
	set name = "X - Трель Случ."
	set category = "Emote"
	emote("sktrill")

/mob/living/carbon/human/skrell/verb/skrell_trill1()
	set name = "X - Трель 1"
	set category = "Emote"
	emote("sktrill1")

/mob/living/carbon/human/skrell/verb/skrell_trill2()
	set name = "X - Трель 2"
	set category = "Emote"
	emote("sktrill2")

/mob/living/carbon/human/skrell/verb/skrell_warble()
	set name = "X - Пение Случ."
	set category = "Emote"
	emote("skwarble")

/mob/living/carbon/human/skrell/verb/skrell_warble1()
	set name = "X - Пение 1"
	set category = "Emote"
	emote("skwarble1")

/mob/living/carbon/human/skrell/verb/skrell_warble2()
	set name = "X - Пение 2"
	set category = "Emote"
	emote("skwarble2")

/mob/living/carbon/human/skrell/verb/skrell_warble3()
	set name = "X - Пение 3"
	set category = "Emote"
	emote("skwarble3")
