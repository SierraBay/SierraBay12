/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(hasHUD(user, HUD_IT) && arePowerSystemsOn())
		to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [NTNet_id]")))
