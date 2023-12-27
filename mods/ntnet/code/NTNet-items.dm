//  HACSO's HUD and related interactions
// code\__defines\items_clothing.dm - used outside pack
// code\modules\mob\living\carbon\human\examine.dm - used outside pack

/obj/item/clothing/glasses/hud/it
	name = "IT special HUD"
	desc = "An augmented reality device that allows you to see doors NTNet ID's."
	icon = 'mods/NTNet/icons/obj_eyes.dmi'
	item_icons = list(slot_glasses_str = 'mods/NTNet/icons/onmob_eyes.dmi')
	icon_state = "ithud"
	off_state = "ithud_off"
	hud_type = HUD_IT
	body_parts_covered = 0

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (src.isElectrified())
		if (istype(mover, /obj/item))
			var/obj/item/i = mover
			if (i.matter && (MATERIAL_STEEL in i.matter) && i.matter[MATERIAL_STEEL] > 0)
				var/datum/effect/spark_spread/s = new /datum/effect/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()
