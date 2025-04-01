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

/obj/item/mech_equipment/drill/afterattack(atom/target, mob/living/user, inrange, params)
	if (!..()) // /obj/item/mech_equipment/afterattack implements a usage guard
		return

	if (istype(target, /obj/item/material/drill_head))
		attach_head(target, user)
		return

	if (!drill_head)
		to_chat(user, SPAN_WARNING("\The [src] doesn't have a head!"))
		return

	if (ismob(target))
		var/mob/tmob = target
		if (tmob.unacidable)
			to_chat(user, SPAN_WARNING("\The [target] can't be drilled away."))
			return
		else
			to_chat(tmob, FONT_HUGE(SPAN_DANGER("You're about to get drilled - dodge!")))

	else if (isobj(target))
		var/obj/tobj = target
		if (tobj.unacidable)
			to_chat(user, SPAN_WARNING("\The [target] can't be drilled away."))
			return

	else if (istype(target, /turf/unsimulated))
		to_chat(user, SPAN_WARNING("\The [target] can't be drilled away."))
		return

	var/obj/item/cell/mech_cell = owner.get_cell()
	mech_cell.use(active_power_use * CELLRATE) //supercall made sure we have one

	var/delay = 3 SECONDS //most things
	switch (drill_head.material.brute_armor)
		if (15 to INFINITY) delay = 0.5 SECONDS //voxalloy on a good roll
		if (10 to 15) delay = 1 SECOND //titanium, diamond
		if (5 to 10) delay = 2 SECONDS //plasteel, steel
	owner.setClickCooldown(delay)

	playsound(src, 'sound/mecha/mechdrill.ogg', 50, 1)
	owner.visible_message(
		SPAN_WARNING("\The [owner] starts to drill \the [target]."),
		blind_message = SPAN_WARNING("You hear a large motor whirring.")
	)

	var/obj/particle_emitter/sparks/EM
	if (istype(target, /turf/simulated/mineral))
		EM = new/obj/particle_emitter/sparks/debris(get_turf(target), delay, target.color)
	else
		EM = new(get_turf(target), delay)

	EM.set_dir(reverse_direction(owner.dir))

	if (!do_after(owner, delay, target, (DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) & ~DO_USER_CAN_TURN))
		if(EM)
			EM.particles.spawning = FALSE
		return
	if(EM)
		EM.particles.spawning = FALSE
	if (src != owner.selected_system)
		to_chat(user, SPAN_WARNING("You must keep \the [src] selected to use it."))
		return
	if (drill_head.durability <= 0)
		drill_head.shatter()
		drill_head = null
		return

	if (istype(target, /turf/simulated/mineral))
		var/list/atoms_in_range = range(1, target)
		for (var/turf/simulated/mineral/mineral in atoms_in_range)
			if (!(get_dir(owner, mineral) & owner.dir))
				continue
			drill_head.durability -= 1
			mineral.GetDrilled()
		scoop_ore(target)
		return

	if (istype(target, /turf/simulated/floor/asteroid))
		var/list/atoms_in_range = range(1, target)
		for (var/turf/simulated/floor/asteroid/asteroid in atoms_in_range)
			if (!(get_dir(owner, asteroid) & owner.dir))
				continue
			drill_head.durability -= 1
			asteroid.gets_dug()
		scoop_ore(target)
		return

	if (istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/wall = target
		var/wall_hardness = max(wall.material.hardness, wall.reinf_material ? wall.reinf_material.hardness : 0)
		if (wall_hardness > drill_head.material.hardness)
			to_chat(user, SPAN_WARNING("\The [wall] is too hard to drill through with \the [drill_head]."))
			drill_head.durability -= 2
			return

	var/audible = "loudly grinding machinery"
	if (iscarbon(target)) //splorch
		audible = "a terrible rending of metal and flesh"

	owner.visible_message(
		SPAN_DANGER("\The [owner] drives \the [src] into \the [target]."),
		blind_message = SPAN_WARNING("You hear [audible].")
	)
	log_and_message_admins("used [src] on [target]", user, owner.loc)
	drill_head.durability -= 1
	target.ex_act(EX_ACT_HEAVY)


/obj/item/mech_equipment/drill/steel
	drill_head = /obj/item/material/drill_head/steel

/obj/item/mech_equipment/drill/titanium
	drill_head = /obj/item/material/drill_head/titanium

/obj/item/mech_equipment/drill/plasteel
	drill_head = /obj/item/material/drill_head/plasteel

/obj/item/mech_equipment/drill/diamond
	drill_head = /obj/item/material/drill_head/diamond
