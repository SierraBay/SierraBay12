// Per-instance timers are used instead of global lists/timers

/datum/component/defective_item
	var/quality = 50
	var/malfunction_chance = 10	// percent per check
	var/check_interval = 30	// seconds between scans
	var/defective_timer = null // per-instance timer id

/datum/component/defective_item/Initialize(design_quality = 50)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	quality = max(0, min(100, design_quality))
	malfunction_chance = max(10, (100 - quality))
	check_interval = quality > 80 ? 50 : quality > 60 ? 40 : quality > 40 ? 30 : 20

	var/obj/item/I = parent
	I.name = "[I.name] (defective)"
	I.desc += "\n<span class='warning'>WARNING: This item may malfunction or even explode!</span>"

	// Start a per-instance recurring timer that calls check_defect
	if(defective_timer)
		deltimer(defective_timer)
	defective_timer = addtimer(new Callback(src, PROC_REF(check_defect)), check_interval, TIMER_STOPPABLE)

	return ..()

/datum/component/defective_item/Destroy()
	// Stop per-instance timer if present
	if(defective_timer)
		deltimer(defective_timer)
		defective_timer = null
	return ..()


/datum/component/defective_item/proc/check_defect()
	// If the parent item is gone, ensure timer is cleared and abort
	if(!parent || QDELETED(parent))
		if(defective_timer)
			deltimer(defective_timer)
			defective_timer = null
		return

	var/explode_chance = 1 + (100 - quality) / 2  // 1% base + more for worse quality

	if(prob(explode_chance))
		explode_item()
		return

	if(prob(malfunction_chance))
		cause_malfunction()

	// Reschedule next check if still valid
	if(parent && !QDELETED(parent))
		if(defective_timer)
			deltimer(defective_timer)
		defective_timer = addtimer(new Callback(src, PROC_REF(check_defect)), check_interval, TIMER_STOPPABLE)


// Removed global scanning in favour of per-instance timers (do_global_scan no longer used)

/datum/component/defective_item/proc/explode_item()
	var/obj/item/I = parent
	var/turf/T = get_turf(I)
	if(T)
		T.visible_message(SPAN_DANGER("[I] suddenly EXPLODES in a fiery blast!"))
		explosion(T, 0, 0, 1, 3)
	qdel(I)

/datum/component/defective_item/proc/cause_malfunction()
	var/obj/item/I = parent
	var/severity = quality < 30 ? 3 : quality < 60 ? 2 : 1

	var/turf/T = get_turf(I)
	switch(severity)
		if(1)
			if(T)
				T.visible_message(SPAN_WARNING("[I] sparks and stops working."))
				sparks(1, 1, T)
		if(2)
			if(T)
				T.visible_message(SPAN_DANGER("[I] is sparking violently!"))
				sparks(3, 1, T)
				var/mob/living/holder = I.loc
				if(istype(holder))
					holder.apply_damage(rand(15, 30), DAMAGE_BURN, pick(BP_L_HAND, BP_R_HAND))
					to_chat(holder, SPAN_DANGER("[I] burns your hand!"))
		if(3)
			if(T)
				T.visible_message(SPAN_DANGER("[I] makes a deafening crack and EXPLODES!"))
				explosion(T, 0, 0, 1, 2)
				qdel(I)
