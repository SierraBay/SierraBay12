/mob/living/carbon/throw_item(atom/target)
	if (istype(loc, /obj/item/holder))
		var/obj/item/holder/H = loc
		if (istype(H.loc, /obj/item/organ/internal/stomach))
			return

	src.throw_mode_off()
	if(src.stat || !target)
		return
	if(target.type == /obj/screen) return

	var/atom/movable/item = src.get_active_hand()

	if(!item) return

	var/throw_range = item.throw_range
	var/itemsize
	if (istype(item, /obj/item/grab))
		var/obj/item/grab/G = item
		item = G.throw_held() //throw the person instead of the grab
		if(ismob(item))
			var/mob/M = item

			//limit throw range by relative mob size
			throw_range = round(M.throw_range * min(src.mob_size/M.mob_size, 1))
			itemsize = round(M.mob_size/4)
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T && usr == src)
				var/start_T_descriptor = SPAN_COLOR("#6b5d00", "[start_T] \[[start_T.x],[start_T.y],[start_T.z]\] ([start_T.loc])")
				var/end_T_descriptor = SPAN_COLOR("#6b4400", "[start_T] \[[end_T.x],[end_T.y],[end_T.z]\] ([end_T.loc])")
				admin_attack_log(usr, M, "Threw the victim from [start_T_descriptor] to [end_T_descriptor].", "Was from [start_T_descriptor] to [end_T_descriptor].", "threw, from [start_T_descriptor] to [end_T_descriptor], ")

	else if (istype(item, /obj/item))
		var/obj/item/I = item
		itemsize = I.w_class

	if(!unEquip(item))
		return
	if(!item || !isturf(item.loc))
		return

	var/message = "\The [src] has thrown \the [item]."
	var/skill_mod = 0.2
	if(!skill_check(SKILL_HAULING, min(round(itemsize - ITEM_SIZE_HUGE) + 2, SKILL_MAX)))
		if(prob(30))
			Weaken(2)
			message = "\The [src] barely manages to throw \the [item], and is knocked off-balance!"
	else
		skill_mod += 0.2

	skill_mod += 0.8 * (get_skill_value(SKILL_HAULING) - SKILL_MIN)/(SKILL_MAX - SKILL_MIN)
	throw_range *= skill_mod

	//actually throw it!
	src.visible_message(SPAN_WARNING("[message]"), range = min(itemsize*2,world.view))
	playsound(src, 'mods/new_sounds/sounds/throw.ogg', 50, 1)
	if(!src.lastarea)
		src.lastarea = get_area(src.loc)
	if(!check_space_footing())
		if(prob((itemsize * itemsize * 10) * MOB_MEDIUM/src.mob_size))
			var/direction = get_dir(target, src)
			step(src,direction)
			space_drift(direction)

	item.throw_at(target, throw_range, item.throw_speed * skill_mod, src)
