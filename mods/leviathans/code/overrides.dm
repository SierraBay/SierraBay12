/obj/meteor
	// Meteor health for point defense tracking
	var/health = 1

/obj/meteor/proc/take_damage(amount)
	health -= amount
	if(health <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

// Override point defense to target meteors with health
/obj/machinery/pointdefense/finish_shot(weakref/target)
	var/datum/extension/local_network_member/pointdefense = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = pointdefense.get_local_network()
	var/obj/machinery/pointdefense_control/PC = null
	if(lan)
		var/list/pointdefense_controllers = lan.get_devices(/obj/machinery/pointdefense_control)
		PC = LAZYACCESS(pointdefense_controllers, 1)
	if(istype(PC))
		PC.targets -= target

	engaging = FALSE
	last_shot = world.time
	var/obj/meteor/M = target.resolve()
	if(!istype(M))
		return

	var/obj/item/projectile/beam/pointdefense/beam = new (get_turf(src))
	playsound(src, 'sound/effects/heavy_cannon_blast.ogg', 75, 1)
	use_power_oneoff(idle_power_usage * 10)
	beam.launch(M.loc)

	M.take_damage(1)

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

		L.take_damage(rand(400, 600), last_charge_type_path) // Use cached type path since charge is deleted
		return
	return ..()

// Overrides the overmap projectile entering z-level to intercept and damage leviathans in the same tile
/obj/overmap/projectile
	var/list/encountered_leviathans

/obj/overmap/projectile/check_enter()
	var/turf/overmap_turf = get_turf(src)
	for(var/obj/overmap/event/leviathan/L in overmap_turf)
		if(L in encountered_leviathans)
			continue
		if(actual_missile && actual_missile.armed)
			var/obj/item/missile_equipment/payload/payload = actual_missile.equipment[MISSILE_PART_PAYLOAD]
			if(payload && payload.is_dangerous)
				if(prob(33)) // Miss chance
					LAZYADD(encountered_leviathans, L)
					continue

				L.take_damage(rand(400, 600), payload) // Pass the payload object for type-checking
				qdel(actual_missile) // Cleanup the actual structure, which deletes the overmap projectile
				return TRUE // We intercepted it, no need to process zs enter

	return ..()
