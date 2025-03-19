/obj/item/mech_equipment/ionjets
	name = "exosuit maneuvering unit"
	desc = "A testament to the fact that sometimes more is actually more. These oversized electric resonance boosters allow exosuits to move in microgravity and can even provide brief speed boosts. The stabilizers can be toggled with ctrl-click."
	icon_state = "mech_jet_off"
	restricted_hardpoints = list(HARDPOINT_BACK)
	restricted_software = list(MECH_SOFTWARE_UTILITY)
	active_power_use = 90 KILOWATTS
	passive_power_use = 0 KILOWATTS
	var/activated_passive_power = 2 KILOWATTS
	var/movement_power = 75
	origin_tech = list(TECH_ENGINEERING = 3, TECH_MAGNET = 3, TECH_PHORON = 3)
	var/datum/effect/trail/ion/ion_trail
	require_adjacent = FALSE
	var/stabilizers = FALSE
	var/slide_distance = 6
	disturb_passengers = TRUE
	heat_generation = 10


/obj/item/mech_equipment/ionjets/Initialize()
	. = ..()
	ion_trail = new /datum/effect/trail/ion()
	ion_trail.set_up(src)

/obj/item/mech_equipment/ionjets/proc/allowSpaceMove()
	if (!active)
		return FALSE

	var/obj/item/cell/C = owner.get_cell()
	if (istype(C))
		if (C.checked_use(movement_power * CELLRATE))
			return TRUE
		else
			deactivate()

	return FALSE

/obj/item/mech_equipment/ionjets/attack_self(mob/user)
	. = ..()
	if (!.)
		return

	if (active)
		deactivate()
	else
		activate()

/obj/item/mech_equipment/ionjets/CtrlClick(mob/user)
	if (owner && ((user in owner.pilots) || user == owner))
		if (active)
			stabilizers = !stabilizers
			to_chat(user, SPAN_NOTICE("You toggle the stabilizers [stabilizers ? "on" : "off"]"))
		return TRUE
	return ..()

/obj/item/mech_equipment/ionjets/proc/activate()
	passive_power_use = activated_passive_power
	ion_trail.start()
	active = TRUE
	update_icon()

/obj/item/mech_equipment/ionjets/deactivate()
	. = ..()
	passive_power_use = 0 KILOWATTS
	ion_trail.stop()
	update_icon()

/obj/item/mech_equipment/ionjets/on_update_icon()
	if (active)
		icon_state = "mech_jet_on"
		set_light(1, 1, l_color = COLOR_LIGHT_CYAN)
	else
		icon_state = "mech_jet_off"
		set_light(0)
	if(owner)
		owner.update_icon()

/obj/item/mech_equipment/ionjets/get_hardpoint_maptext()
	if (active)
		return "ONLINE - Stabilizers [stabilizers ? "on" : "off"]"
	else return "OFFLINE"

/obj/item/mech_equipment/ionjets/proc/slideCheck(turf/target)
	if (owner && istype(target))
		if ((get_dist(owner, target) <= slide_distance) && (get_dir(get_turf(owner), target) == owner.dir))
			return TRUE
	return FALSE

/obj/item/mech_equipment/ionjets/afterattack(atom/target, mob/living/user, inrange, params)
	. = ..()
	if (. && active)
		if (owner.z != target.z)
			to_chat(user, SPAN_WARNING("You cannot reach that level!"))
			return FALSE
		var/turf/TT = get_turf(target)
		if (slideCheck(TT))
			playsound(src, 'sound/magic/forcewall.ogg', 30, 1)
			owner.visible_message(
				SPAN_WARNING("\The [src] charges up in preparation for a slide!"),
				blind_message = SPAN_WARNING("You hear a loud hum and an intense crackling.")
			)
			new /obj/temporary(get_step(owner.loc, reverse_direction(owner.dir)), 2 SECONDS, 'icons/effects/effects.dmi',"cyan_sparkles")
			owner.setClickCooldown(2 SECONDS)
			if (do_after(owner, 2 SECONDS, target, (DO_DEFAULT | DO_PUBLIC_PROGRESS | DO_USER_UNIQUE_ACT) & ~DO_USER_CAN_TURN) && slideCheck(TT))
				owner.visible_message(SPAN_DANGER("Burning hard, \the [owner] thrusts forward!"))
				owner.throw_at(get_ranged_target_turf(owner, owner.dir, slide_distance), slide_distance, 1, owner, FALSE)
			else
				owner.visible_message(SPAN_DANGER("\The [src] sputters and powers down"))
				owner.sparks.set_up(3,0,owner)
				owner.sparks.start()

		else
			to_chat(user, SPAN_WARNING("You cannot slide there!"))
