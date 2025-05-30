/datum/effect/trail/afterimage
	var/mob/living/carbon/human/H

/datum/effect/trail/afterimage/start()
	var/obj/item/rig_module/module = holder
	H = module.holder.wearer
	..()

/datum/effect/trail/afterimage/effect(obj/effect/T)
	if(H)
		T.set_dir(H.dir)
		T.appearance = H.appearance
		T.mouse_opacity = 0
		T.appearance_flags = KEEP_TOGETHER
		T.alpha = 190
		animate(T,alpha=0,time=5)
	return