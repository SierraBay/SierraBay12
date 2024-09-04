/mob/living/silicon/pai/fold_up()
	var/obj/item/integrated_circuit/manipulation/ai/A = src.loc
	if(istype(A))
		A.unload_ai()
		src.visible_message("[src] ejects from [A].")
	..()