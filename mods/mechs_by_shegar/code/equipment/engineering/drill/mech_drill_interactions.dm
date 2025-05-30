/atom/proc/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	return

/obj/item/mech_equipment/drill/resolve_attackby(atom/atom, mob/living/user, click_params)
	if(owner)
		return 0
	return ..()

/turf/simulated/wall/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	var/wall_hardness = max(material.hardness, reinf_material ? reinf_material.hardness : 0)
	if (wall_hardness > mech_drill.drill_head.material.hardness)
		to_chat(pilot, SPAN_WARNING("\The [src] is too hard to drill through with \the [mech_drill.drill_head]."))
	else
		src.ex_act(EX_ACT_HEAVY)
		mech_drill.damage_drill_head(1)

/turf/simulated/floor/asteroid/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	for (var/turf/simulated/floor/asteroid/asteroid in range(1, src))
		asteroid.gets_dug()
		mech_drill.scoop_ore(asteroid)
		mech_drill.damage_drill_head(1)

/turf/simulated/mineral/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	for (var/turf/simulated/mineral/mineral in range(1, src))
		mineral.GetDrilled()
		mech_drill.scoop_ore(src)
		mech_drill.damage_drill_head(1)

/obj/machinery/door/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	src.ex_act(EX_ACT_HEAVY)
	mech_drill.damage_drill_head(1)

/obj/structure/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	src.ex_act(EX_ACT_HEAVY)
	mech_drill.damage_drill_head(1)

/obj/structure/broken_door/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	Destroy()

/obj/item/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	Destroy()

/obj/machinery/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	Destroy()

/obj/item/artefact/mech_drill_interaction(mob/living/exosuit/mech, obj/item/mech_equipment/drill/mech_drill, mob/living/pilot)
	return
