/mob/living/exosuit/Destroy()
	//Пассажиров сбрасываем первыми: всё, что останется внутри меха, удалится вместе с ним,
	//а отрисовке оставшихся пассажиров нужен ещё не удалённый корпус
	if(passenger_compartment)
		external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS)

	selected_system = null

	for (var/mob/pilot as anything in pilots)
		remove_pilot(pilot)

	hud_health = null
	hud_power = null
	hud_power_control = null
	hud_camera = null

	QDEL_NULL_LIST(hud_elements)

	for (var/hardpoint in hardpoints)
		qdel(hardpoints[hardpoint])
	// SIERRA-REMOVE hardpoints.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoints = null

	QDEL_NULL(access_card)
	QDEL_NULL(L_leg)
	QDEL_NULL(R_leg)
	QDEL_NULL(L_arm)
	QDEL_NULL(R_arm)
	QDEL_NULL(head)
	QDEL_NULL(body)

	for(var/hardpoint in hardpoint_hud_elements)
		var/obj/screen/movable/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
		H.owner = null
		H.holding = null
		qdel(H)
	// SIERRA-REMOVE hardpoint_hud_elements.Cut() //Это место из-за мода рантаймит, в целом бесполезный кусок кода ибо удаление всё само сделает
	hardpoint_hud_elements = null
	. = ..()


/mob/living/exosuit/death(gibbed = FALSE)
	// Выкинуть пилотов
	if(LAZYLEN(pilots))
		hatch_locked = 0
		for(var/pilot in pilots)
			remove_pilot(pilot)

	//Спавним остатки меха
	var/obj/wreck = new wreckage_path(get_turf(src), src, gibbed)
	wreck.name = "wreckage of \the [name]"

	//Взрыв и огонь если гибнут
	if(gibbed)
		src.visible_message(message = SPAN_BAD("[src] explodes!"), range = 7)
		var/turf/my_turf = get_turf(src)
		for(var/mob/living/detected_living in range(1, my_turf))
			detected_living.fire_stacks = max(2, detected_living.fire_stacks)
			detected_living.IgniteMob()
		explosion(my_turf, 2, EX_ACT_LIGHT)
	else
		//Иначе просто развалиться
		src.visible_message(message = SPAN_BAD("[src] grinds to a halt before collapsing!"), range = 7)
	//Пассажиры слезают, пока корпус ещё числится за мехом: он нужен отрисовке тех, кто ещё сидит
	if(passenger_compartment)
		external_leaving_passenger(mode = MECH_DROP_ALL_PASSENGERS)
	//Части, которые забрали обломки, мех с собой не удаляет
	release_salvaged_parts()
	qdel(src)

///Части меха так, как их находят в обломках: сдвоенные ноги — одним предметом, своим держателем
/mob/living/exosuit/proc/get_salvageable_parts()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/mech_component/part in list(head, body, L_arm, R_arm))
		. += part
	if(R_leg && L_leg && R_leg.doubled_owner && R_leg.doubled_owner == L_leg.doubled_owner)
		. += R_leg.doubled_owner
		return
	for(var/obj/item/mech_component/leg in list(L_leg, R_leg))
		. += leg

///Мех отпускает части, которые лежат уже не в нём: `Destroy()` удаляет только то, что осталось при мехе
/mob/living/exosuit/proc/release_salvaged_parts()
	for(var/part_var in list("head", "body", "L_arm", "R_arm", "L_leg", "R_leg"))
		var/obj/item/mech_component/part = vars[part_var]
		if(part && part.loc != src)
			vars[part_var] = null
			part.update_component_owner()

/mob/living/exosuit/gib()
	death(gibbed = TRUE)
