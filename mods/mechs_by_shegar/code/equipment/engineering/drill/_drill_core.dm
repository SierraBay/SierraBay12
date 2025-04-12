/obj/item/material/drill_head
	var/durability = 0
	name = "drill head"
	desc = "A replaceable drill head usually used in exosuit drills."
	icon = 'icons/obj/weapons/other.dmi'
	icon_state = "drill_head"

/obj/item/material/drill_head/proc/get_percent_durability()
	return round((durability / material.integrity) * 50)

/obj/item/material/drill_head/proc/get_visible_durability()
	switch (get_percent_durability())
		if (95 to INFINITY) . = "shows no wear"
		if (75 to 95) . = "shows some wear"
		if (50 to 75) . = "is fairly worn"
		if (10 to 50) . = "is very worn"
		else . = "looks close to breaking"

/obj/item/material/drill_head/examine(mob/user, distance)
	. = ..()
	to_chat(user, "It [get_visible_durability()].")


/obj/item/material/drill_head/steel
	default_material = MATERIAL_STEEL

/obj/item/material/drill_head/titanium
	default_material = MATERIAL_TITANIUM

/obj/item/material/drill_head/plasteel
	default_material = MATERIAL_PLASTEEL

/obj/item/material/drill_head/diamond
	default_material = MATERIAL_DIAMOND

/obj/item/material/drill_head/Initialize()
	. = ..()
	durability = 2 * material.integrity

/obj/item/mech_equipment/drill
	name = "drill"
	desc = "This is the drill that'll pierce the heavens!"
	icon_state = "mech_drill"
	restricted_hardpoints = list(HARDPOINT_LEFT_HAND, HARDPOINT_RIGHT_HAND)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	equipment_delay = 10
	heat_generation = 50

	//Drill can have a head
	var/obj/item/material/drill_head/drill_head
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)

/obj/item/mech_equipment/drill/Initialize()
	. = ..()
	if (ispath(drill_head))
		drill_head = new drill_head(src)

/obj/item/mech_equipment/drill/attack_self(mob/user)
	. = ..()
	if(.)
		if(drill_head)
			owner.visible_message(SPAN_WARNING("[owner] revs the [drill_head], menancingly."))
			playsound(src, 'sound/mecha/mechdrill.ogg', 50, 1)

/obj/item/mech_equipment/drill/get_hardpoint_maptext()
	if(drill_head)
		return "Integrity: [drill_head.get_percent_durability()]%"
	return

/obj/item/mech_equipment/drill/examine(mob/user, distance)
	. = ..()
	if (drill_head)
		to_chat(user, "It has a[distance > 3 ? "" : " [drill_head.material.name]"] drill head installed.")
		if (distance < 4)
			to_chat(user, "The drill head [drill_head.get_visible_durability()].")
	else
		to_chat(user, "It does not have a drill head installed.")

/obj/item/mech_equipment/drill/proc/attach_head(obj/item/material/drill_head/DH, mob/user)
	if (user && !user.unEquip(DH))
		return
	if (drill_head)
		visible_message(SPAN_NOTICE("\The [user] detaches \the [drill_head] mounted on \the [src]."))
		drill_head.dropInto(get_turf(src))
	user.visible_message(SPAN_NOTICE("\The [user] mounts \the [drill_head] on \the [src]."))
	DH.forceMove(src)
	drill_head = DH


/obj/item/mech_equipment/drill/use_tool(obj/item/I, mob/living/user, list/click_params)
	if (istype(I, /obj/item/material/drill_head))
		attach_head(I, user)
		return TRUE
	return ..()

/obj/item/mech_equipment/drill/proc/scoop_ore(at_turf)
	if (!owner)
		return
	for (var/hardpoint in owner.hardpoints)
		var/obj/item/item = owner.hardpoints[hardpoint]
		if (!istype(item))
			continue
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in item
		if (!ore_box)
			continue
		var/list/atoms_in_range = range(1, at_turf)
		for(var/obj/item/ore/ore in atoms_in_range)
			if (!(get_dir(owner, ore) & owner.dir))
				continue
			ore.Move(ore_box)

/obj/item/mech_equipment/drill/steel
	drill_head = /obj/item/material/drill_head/steel

/obj/item/mech_equipment/drill/titanium
	drill_head = /obj/item/material/drill_head/titanium

/obj/item/mech_equipment/drill/plasteel
	drill_head = /obj/item/material/drill_head/plasteel

/obj/item/mech_equipment/drill/diamond
	drill_head = /obj/item/material/drill_head/diamond
