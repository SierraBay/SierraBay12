// Immovable rod LITE. Cleanly cleaves through a set amount of dense objects
/obj/structure/missile/breacher
	name = "HBM67 missile"
	overmap_name = "breacher missile"
	desc = "A breacher missile developed by Haephestus Industries. It is widely known and feared for eating through hulls like butter, often making it through multiple wall sections before coming to a halt."

	equipment = list(
		/obj/item/missile_equipment/thruster,
		/obj/item/missile_equipment/autoarm/breacher
	)

	// how many pieces of dense objects can this missile still punch through
	var/inertia = 16

// This doesn't have a detonation mechanism, it simply punches through hulls.
/obj/structure/missile/breacher/Bump(atom/obstacle)
	if(!active)
		return

	// cleaves through anything that isn't a shield while it still has inertia left
	if(istype(obstacle, /obj/shield))
		inertia = 0
	else
		obstacle.ex_act(2)
		inertia--

	if(!inertia)
		..()
		walk(src, 0)
		qdel(src)
//		log_and_message_admins("A breacher missile reached it's destignation (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[obstacle.x];Y=[obstacle.y];Z=[obstacle.z]'>JMP</a>)")

/obj/structure/missile/use_tool(obj/item/I, mob/user)
	SHOULD_CALL_PARENT(FALSE)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(isScrewdriver(I))
		maintenance_hatch_open = !maintenance_hatch_open
		to_chat(user, "You [maintenance_hatch_open ? "open" : "close"] the maintenance hatch of \the [src].")

		update_icon()
		return

	if(maintenance_hatch_open)
		if(istype(I, /obj/item/missile_equipment))
			if(istype(I, /obj/item/missile_equipment/payload))
				for(var/obj/item/missile_equipment/payload/L in equipment)
					to_chat(user, "\The [src] can only have one payload.")
					return

			if(istype(I, /obj/item/missile_equipment/thruster))
				for(var/obj/item/missile_equipment/thruster/T in equipment)
					to_chat(user, "\The [src] can only have one thruster.")
					return

			if(istype(I, /obj/item/missile_equipment/autoarm))
				for(var/obj/item/missile_equipment/autoarm/T in equipment)
					to_chat(user, "\The [src] can only have one activator.")
					return

			if(!user.unEquip(I, src))
				return
			equipment += I
			to_chat(user, "You install \the [I] into \the [src].")

			update_icon()
			return

		if(isCrowbar(I))
			var/obj/item/missile_equipment/removed_component = input("Which component would you like to remove?") as null|obj in equipment
			if(removed_component)
				to_chat(user, "You remove \the [removed_component] from \the [src].")
				user.put_in_hands(removed_component)
				equipment -= removed_component

				update_icon()
			return

	if(I.attack_verb.len)
		visible_message("<span class='warning'>\The [src] have been [pick(I.attack_verb)] with \the [I][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='warning'>\The [src] have been attacked with \the [I][(user ? " by [user]." : ".")]</span>")

	var/damage = round(I.force / 2.0)

	if(isWelder(I))
		var/obj/item/weldingtool/WT = I

		if(WT.remove_fuel(0, user))
			damage = 20
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	if(damage <= 2)
		return

	health -= damage
	healthcheck(damage)

/obj/structure/missile/breacher/fall()
	if(active)
		return
	..()

/obj/structure/missile/breacher/he
	name = "HBM92 missile"
	equipment = list(
		/obj/item/missile_equipment/thruster,
		/obj/item/missile_equipment/autoarm/breacher,
		/obj/item/missile_equipment/payload/explosive
	)
