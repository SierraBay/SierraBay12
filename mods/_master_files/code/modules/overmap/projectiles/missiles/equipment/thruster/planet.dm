/obj/item/missile_equipment/thruster/planet
	guidance_type = /datum/missile_guidance/planet

/obj/item/missile_equipment/thruster/planet/is_target_valid(obj/overmap/site)
	return guidance.is_target_valid(site, src)

/obj/item/missile_equipment/thruster/planet/configure(mob/user)
	return guidance.configure(src, user)

/obj/item/missile_equipment/thruster/planet/on_enter_level(z_level)
	return guidance_enter_level(z_level)
