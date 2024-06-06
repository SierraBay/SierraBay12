/obj/item/mag_table_plate
	name = "circuit board (magnetic table)"
	icon_state = "mainboard"
	icon = 'icons/obj/module.dmi'

/obj/structure/mag_unfinished
	name = "Magnetic Table Frame"
	desc = "It is unfinished magnetic table. Good for merchants."
	icon = 'mods/_fd/fd_assets/icons/structures/mag_table.dmi'
	icon_state = "magnetic_table"

/obj/structure/mag_unfinished/use_tool(obj/item/W as obj, mob/user as mob)
	SHOULD_CALL_PARENT(FALSE)
	if(istype(W, /obj/item/mag_table_plate))
		if(do_after(user, 50))
			new /obj/structure/table/mag(src.loc)
			qdel(W)
			qdel(src)
	if(isWrench(W) && user.a_intent == I_HURT)
		new /obj/item/stack/material/plasteel/ten(src.loc)
		qdel(src)

/obj/structure/table/mag
	name = "Magnetic Table"
	desc = "It is simple magnetic table. Good for merchants."
	icon = 'mods/_fd/fd_assets/icons/structures/mag_table.dmi'
	icon_state = "magnetic_table_disabled"
	var/icon_state_open = "magnetic_table_disabled"
	var/icon_state_closed = "magnetic_table_enabled"
	req_access = list()
	can_plate = 0
	can_reinforce = 0
	flipped = -1
	var/owned = 0
	var/locked = 0

/obj/structure/table/mag/Initialize()
	. = ..()
	verbs -= /obj/structure/table/verb/do_flip
	verbs -= /obj/structure/table/proc/do_put
	name = "Magnetic Table"
	health_max = 20
	health_current = 20

/obj/structure/table/mag/on_update_icon()
	if (locked)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_open
	return

/obj/structure/table/mag/can_connect()
	return FALSE

/obj/structure/table/mag/damage_health(damage, damage_type, damage_flags = EMPTY_BITFIELD, severity, skip_can_damage_check = FALSE)
	. = ..()
	if(get_damage_value() >= 10 && locked)
		toggle_lock()


/obj/structure/table/mag/Destroy()
	if(locked)
		toggle_lock()
	..()

/obj/structure/table/mag/break_to_parts(full_return = 0)
	if(locked)
		toggle_lock()
	..()

/obj/structure/table/mag/proc/toggle_lock()
	if(get_damage_value() >= 10 && !locked)
		return
	locked = !locked
	update_icon()
	for (var/obj/item/I in get_turf(src))
		I.anchored = locked
	playsound(src, 'sound/effects/storage/briefcase.ogg', 100, 1)

/obj/structure/table/mag/use_tool(obj/item/W, mob/living/user as mob, click_params)
	if(isrobot(user))
		return
/*	if(istype(W, /obj/item/psychic_power/psielectro)) ПСИОНИКА
		if(istype(user) && user.psi && !user.psi.suppressed && user.psi.get_rank(PSI_METAKINESIS) >= PSI_RANK_OPERANT)
			if(do_after(user, 50))
				to_chat(user, "<span class='warning'>Одним лишь касанием вы переписываете доступ, привязанный к этому столу...</span>")
				owned = FALSE
		else
			to_chat(user, "<span class='warning'>Как бы того не хотелось, но вы ещё слишком неумелы, чтобы взламывать подобное.</span>")
			return */
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/modular_computer))
		var/obj/item/card/id/id_card = /obj/item/card/id
		if(owned)
			if(allowed(usr))
				toggle_lock()
				visible_message(SPAN_NOTICE("[usr] [locked ? "" : "un"]locked [src]!"))
				return
		else if(!owned)
			id_card = istype(id_card) ? id_card : user.GetIdCard()
			var/access_type = input(user, "Choose access you need.") as null | anything in id_card.access
			if (!access_type)
				return
			req_access = list(access_type)
			owned = TRUE
	if(isitem(W))
		if(user.drop_from_inventory(W, src.loc))
			auto_align(W, click_params)
			W.anchored = locked
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	..()

/obj/structure/table/mag/dismantle(obj/item/wrench/W, mob/user)
	reset_mobs_offset()
	if(manipulating) return
	manipulating = 1
	user.visible_message("<span class='notice'>\The [user] begins dismantling \the [src].</span>",
						"<span class='notice'>You begin dismantling \the [src].</span>")
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(!do_after(user, 20, src))
		manipulating = 0
		return
	user.visible_message("<span class='notice'>\The [user] dismantles \the [src].</span>",
						"<span class='notice'>You dismantle \the [src].</span>")
	new /obj/item/stack/material/plasteel/ten(src.loc)
	new /obj/item/mag_table_plate(src.loc)
	qdel(src)
	return

/obj/structure/table/mag/CtrlClick()
	return

/datum/stack_recipe/furniture/mag_tables
	title = "magnetic table"
	result_type = /obj/structure/mag_unfinished
	req_amount = 20
	time = 50

/material/plasteel/generate_recipes(reinforce_material)
	..()
	. += new/datum/stack_recipe/furniture/mag_tables(src)
