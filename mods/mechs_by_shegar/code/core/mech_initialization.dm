/mob/living/exosuit/Initialize(mapload, obj/structure/heavy_vehicle_frame/source_frame)
	. = ..()

	if(!access_card) access_card = new (src)

	pixel_x = default_pixel_x
	pixel_y = default_pixel_y
	sparks = new(src)

	// Grab all the supplied components.
	if(source_frame)
		if(source_frame.set_name)
			name = source_frame.set_name
		if(source_frame.arms)
			source_frame.arms.forceMove(src)
			arms = source_frame.arms
		if(source_frame.legs)
			source_frame.legs.forceMove(src)
			legs = source_frame.legs
		if(source_frame.head)
			source_frame.head.forceMove(src)
			head = source_frame.head
		if(source_frame.body)
			source_frame.body.forceMove(src)
			body = source_frame.body
		if(source_frame.material)
			material = source_frame.material

	updatehealth()

	// Generate hardpoint list.
	var/list/component_descriptions
	for(var/obj/item/mech_component/comp in list(arms, legs, head, body))
		if(comp.exosuit_desc_string)
			LAZYADD(component_descriptions, comp.exosuit_desc_string)
		if(LAZYLEN(comp.has_hardpoints))
			for(var/hardpoint in comp.has_hardpoints)
				hardpoints[hardpoint] = null

	if(head && head.radio)
		radio = new(src)

	if(LAZYLEN(component_descriptions))
		desc = "[desc] It has been built with [english_list(component_descriptions)]."

	// Create HUD.
	InitializeHud()

	// Build icon.
	queue_icon_update()
	generate_icons()
	passenger_compartment = new(src)
	maxHealth = (body.current_hp + material.integrity) + head.current_hp + arms.current_hp + legs.current_hp
	max_heat = body.max_heat + head.max_heat + arms.max_heat + legs.max_heat
	health = maxHealth
	GPS = new(src)
	medscan = new(src)
	total_heat_cooling = head.heat_cooling + body.heat_cooling + arms.heat_cooling + legs.heat_cooling
	overheat_heat_generation = ((head.emp_heat_generation/2) + (arms.emp_heat_generation/2) + (body.emp_heat_generation/2) + (legs.emp_heat_generation/2))
	legs.current_speed = legs.min_speed
	currently_use_something = FALSE
	next_move = world.time

	total_weight = head.weight + arms.weight + body.weight + legs.weight
	//Расчитываем разгон меха. Вес будет являться модификатором
	total_acceleration = legs.acceleration / ( total_weight / 1000)

	for(var/obj/item/mech_component/component  in parts_list)
		component.update_component_owner()
