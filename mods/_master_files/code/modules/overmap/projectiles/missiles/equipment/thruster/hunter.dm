/obj/item/missile_equipment/thruster/hunter
	guidance_type = /datum/missile_guidance/hunter

/obj/item/missile_equipment/thruster/hunter/is_target_valid(obj/overmap/site)
	return guidance.is_target_valid(site, src)
