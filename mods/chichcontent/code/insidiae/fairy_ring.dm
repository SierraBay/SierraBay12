/datum/map_template/ruin/exoplanet/fairy_ring
	name = "fairy ring"
	id = "fairy_ring"
	description = "A tiny patch of life in a vast desert."
	prefix = "mods/chichcontent/maps/insidiae/"
	suffixes = list("fairy_ring.dmm")
	spawn_cost = 0.5
	template_flags = TEMPLATE_FLAG_CLEAR_CONTENTS|TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_NATURAL

/obj/fairy_ring_portal
	name = "entrance"
	desc = "You will need four adult men and a rope to pull out the poor fellow who fell in there."
	icon = 'icons/obj/portals.dmi'
	icon_state = "rift"
	density = FALSE
	anchored = TRUE
	invisibility = 60

/obj/fairy_ring_portal/Crossed(mob/M as mob|obj)
	if(!istype(M, /mob/living/carbon/human))
		return

	src.visible_message(SPAN_WARNING("\The [M] disappears right before your eyes!"))
	do_teleport(M, locate(world.maxx/2, world.maxy/2, pick(GLOB.using_map.player_levels)), 15, /singleton/teleport)
	return
