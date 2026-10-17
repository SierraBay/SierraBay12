/// Contact is checked on both completed paths, independently of SSobj processing order.
/obj/item/missile_equipment/payload/antimissile/do_overmap_work(obj/overmap/projectile/projectile)
	if (world.time < next_work)
		return FALSE
	next_work = world.time + cooldown
	return projectile.check_target_contact()

/obj/item/missile_equipment/payload/antimissile/proc/disable_target(obj/overmap/projectile/projectile, obj/overmap/projectile/target)
	if (QDELETED(projectile) || QDELETED(target) || target == projectile || !target.moving || projectile.actual_missile?.get_target() != target)
		return FALSE
	target.actual_missile?.self_destruct()
	if (!QDELETED(target))
		qdel(target)
	projectile.actual_missile?.self_destruct()
	if (!QDELETED(projectile))
		qdel(projectile)
	return TRUE
