/mob/living/carbon/human/get_interactions(mob/living/carbon/human/user, data = list())
	if(!istype(user))
		return

	var/user_species = user.species.name
	var/mouth_covered = user.wear_mask || user.check_mouth_coverage() || (user_species in SPECIES_NO_MOUTH) || !user.has_organ(BP_HEAD)

	var/target_species = species.name
	var/mouth_covered_target = wear_mask || check_mouth_coverage() || (target_species in SPECIES_NO_MOUTH) || !has_organ(BP_HEAD)

	var/has_hands = user.has_organ(BP_L_HAND) && user.has_organ(BP_R_HAND)
	var/has_hands_target = has_organ(BP_L_HAND) && has_organ(BP_R_HAND)

	var/adjacent = user.Adjacent(src)

	LAZYINITLIST(data[null])
	if(has_hands && adjacent)
		LAZYINITLIST(data["Руки"])
		data["Руки"] += "handshake'>Пожать руку"
		data["Руки"] += "cheer'>Похлопать по спине/плечу"
		data["Руки"] += "fixform'>Поправить одежду"
		data["Руки"] += "draw'>Трясти за плечо"
		data["Руки"] += "five'>Дать пять"
		if(has_hands_target)
			data["Руки"] += "give'>Передать предмет"
		if(target_species in SPECIES_HAS_TAIL)
			data["Руки"] += "pull'><font color='red'>Дернуть за хвост!</font>"
		data["Руки"] += "slap'><font color='red'>Дать пощечину!</font>"
		if(w_uniform)
			data["Руки"] += "grab'><font color='red'>Схватить за воротник</font>"
		data["Руки"] += "knock'><font color='red'>Дать подзатыльник</font>"

	if(adjacent && !mouth_covered && !mouth_covered_target)
		LAZYINITLIST(data["Лицо"])
		data["Лицо"] += "lick'>Лизнуть в щеку"

	..()

/mob/living/carbon/human/on_interaction(mob/living/carbon/human/user, interaction)
	. = ..()
	if(.)
		return .

	var/user_species = user.species.name
	var/mouth_covered = user.wear_mask || user.check_mouth_coverage() || (user_species in SPECIES_NO_MOUTH) || !user.has_organ(BP_HEAD)

	var/target_species = species.name
	var/mouth_covered_target = wear_mask || check_mouth_coverage() || (target_species in SPECIES_NO_MOUTH) || !user.has_organ(BP_HEAD)

	var/has_hands = user.has_organ(BP_L_HAND) && user.has_organ(BP_R_HAND) && user.can_use_hands()
	var/has_hands_target = has_organ(BP_L_HAND) && has_organ(BP_R_HAND) && can_use_hands()

	var/adjacent = user.Adjacent(src)
	var/sel_zone = user.zone_sel.selecting

	if(interaction == "scratch" && adjacent && has_hands)
		if(sel_zone == BP_HEAD && !(target_species in SPECIES_NO_EARS))
			return "<B>[user]</B> [pick("чешет за ухом", "чешет голову")] <B>[src]</B>."
		return "<B>[user]</B> чешет <B>[src]</B>."

	if(interaction == "handshake" && adjacent && has_hands && has_hands_target)
		return "<B>[user]</B> жмет руку <B>[src]</B>."

	if(interaction == "cheer" && adjacent && has_hands)
		return "<B>[user]</B> похлопывает <B>[src]</B> по [(sel_zone in BP_ARMS_HANDS) ? "плечу" : "спине"]."

	if(interaction == "fixform" && adjacent && has_hands)
		return "<B>[user]</B> поправляет одежду на <B>[src]</B>."

	if(interaction == "draw" && adjacent && has_hands)
		return "<B>[user]</B> трясет <B>[src]</B> за плечо."

	if(interaction == "five" && adjacent && has_hands && has_hands_target)
		playsound(loc, 'mods/_fd/mob_interactions/sounds/slap.ogg', 50, 1, -1)
		return "<B>[user]</B> дает <B>[src]</B> пять."

	if(interaction == "give" && adjacent)
		user.give(src)
		return

	if(interaction == "slap" && adjacent && has_hands)
		var/obj/item/organ/external/bodypart = get_organ(BP_HEAD)
		var/slap = SPAN_DANGER("[user] дает [src] пощечину!")
		if(sel_zone == BP_GROIN)
			bodypart = get_organ(BP_GROIN)
			slap = SPAN_DANGER("[user] шлепает [src] по заднице!")

		if(sel_zone == BP_MOUTH)
			slap = SPAN_DANGER("[user] дает [src] по губе!")

		if(bodypart && bodypart.pain <= 2)
			bodypart.add_pain(10)

		playsound(loc, 'mods/_fd/mob_interactions/sounds/slap.ogg', 50, 1, -1)
		user.do_attack_animation(src)
		return slap

	if(interaction == "pull" && adjacent && has_hands)
		if(prob(30))
			var/obj/item/organ/external/groin = get_organ(BP_GROIN)
			if(groin.pain <= 3)
				groin.add_pain(4)
			return SPAN_DANGER("[user] дергает [src] за хвост!")
		else
			return SPAN_DANGER("[user] пытается поймать [src] за хвост!")

	if(interaction == "knock" && adjacent && has_hands)
		var/obj/item/organ/external/bodypart = get_organ(BP_HEAD)
		if(bodypart && bodypart.pain <= 2)
			bodypart.add_pain(5)
		user.do_attack_animation(src)
		playsound(loc, 'sound/weapons/throwtap.ogg', 50, 1, -1)
		return SPAN_DANGER("[user] дает [src] подзатыльник!")

	if(interaction == "grab" && adjacent && has_hands && w_uniform)
		if(!user.species.attempt_grab(user, src))
			return
		face_atom(user)
		return SPAN_DANGER("[user] агрессивно хватает [src] за воротник!")

	if(interaction == "lick" && adjacent && !mouth_covered && !mouth_covered_target)
		if(prob(10))
			return "<B>[user]</B> особо тщательно лизнул[user.gender == FEMALE ? "а":""] <B>[src]</B>."
		else
			return "<B>[user]</B> лизнул[user.gender == FEMALE ? "а":""] <B>[src]</B> в щеку."
