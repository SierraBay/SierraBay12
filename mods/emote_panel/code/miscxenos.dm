/singleton/species/vox/proc/add_vox_verbs()
	var/list/vox_verbs = list(
		/mob/living/carbon/human/vox/verb/vox_shriek
	)
	LAZYADD(inherent_verbs, vox_verbs)

/singleton/species/vox/New()
	. = ..()
	add_vox_verbs()

/mob/living/carbon/human/vox/verb/vox_shriek()
	set name = "X - Визг"
	set category = "Emote"
	emote("shriek")

/singleton/species/adherent/proc/add_adherent_verbs()
	var/list/adherent_verbs = list(
		/mob/living/carbon/human/adherent/verb/adherent_ding,
		/mob/living/carbon/human/adherent/verb/adherent_chime
	)
	LAZYADD(inherent_verbs, adherent_verbs)

/singleton/species/adherent/New()
	. = ..()
	add_adherent_verbs()

/mob/living/carbon/human/adherent/verb/adherent_ding()
	set name = "X - Звон"
	set category = "Emote"
	emote("ding")

/mob/living/carbon/human/adherent/verb/adherent_chime()
	set name = "X - Гул"
	set category = "Emote"
	emote("chime")

/singleton/species/nabber/proc/add_nabber_verbs()
	var/list/nabber_verbs = list(
		/mob/living/carbon/human/nabber/verb/bug_hiss,
		/mob/living/carbon/human/nabber/verb/bug_buzz,
		/mob/living/carbon/human/nabber/verb/bug_chitter
	)
	LAZYADD(inherent_verbs, nabber_verbs)

/singleton/species/nabber/New()
	. = ..()
	add_nabber_verbs()

/mob/living/carbon/human/nabber/verb/bug_hiss()
	set name = "X - Шипение"
	set category = "Emote"
	emote("hiss")

/mob/living/carbon/human/nabber/verb/bug_buzz()
	set name = "X - Высокое жужжание"
	set category = "Emote"
	emote("buzz")

/mob/living/carbon/human/nabber/verb/bug_chitter()
	set name = "X - Треск"
	set category = "Emote"
	emote("chitter")

/singleton/species/diona/proc/add_diona_verbs()
	var/list/diona_verbs = list(
		/mob/living/carbon/human/diona/verb/chirp,
		/mob/living/carbon/human/diona/verb/multichirp
	)
	LAZYADD(inherent_verbs, diona_verbs)

/singleton/species/diona/New()
	. = ..()
	add_diona_verbs()

/mob/living/carbon/human/diona/verb/chirp()
	set name = "X - Чириканье"
	set category = "Emote"
	emote("chirp")

/mob/living/carbon/human/diona/verb/multichirp()
	set name = "X - Множ. чириканье"
	set category = "Emote"
	emote("mchirp")

/singleton/species/machine/proc/add_machine_verbs()
	var/list/machine_verbs = list(
		/mob/living/carbon/human/machine/verb/beep,
		/mob/living/carbon/human/machine/verb/ping,
		/mob/living/carbon/human/machine/verb/buzz,
		/mob/living/carbon/human/machine/verb/confirm,
		/mob/living/carbon/human/machine/verb/deny
	)
	LAZYADD(inherent_verbs, machine_verbs)

/singleton/species/machine/New()
	. = ..()
	add_machine_verbs()

/mob/living/carbon/human/machine/verb/beep()
	set name = "X - Бибикнуть"
	set category = "Emote"
	emote("beep")

/mob/living/carbon/human/machine/verb/ping()
	set name = "X - Пинг"
	set category = "Emote"
	emote("ping")

/mob/living/carbon/human/machine/verb/buzz()
	set name = "X - Низкое жужжание"
	set category = "Emote"
	emote("buzz")

/mob/living/carbon/human/machine/verb/confirm()
	set name = "X - Подтверждение"
	set category = "Emote"
	emote("confirm")

/mob/living/carbon/human/machine/verb/deny()
	set name = "X - Отрицание"
	set category = "Emote"
	emote("deny")
