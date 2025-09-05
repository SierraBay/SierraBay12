/mob/living/exosuit/proc/dismantle()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	var/obj/structure/heavy_vehicle_frame/frame = new(get_turf(src))
	for(var/hardpoint in hardpoints)
		remove_system(hardpoint, force = 1)
	hardpoints.Cut()
	if(body)
		frame.body = body
		body.forceMove(frame)
		body.update_component_owner()
		body = null
	if(head)
		frame.head = head
		head.forceMove(frame)
		head.update_component_owner()
		head = null
	if(R_leg && R_leg.doubled_owner && L_leg && L_leg.doubled_owner)
		R_leg.owner = null
		L_leg.owner = null
		frame.R_leg = R_leg
		frame.L_leg = L_leg
		R_leg.doubled_owner.forceMove(frame)
		R_leg.forceMove(frame)
		L_leg.forceMove(frame)
		R_leg.update_component_owner()
		L_leg.update_component_owner()
		R_leg = null
		L_leg = null
	if(R_leg && !R_leg.doubled_owner)
		R_leg.owner = null
		frame.R_leg = R_leg
		R_leg.forceMove(frame)
		R_leg.update_component_owner()
		R_leg = null
	if(L_leg && !L_leg.doubled_owner)
		L_leg.owner = null
		frame.L_leg = L_leg
		L_leg.forceMove(frame)
		L_leg.update_component_owner()
		L_leg = null
	if(R_arm)
		R_arm.owner = null
		frame.R_arm = R_arm
		R_arm.forceMove(frame)
		R_arm.update_component_owner()
		R_arm = null
	if(L_arm)
		L_arm.owner = null
		frame.L_arm = L_arm
		L_arm.forceMove(frame)
		L_arm.update_component_owner()
		L_arm = null

	frame.is_wired = FRAME_WIRED_ADJUSTED
	frame.is_reinforced = FRAME_REINFORCED_WELDED
	frame.set_name = name
	frame.name = "frame of \the [frame.set_name]"
	frame.material = material
	frame.queue_icon_update()

	qdel(src)
