/mob/living/exosuit/dismantle()

	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/obj/structure/heavy_vehicle_frame/frame = new(get_turf(src))
	for(var/hardpoint in hardpoints)
		remove_system(hardpoint, force = 1)
	hardpoints.Cut()

	if(arms)
		frame.arms = arms
		arms.forceMove(frame)
		arms.update_component_owner()
		arms = null
	if(legs)
		frame.legs = legs
		legs.forceMove(frame)
		legs.update_component_owner()
		legs = null
	if(body)
		frame.body = body
		body.update_component_owner()
		body.forceMove(frame)
		body = null
	if(head)
		frame.head = head
		head.update_component_owner()
		head.forceMove(frame)
		head = null

	frame.is_wired = FRAME_WIRED_ADJUSTED
	frame.is_reinforced = FRAME_REINFORCED_WELDED
	frame.set_name = name
	frame.name = "frame of \the [frame.set_name]"
	frame.material = material
	frame.queue_icon_update()

	qdel(src)
