/mob/living/get_interactions(mob/living/carbon/human/user, data = list())
	if(!istype(user))
		return

	var/user_species = user.species.name
	var/mouth_covered = user.wear_mask || user.check_mouth_coverage() || (user_species in SPECIES_NO_MOUTH) || !user.has_organ(BP_HEAD)

	var/has_hands = user.has_organ(BP_L_HAND) && user.has_organ(BP_R_HAND)
	var/adjacent = user.Adjacent(src)

	LAZYINITLIST(data[null])
	data[null] += "bow'>Отвесить поклон"
	data[null] += "bow_affably'>Приветливо кивнуть"
	data[null] += "wink'>Подмигнуть"

	if(has_hands)
		LAZYINITLIST(data["Руки"])
		if(adjacent)
			data["Руки"] += "hug'>Обнимашки!"
			data["Руки"] += "pointing'>Ткнуть в бок/нос"
			data["Руки"] += "pat'>Погладить"
			data["Руки"] += "scratch'>Почесать"
		data["Руки"] += "fuckyou'><font color='red'>Показать средний палец</font>"
		data["Руки"] += "threaten'><font color='red'>Погрозить кулаком</font>"

	if(!mouth_covered)
		LAZYINITLIST(data["Лицо"])
		data["Лицо"] += "kiss'>Поцеловать"
		data["Лицо"] += "tongue'><font color='red'>Показать язык</font>"
		if(adjacent)
			data["Лицо"] += "spit'><font color='red'>Плюнуть</font>"

	..()

/mob/living/on_interaction(mob/living/carbon/human/user, interaction)
	. = ..()
	if(.)
		return .

	var/user_species = user.species.name
	var/mouth_covered = user.wear_mask || user.check_mouth_coverage() || (user_species in SPECIES_NO_MOUTH) || !user.has_organ(BP_HEAD)

	var/has_hands = user.has_organ(BP_L_HAND) && user.has_organ(BP_R_HAND) && user.can_use_hands()
	var/adjacent = user.Adjacent(src)

	var/sel_zone = user.zone_sel.selecting

	if(interaction == "bow")
		return "<B>[user]</B> кланяется <B>[src]</B>."

	if(interaction == "bow_affably")
		return "<B>[user]</B> приветливо кивнул[user.gender == FEMALE ? "а":""] в сторону <B>[src]</B>."

	if(interaction == "wink")
		return "<B>[user]</B> улыбчиво подмигнул[user.gender == FEMALE ? "а":""] <B>[src]</B>."

	if(interaction == "hug" && adjacent && has_hands)
		playsound(loc, 'mods/_fd/mob_interactions/sounds/hug.ogg', 50, 1, -1)
		return "<B>[user]</B> обнимает <B>[src]</B>."

	if(interaction == "pointing" && adjacent && has_hands)
		if(sel_zone == BP_HEAD)
			return "<B>[user]</B> тыкает <B>[src]</B> в нос."
		return "<B>[user]</B> толкает <B>[src]</B> в бок."

	if(interaction == "pat" && adjacent && has_hands)
		return "<B>[user]</B> [pick("гладит", "поглаживает")] <B>[src]</B>."

	if(interaction == "scratch" && adjacent && has_hands)
		if(sel_zone == BP_HEAD)
			return "<B>[user]</B> [pick("чешет за ухом", "чешет голову")] <B>[src]</B>."
		return "<B>[user]</B> чешет <B>[src]</B>."

	if(interaction == "fuckyou" && has_hands)
		return "<B>[user]</B> показывает <B>[src]</B> средний палец!"

	if(interaction == "threaten" && has_hands)
		return "<B>[user]</B> грозит <B>[src]</B> кулаком!"

	if(interaction == "kiss" && !mouth_covered)
		if(adjacent)
			return "<B>[user]</B> целует <B>[src]</B>."
		return "<B>[user]</B> посылает <B>[src]</B> воздушный поцелуй."

	if(interaction == "tongue" && !mouth_covered)
		return "<B>[user]</B> показывает <B>[src]</B> язык!"

	if(interaction == "spit" && adjacent && !mouth_covered)
		return SPAN_DANGER("[user] плюет в [src]!")
