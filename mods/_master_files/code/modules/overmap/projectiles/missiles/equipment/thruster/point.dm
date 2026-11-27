/obj/item/missile_equipment/thruster/point
	guidance_type = /datum/missile_guidance/point

/obj/item/missile_equipment/thruster/point/configure(mob/user)
	return guidance.configure(src, user)

/obj/item/missile_equipment/thruster/point/should_enter(obj/overmap/site)
	return guidance.should_enter(site)
