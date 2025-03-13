/mob/living/exosuit/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	. = ..()

	if(!access_card)
		access_card = new (src)

	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	sparks = new(src)

	// Grab all the supplied components.
	if(source_frame)
		if(source_frame.set_name)
			name = source_frame.set_name
		if(source_frame.head)
			source_frame.head.forceMove(src)
			head = source_frame.head
		if(source_frame.body)
			source_frame.body.forceMove(src)
			body = source_frame.body
		//Руки
		if(source_frame.R_arm)
			source_frame.R_arm.forceMove(src)
			R_arm = source_frame.R_arm
		if(source_frame.L_arm)
			source_frame.L_arm.forceMove(src)
			L_arm = source_frame.L_arm
		//Ноги
		if(source_frame.R_leg && source_frame.R_leg.doubled_owner && source_frame.L_leg && source_frame.L_leg.doubled_owner)
			source_frame.R_leg.doubled_owner.forceMove(src)
			source_frame.R_leg.forceMove(src)
			source_frame.L_leg.forceMove(src)
			R_leg = source_frame.R_leg
			L_leg = source_frame.L_leg
		if(source_frame.R_leg && !source_frame.R_leg.doubled_owner)
			source_frame.R_leg.forceMove(src)
			R_leg = source_frame.R_leg
		if(source_frame.L_leg && !source_frame.L_leg.doubled_owner)
			source_frame.L_leg.forceMove(src)
			L_leg = source_frame.L_leg
		if(source_frame.material)
			material = source_frame.material

	exosuit_data = new /datum/exosuit_holder(src)

	updatehealth()

	// Generate hardpoint list.
	var/list/component_descriptions
	for(var/obj/item/mech_component/comp in list(head, body, L_arm, R_arm, L_arm, R_arm))
		if(comp.exosuit_desc_string)
			LAZYADD(component_descriptions, comp.exosuit_desc_string)
		if(LAZYLEN(comp.has_hardpoints))
			for(var/hardpoint in comp.has_hardpoints)
				hardpoints[hardpoint] = null

	if(head && head.radio)
		radio = new(src)

	if(LAZYLEN(component_descriptions))
		desc = "[desc] It has been built with [english_list(component_descriptions)]."

	// Build icon.
	on_update_icon()
	generate_icons()
	// Create HUD.
	InitializeHud()
	passenger_compartment = new(src)
	maxHealth = (head.current_hp + head.unrepairable_damage) + (body.max_hp + body.unrepairable_damage + material.integrity) + (L_arm.current_hp + L_arm.unrepairable_damage) + (R_arm.current_hp + R_arm.unrepairable_damage)  + (L_leg.current_hp + L_leg.unrepairable_damage) + (R_leg.current_hp + R_leg.unrepairable_damage)
	max_heat = head.max_heat + body.max_heat + L_arm.max_heat + R_arm.max_heat + L_leg.max_heat + R_leg.max_heat
	health = maxHealth
	GPS = new(src)
	medscan = new(src)
	total_heat_cooling = head.heat_cooling + body.heat_cooling + L_leg.heat_cooling + R_leg.heat_cooling + L_arm.heat_cooling + R_arm.heat_cooling
	overheat_heat_generation = (head.emp_heat_generation/2) + (body.emp_heat_generation/2) + (L_arm.emp_heat_generation/2) + (R_arm.emp_heat_generation/2) +  (L_leg.emp_heat_generation/2) + (R_leg.emp_heat_generation/2)
	min_speed = (L_leg.min_speed + R_leg.min_speed)/2
	current_speed = min_speed
	max_speed = (L_leg.max_speed + R_leg.max_speed)/2
	currently_use_something = FALSE
	next_move = world.time

	total_weight = head.weight + body.weight + L_arm.weight + R_arm.weight + L_leg.weight + R_leg.weight
	//Расчитываем разгон меха. Вес будет являться модификатором
	total_acceleration = ((L_leg.acceleration + R_leg.acceleration)/2)  / ( total_weight / 1000)

	for(var/obj/item/mech_component/component  in parts_list)
		component.update_component_owner()
	active_arm = L_arm
