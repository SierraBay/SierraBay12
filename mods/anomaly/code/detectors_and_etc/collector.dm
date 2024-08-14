/obj/item/collector
	name = "artefact collector"
	icon = 'mods/anomaly/icons/collectors.dmi'
	icon_state = "collector_empty"
	var/closed = FALSE
	var/obj/item/artefact/stored_artefact

/obj/item/collector/Initialize()
	. = ..()

/obj/item/collector/use_tool(obj/item/item, mob/living/user, list/click_params)
	. = ..()
	if(istype(item, /obj/item/artefact))
		try_insert_artefact(user, item)
	else if(isScrewdriver(item))
		try_pop_out_artefact(user)

/obj/item/collector/proc/try_insert_artefact(mob/living/user, obj/item/item)
	if(!stored_artefact)
		to_chat(user,SPAN_NOTICE("You inserted [item] in [src]."))
		insert_artefact(user, item)

/obj/item/collector/proc/insert_artefact(mob/living/user, obj/item/item)
	if(!user.unEquip(item))
		return
	stored_artefact = item
	item.forceMove(src)
	update_icon()

/obj/item/collector/proc/try_pop_out_artefact(mob/living/user)
	if(stored_artefact)
		to_chat(user,SPAN_NOTICE("You pop-out [stored_artefact] from [src]."))
		pop_out_artefact(user)

/obj/item/collector/proc/pop_out_artefact(mob/living/user)
	stored_artefact.forceMove(get_turf(src))
	user.put_in_hands(stored_artefact)
	stored_artefact = null
	update_icon()

/obj/item/collector/attack_self(mob/living/user)
	. = ..()
	if(istype(stored_artefact, /obj/item/artefact/pruzhina))
		var/obj/item/cell/spawned_cell = new /obj/item/cell/pruzhina(get_turf(src))
		spawned_cell.charge = stored_artefact.stored_energy
		qdel(src)
	else
		if(!closed)
			close_collector()
			playsound(src, 'mods/anomaly/sounds/collector_closed.ogg', 25, FALSE  )
		else
			open_collector()
			playsound(src, 'mods/anomaly/sounds/collector_open.ogg', 25, FALSE  )

/obj/item/collector/proc/close_collector()
	closed = TRUE
	update_icon()

/obj/item/collector/proc/open_collector()
	closed = FALSE
	update_icon()

/obj/item/collector/on_update_icon()
	. = ..()
	if(closed)
		icon_state = "collector_closed"
	else if(istype(stored_artefact, /obj/item/artefact/pruzhina))
		icon_state = "collector_pruzhina"
	else if(istype(stored_artefact, /obj/item/artefact/svetlyak))
		icon_state = "collector_svetlyak"
	else if(istype(stored_artefact, /obj/item/artefact/zjar))
		icon_state = "collector_zjar"
	else if(istype(stored_artefact, /obj/item/artefact/gravi))
		icon_state = "collector_gravi"
	else if(!stored_artefact)
		icon_state = "collector_empty"


/obj/item/collector/pruzhina_inside
	icon_state = "collector_pruzhina"
	stored_artefact = new /obj/item/artefact/pruzhina

/obj/item/collector/zjar_inside
	icon_state = "collector_zjar"
	stored_artefact = new /obj/item/artefact/zjar

/obj/item/collector/svetlyak_inside
	icon_state = "collector_svetlyak"
	stored_artefact = new /obj/item/artefact/svetlyak

/obj/item/collector/gravi_inside
	icon_state = "collector_gravi"
	stored_artefact = new /obj/item/artefact/gravi

/datum/design/item/bluespace/collector
	name = "artefact collector"
	desc = "Container designed for safe transportation and use of anomalous formations."
	id = "collector"
	req_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_BLUESPACE = 2, TECH_POWER = 4)
	materials = list(MATERIAL_ALUMINIUM = 1000, MATERIAL_STEEL = 5000, MATERIAL_GLASS = 2500, MATERIAL_PLASTEEL = 2500, MATERIAL_PLASTIC = 1000)
	build_path = /obj/item/collector
	sort_string = "VAWAB"
