/obj/machinery/computer/ship/disperser
	var/last_charge_type_path

// Overrides the OFD's default event destruction behavior
/obj/machinery/computer/ship/disperser/fire(mob/user)
	var/obj/structure/ship_munition/disperser_charge/C = get_charge()
	last_charge_type_path = C?.type
	return ..()

/obj/machinery/computer/ship/disperser/fire_at_event(obj/overmap/event/finaltarget, chargetype)
	if(istype(finaltarget, /obj/overmap/event/leviathan))
		var/obj/overmap/event/leviathan/L = finaltarget
		
		L.take_damage(500, last_charge_type_path) // Use cached type path since charge is deleted
		return
	return ..()

// Overrides the overmap projectile entering z-level to intercept and damage leviathans in the same tile
/obj/overmap/projectile/check_enter()
	var/turf/overmap_turf = get_turf(src)
	for(var/obj/overmap/event/leviathan/L in overmap_turf)
		if(actual_missile && actual_missile.armed)
			var/obj/item/missile_equipment/payload/payload = actual_missile.equipment[MISSILE_PART_PAYLOAD]
			if(payload && payload.is_dangerous)
				L.take_damage(500, payload) // Pass the payload object for type-checking

				// Optional visual effect
				var/datum/effect/explosion/E = new /datum/effect/explosion()
				E.set_up(overmap_turf)
				E.start()
				playsound(overmap_turf, 'sound/effects/explosionfar.ogg', 50, 1)

				qdel(actual_missile) // Cleanup the actual structure, which deletes the overmap projectile
				return TRUE // We intercepted it, no need to process zs enter

	return ..()
