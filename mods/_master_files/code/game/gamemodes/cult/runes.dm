// The target search used to require `M.key`, but a dead player's key moves to their ghost the
// moment they observe, so it was null on practically every corpse and the rune could never find
// anyone. `ckey` stays behind on the body - it is what the defibrillator uses to locate the ghost
// too - so that is the right thing to test here.
// The rune also tells the ghost that their body is being called back, says which half of the
// ritual is missing instead of only fizzling, and takes the pronouns off the corpse rather than
// off the caster.
/obj/rune/revive/cast(mob/living/user)
	var/mob/living/carbon/human/target
	var/obj/item/device/soulstone/source
	for(var/mob/living/carbon/human/M in get_turf(src))
		if(!M.is_real_dead())
			continue
		if(!iscultist(M))
			continue
		if(!M.ckey)
			continue
		target = M
		break
	if(!target)
		to_chat(user, SPAN_OCCULT("The rune finds no fallen brother here to call back."))
		return fizzle(user)
	for(var/obj/item/device/soulstone/S in get_turf(src))
		if(S.full && !S.shade.key)
			source = S
			break
	if(!source)
		to_chat(user, SPAN_OCCULT("The rune has no unspent soul stone to draw life from."))
		return fizzle(user)
	if(target.ssd_check())
		to_chat(find_dead_player(target.ckey, TRUE), SPAN_OCCULT("The cult is calling your body back. Re-enter your corpse if you want to return to life."))
	target.rejuvenate()
	source.set_full(0)
	speak_incantation(user, "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	var/datum/pronouns/pronouns = target.choose_from_pronouns()
	target.visible_message(SPAN_WARNING("\The [target]'s eyes glow with a faint red as [pronouns.he] stands up, slowly starting to breathe again."), SPAN_WARNING("Life... I'm alive again..."), "You hear liquid flow.")
