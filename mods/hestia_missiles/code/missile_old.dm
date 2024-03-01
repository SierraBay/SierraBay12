/obj/structure/missile/locked
	name = "MK2 Universal Missile"
	desc = "An old mighty father of well-known MK3 Universal Missile. Cannot be modified in the field, but still popular due to it's ruggedness and cheap price."
	health = 200

/obj/structure/missile/locked/attackby(obj/item/I, mob/user)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(isWrench(I))
		playsound(loc, 'sound/items/scrape_clunk.ogg', 100)
		if (!active)
			active = 1
			to_chat(user, "<span class='notice'>You manually armed the [name], it's warhead priming mechanism is now active!</span>")
			playsound(loc, activation_sound, 100)
		else
			active = 0
			playsound(loc, 'sound/machines/defib_safetyOff.ogg', 100)
			to_chat(user, "<span class='notice'>You manually unarmed the [name], it's warhead priming mechanism is now off.</span>")

		add_fingerprint(user)
		return

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
			to_chat(user, "You can't modify this type of missile.")
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

/obj/structure/missile/locked/ex_act(severity, turf_breaker)
	if(detonating || !src)
		return

	if(active && prob(60))
		playsound(loc, activation_sound, 100)
		detonate(loc)
		return
