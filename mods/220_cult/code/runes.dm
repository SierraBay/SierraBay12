/mob/proc/wrath_imbue()
	set category = "Cult Magic"
	set name = "Imbue: Wrath Burning"

	make_rune(/obj/rune/imbue/wrath, cost = 15)

/obj/rune/imbue/wrath
	cultname = "wrath burning imbue"
	papertype = /obj/item/paper/talisman/wrath

/mob/proc/burn_imbue()
	set category = "Cult Magic"
	set name = "Imbue: Burning"

	make_rune(/obj/rune/imbue/burn)

/obj/rune/imbue/burn
	cultname = "burning imbue"
	papertype = /obj/item/paper/talisman/burn

/mob/proc/hellbucket_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon HellWater"

	make_rune(/obj/rune/hellbucket, cost = 15)

/obj/rune/hellbucket
	cultname = "summon hellwater"

/obj/rune/hellbucket/cast(mob/living/user)
	new /obj/item/reagent_containers/glass/bucket/wood/cult(get_turf(src))
	speak_incantation(user, "N[pick("'","`")]ath chsz'rchesh tza'jink'tumakes!")
	visible_message("<span class='notice'>\The [src] disappears with a flash of red light.</span>", "You hear a pop.")
	qdel(src)

/mob/proc/hellhunter_rune()
	set category = "Cult Magic"
	set name = "Rune: Summon HellHunter equip"

	make_rune(/obj/rune/hellhunter, cost = 15, tome_required = 1)

/obj/rune/hellhunter
	cultname = "summon hellhunter equip"

/obj/rune/hellhunter/cast(mob/living/user)
	new /obj/item/device/flashlight/flashdark/stone(get_turf(src))
	new /obj/item/clothing/glasses/tacgoggles/cult(get_turf(src))
	new /obj/item/material/knife/ritual(get_turf(src))
	speak_incantation(user, "N[pick("'","`")]ath chip'ayiayan auyana!")
	visible_message("<span class='notice'>\The [src] disappears with a flash of red light.</span>", "You hear a pop.")
	qdel(src)

/mob/proc/hellstone_rune()
	set category = "Cult Magic"
	set name = "Rune: HellStone"

	make_rune(/obj/rune/hellstone, cost = 15, tome_required = 1)

/obj/rune/hellstone
	cultname = "summon hellstone"

/obj/rune/hellstone/cast(mob/living/user)
	new /obj/item/device/flashlight/flashdark/stone(get_turf(src))
	speak_incantation(user, "N[pick("'","`")]akkakkaya'iyakaiya!")
	visible_message("<span class='notice'>\The [src] disappears with a flash of red light.</span>", "You hear a pop.")
	qdel(src)

/obj/rune/blood_boil
	cultname = "blood boil"
	strokes = 4
	var/spamcheck = 0

/obj/rune/blood_boil/cast(mob/living/user)
	var/list/mob/living/cultists = get_cultists()
	if(length(cultists) < 3)
		return fizzle()

	if(spamcheck)
		return

	for(var/mob/living/M in cultists)
		M.say("Dedo ol[pick("'","`")]btoh!")
// твик старой руны - больше не позволено спамить кликами для инста-килла, но куковать у руны долго всё ещё опасно
	spamcheck = 1
	sleep(40)
	spamcheck = 0

	var/list/mob/living/previous = list()
	var/list/mob/living/current = list()
	while(length(cultists) >= 3)
		cultists = get_cultists()
		for(var/mob/living/carbon/M in viewers(src))
			if(iscultist(M))
				continue
			current |= M
			var/obj/item/nullrod/N = locate() in M
			if(N)
				continue
			M.take_overall_damage(5, 5)
			if(!(M in previous))
				if(M.should_have_organ(BP_HEART))
					to_chat(M, SPAN_DANGER("Your blood boils!"))
				else
					to_chat(M, SPAN_DANGER("You feel searing heat inside!"))
		previous = current.Copy()
		current.Cut()
		sleep(10)
