/obj/machinery/door/airlock/use_tool(obj/item/C, mob/living/user, list/click_params)

	if (istype(C, /obj/item/paper/talisman/emp)) //220_cult - обязательная строчка для взаимодействия талисмана со шлюзом
		return

	return ..()
