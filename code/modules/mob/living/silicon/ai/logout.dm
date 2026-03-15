/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O as anything in SSmachines.get_machinery_of_type(/obj/machinery/ai_status_display))
		O.mode = 0
	if(!isturf(loc))
		if (client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	src.view_core()
	return
