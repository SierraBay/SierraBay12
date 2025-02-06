/obj/item/stack/Initialize(mapload)
	. = ..()

	if (!mapload && isturf(loc))
		addtimer(new Callback(src, PROC_REF(stack_new)), 0)

/obj/item/stack/proc/stack_new()
	for (var/obj/item/stack/S in loc)
		if (S == src)
			continue
		if (S.stacktype == stacktype)
			transfer_to(S)

/obj/item/stack/Crossed(obj/o)
	addtimer(new Callback(src, PROC_REF(stack_crossed), o), 0)
	. = ..()

/obj/item/stack/proc/stack_crossed(obj/o)
	if (!o.throwing && loc == o.loc && isturf(loc) && istype(o, /obj/item/stack))
		var/obj/item/stack/S = o
		transfer_to(S)