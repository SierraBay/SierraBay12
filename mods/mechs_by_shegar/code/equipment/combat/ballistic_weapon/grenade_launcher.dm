//Гранатомёт для меха СБ способный заряжать в себя некоторые боеприпасы (гранаты обычные лол)
/obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher
	name = "\improper Mounted \"ZH-MIH\" security grenade launcher"
	desc = "A huge automatic grenade launcher for mechs. Old, ancient, heavy—its design is way outdated. They don’t make them like this anymore."
	icon_state = "mech_granatomet"
	holding_type = /obj/item/gun/launcher/grenade/mech

/obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher/use_tool(obj/item/item, mob/living/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	holding.use_tool(item, user)


/obj/item/gun/launcher/grenade/mech
	has_safety = FALSE

/obj/item/gun/launcher/grenade/mech/load(obj/item/grenade/G, mob/user)
	if(!can_load_grenade_type(G, user))
		return

	if(LAZYLEN(grenades) >= max_grenades)
		to_chat(user, SPAN_WARNING("Полон."))
		return
	if(!user.unEquip(G, src))
		return
	grenades.Insert(1, G) //add to the head of the list, so that it is loaded on the next pump
	to_chat(user, SPAN_NOTICE("Граната заряжена."))
	if(!chambered)
		pump()

/obj/item/gun/launcher/grenade/mech/proc/unload_ammo(mob/user,allow_dump = FALSE)
	if(length(grenades))
		var/obj/item/grenade/G = grenades[length(grenades)]
		LIST_DEC(grenades)
		user.put_in_hands(G)
		user.visible_message("\The [user] removes \a [G] from [src].", SPAN_NOTICE("You remove \a [G] from \the [src]."))
	else if(chambered)
		user.visible_message("\The [user] removes \a [chambered] from [src].", SPAN_NOTICE("You remove \a [chambered] from \the [src]."))
		user.put_in_hands(chambered)
		chambered = null
	else
		to_chat(user, SPAN_WARNING("\The [src] is empty."))

/obj/item/gun/launcher/grenade/mech/loaded/Initialize()
	. = ..()

	var/list/grenade_types = list(
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/grenade/flashbang,
		/obj/item/grenade/empgrenade
		)

	var/grenade_type = pick(grenade_types)
	chambered = new grenade_type(src)
	for(var/i in grenade_types)
		var/magazine_grenade_type = pick(grenade_types)
		grenades += new magazine_grenade_type(src)

/obj/item/gun/launcher/grenade/mech/Fire(atom/target, mob/living/user, clickparams, pointblank, reflex)
	. = ..()
	pump()

/obj/item/gun/launcher/grenade/mech/proc/get_max_grenades()
	return max_grenades

/obj/item/mech_equipment/mounted_system/taser/ballistic/grenade_launcher/get_hardpoint_maptext()
	return //пока не пофиксил
