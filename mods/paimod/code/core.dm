/obj/item/device/paicard
	var/list/modlimits = list(
			"common"	=	5,
			"skins"		=	2,
			"hacking"	=	6,
			"memory"	=	6,
			"special"	=	1,
		)
/obj/item/device/paicard/proc/check_for_free_place(obj/item/paimod/P)
	var/list/mods = list()
	for(var/obj/item/paimod/PM in contents)
		mods.Add(PM)
	var/T = P.special_limit_tag
	if(LAZYLEN(mods) > modlimits["common"]) return 0
	else if(!T) return 1
	else
		var/mods_withT = 0
		for(var/obj/item/paimod/PM in mods) if(PM.special_limit_tag == T) mods_withT += 1
		if(mods_withT > modlimits[T]) return 0
		else return 1

/mob/living/silicon/pai
	var/hack_speed = 1
	var/is_hack_covered = 0
	var/is_advanced_holo = 0

/mob/living/silicon/pai/proc/RecalculateModifications()
	if(length(card.contents))
		is_hack_covered = initial(is_hack_covered)
		is_advanced_holo = initial(is_advanced_holo)
		hack_speed = initial(hack_speed)
		for(var/obj/item/paimod/P in card.contents)
			if(card.check_for_free_place(P))
				P.is_broken ? (P.on_brocken_recalculate(src)) : (P.on_recalculate(src))
			else
				P.dropInto(get_turf(card))
				card.visible_message(SPAN_NOTICE("[card] haven't enough place to hold [P] and [card] threw [P] out."))
	update_verbs()

/obj/item/device/paicard/use_tool(obj/item/W, mob/user)
	. = ..()
	if(pai)
		if(istype(W, /obj/item/paimod))
			var/obj/item/paimod/PMOD = W
			if(PMOD.is_broken) visible_message(SPAN_NOTICE("[user] tried to install [PMOD] in [src], but nothing happened."))
			else if(check_for_free_place(PMOD))
				user.drop_from_inventory(PMOD)
				PMOD.forceMove(src)
				pai.RecalculateModifications()
				PMOD.on_install(pai, user)


// ========= Core =========
/obj/item/paimod
	name = "unknown personal AI modification module"
	desc = "This is unknown PAImod. You should not have this!"
	icon = 'packs/infinity/icons/obj/paimod.dmi'
	icon_state = "null"

	var/is_broken = 0
	var/mod_integrity = 100
	var/special_limit_tag

/obj/item/paimod/proc/on_install(mob/living/silicon/pai/P, mob/user)
	P.visible_message(SPAN_NOTICE("[user] installed [src] in [P.name]."))

/obj/item/paimod/proc/on_recalculate(mob/living/silicon/pai/P)

/obj/item/paimod/proc/on_update_memory(mob/living/silicon/pai/P)

/obj/item/paimod/proc/on_brocken_recalculate(mob/living/silicon/pai/P)
	P.visible_message("\icon[P]" + SPAN_WARNING("\the [P] sparks."))

/obj/item/paimod/proc/update_damage()
	if(mod_integrity <= 0)
		is_broken = 1
		update_icon()
/obj/item/paimod/on_update_icon()
	. = ..()
	icon_state = initial(icon_state)
	if(is_broken)
		icon_state = "[icon_state]_dead"
		desc += "<br><font color = '#f00'>It's broken.</font>"

/obj/item/paimod/use_tool(obj/item/W, mob/user)
	. = ..()
	if(W.force)
		visible_message(SPAN_DANGER("[user.name] attacks [src.name] with [W]!"))
		is_broken ? (mod_integrity = 0) : (mod_integrity -= W.force * 2)
		update_damage()

//сетап пИИ

/datum/category_item/player_setup_item/player_global/pai/update_pai_preview(mob/user)
	pai_preview = icon('icons/effects/128x48.dmi', bgstate)
	var/icon/pai = icon('mods/paimod/icons/pai.dmi', GLOB.possible_chassis[candidate.chassis], NORTH)
	pai_preview.Scale(48+32, 16+32)

	pai_preview.Blend(pai, ICON_OVERLAY, 25, 22)
	pai = icon('mods/paimod/icons/pai.dmi', GLOB.possible_chassis[candidate.chassis], WEST)
	pai_preview.Blend(pai, ICON_OVERLAY, 1, 9)
	pai = icon('mods/paimod/icons/pai.dmi', GLOB.possible_chassis[candidate.chassis], SOUTH)
	pai_preview.Blend(pai, ICON_OVERLAY, 49, 5)

	pai_preview.Scale(pai_preview.Width() * 2, pai_preview.Height() * 2)

	send_rsc(user, pai_preview, "pai_preview.png")
