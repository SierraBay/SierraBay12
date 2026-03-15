// Sandevistan Augment
// Provides mechanical speed boost, bullet dodging, and phasewalk (mob passing).
// Costs Brain Loss upon activation.

/obj/item/organ/internal/augment/active/sandevistan
	name = "Sandevistan spine implant"
	desc = "An extremely risky and powerful spinal implant that pushes the user's nervous system into overdrive, providing incredible speed and evasiveness at the cost of brain damage upon activation."
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "sandevistan"
	action_button_name = "Activate Sandevistan"
	augment_slots = AUGMENT_CHEST
	augment_flags = AUGMENT_BIOLOGICAL | AUGMENT_SCANNABLE
	origin_tech = list(TECH_COMBAT = 5, TECH_ESOTERIC = 5, TECH_BIO = 5)

	var/datum/effect/trail/afterimage/sandevistan/trail
	var/static/list/dodge_sounds = list('sound/weapons/punchmiss.ogg')
	var/original_slowdown
	var/next_tick = 0

	// We'll keep our own 'active' flag to track the buff state
	var/active = FALSE

/obj/item/device/augment_implanter/sandevistan
	name = "augment implanter (Sandevistan)"
	augment = /obj/item/organ/internal/augment/active/sandevistan

/datum/uplink_item/item/augment/aug_sandevistan
	name = "Sandevistan (chest, active)"
	desc = "A highly dangerous spinal reflex booster. Activating it provides extreme speed and evasion, but deals scaling brain damage based on other cybernetics in the body. This augment is incompatible with synthetic biologies."
	item_cost = 40
	path = /obj/item/device/augment_implanter/sandevistan

/obj/item/organ/internal/augment/active/sandevistan/proc/get_brain_damage_cost(mob/living/carbon/human/H)
	var/dmg = 3
	for(var/O in H.organs)
		var/obj/item/organ/external/limb = O
		if(length(limb.implants))
			dmg += length(limb.implants) * 0.5
	for(var/I in H.internal_organs)
		if(istype(I, /obj/item/organ/internal/augment))
			dmg += 1
	return dmg

/obj/item/organ/internal/augment/active/sandevistan/proc/take_brain_damage(mob/living/carbon/human/H)
	var/dmg = get_brain_damage_cost(H)
	var/obj/item/organ/internal/brain/sponge = H.internal_organs_by_name[BP_BRAIN]
	if(sponge)
		var/brain_health = sponge.max_damage - sponge.damage

		to_chat(H, SPAN_WARNING("Current brain status: [round(max(0,(1 - sponge.damage/sponge.max_damage)*100))]%"))

		if(brain_health < 60 || brain_health <= dmg + 1)
			if(brain_health <= dmg + 1)
				dmg = max(0, brain_health - 1)
				if(dmg > 0)
					H.adjustBrainLoss(dmg)

			to_chat(H, SPAN_DANGER("WARNING: Nervous system indicators have reached critical levels! Sandevistan has been forcibly shut down."))
			if(active)
				deactivate_sandevistan(H)
			return FALSE

	// Apply normal damage if we didn't hit the critical threshold
	H.adjustBrainLoss(dmg)
	return TRUE

/obj/item/organ/internal/augment/active/sandevistan/Process()
	..()
	if(world.time <= next_tick)
		return

	next_tick = world.time + 1 SECOND

	if(active && owner && istype(owner, /mob/living/carbon/human))
		take_brain_damage(owner)

/obj/item/organ/internal/augment/active/sandevistan/activate()
	if(!can_activate())
		return

	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	if(!active)
		// Activating
		if(!take_brain_damage(H))
			return // Cannot activate if HP is too low

		to_chat(H, SPAN_DANGER("You feel a severe, agonizing spike in your nervous system as the Sandevistan engages!"))

		if(!trail)
			trail = new /datum/effect/trail/afterimage/sandevistan()
			var/matrix/M = matrix()
			M.Scale(1.05)
			trail.set_up(H, 12, M, "#00ffff")
		trail.start()

		H.playsound_local(get_turf(H), 'mods/RnD/sounds/sandy_act.ogg', 100, 1)

		active = TRUE
		to_chat(H, SPAN_NOTICE("You activate the Sandevistan."))
	else
		// Deactivating
		deactivate_sandevistan(H)

/obj/item/organ/internal/augment/active/sandevistan/proc/deactivate_sandevistan(mob/living/carbon/human/H)
	if(!active)
		return
	active = FALSE
	if(trail)
		trail.stop()

	H.playsound_local(get_turf(H), 'mods/RnD/sounds/sandy_exit.ogg', 100, 1)
	to_chat(H, SPAN_NOTICE("You deactivate the Sandevistan."))

/obj/item/organ/internal/augment/active/sandevistan/proc/dodge_bullet(mob/living/carbon/human/user, obj/item/projectile/P, mob/attacker, def_zone)
	if(!active)
		return FALSE

	// Calculate direction if it's a projectile
	if(P)
		var/attack_dir = get_dir(get_turf(user), P.starting)
		var/bad_arc = reverse_direction(user.dir)

		// If projectile attack comes from behind, do not dodge
		if(attack_dir && (attack_dir & bad_arc))
			return FALSE

	user.visible_message(SPAN_DANGER("\The [user] moves with such speed that \the attack misses!"))
	user.dodge_animation(attacker = attacker)
	playsound(user.loc, pick(dodge_sounds), 50, 1)

	return TRUE

// --- Hook Into Human ---

// Hook into hand attack to dodge
/mob/living/carbon/human/resolve_hand_attack(damage, mob/living/user, target_zone)
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(S.dodge_bullet(src, null, user, target_zone))
					return null // Return null to signify miss
	return ..()

// Hook into item attack to dodge
/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, target_zone)
	for(var/A in internal_organs)
		if(istype(A, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = A
			if(S.active)
				if(S.dodge_bullet(src, null, user, target_zone))
					return null // Return null to signify miss
	return ..()

// Hook into bullet acting to dodge
/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(S.dodge_bullet(src, P, null, def_zone))
					return PROJECTILE_FORCE_MISS
	return ..()

// Hook into human movement delay to provide speed boost while active
/mob/living/carbon/human/movement_delay(singleton/move_intent/using_intent)
	. = ..()
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				. *= 0.25
				break

// Hook into CanPass to let humans pass through other mobs while Sandevistan is active
/mob/living/carbon/human/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	// If mover is the one with Sandevistan passing through this human
	if(ismob(mover))
		var/mob/M = mover
		if(ishuman(M))
			var/mob/living/carbon/human/HM = M
			for(var/I in HM.internal_organs)
				if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
					var/obj/item/organ/internal/augment/active/sandevistan/S = I
					if(S.active)
						return 1 // Allow phasewalking through this mob
	// If this human has Sandevistan active, let moving mobs pass
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(ismob(mover))
					return 1 // Allow this mob to pass through others too

	return ..()

// ----------------------------------------------------
// Afterimage Trail Sandevistan
// ----------------------------------------------------

/obj/effect/afterimage/sandevistan
	name = "afterimage"
	icon = null
	icon_state = null
	mouse_opacity = 0
	anchored = TRUE

/obj/effect/afterimage/sandevistan/proc/setup(atom/target, duration = 10, matrix/M, new_color)
	if(!target)
		return
	appearance = target.appearance
	dir = target.dir
	appearance_flags |= KEEP_TOGETHER
	alpha = 255
	mouse_opacity = 0
	if(new_color)
		color = new_color

	var/matrix/new_transform = matrix(transform)
	if(M)
		new_transform.Multiply(M)

	animate(src, transform = new_transform, alpha = 0, time = duration, easing = SINE_EASING)
	QDEL_IN(src, duration)

/datum/effect/trail/afterimage/sandevistan
	parent_type = /datum/effect/trail
	trail_type = /obj/effect/afterimage/sandevistan
	duration_of_effect = 10
	specific_turfs = list(/turf)
	var/matrix/end_matrix
	var/trail_color
	var/last_spawn_tick = 0
	var/obj/effect/afterimage/sandevistan/last_spawned_afterimage
	var/turf/tick_start_loc
	on = FALSE

/datum/effect/trail/afterimage/sandevistan/set_up(atom/atom, duration = 10, matrix/M, new_color)
	..()
	duration_of_effect = duration
	end_matrix = M
	trail_color = new_color

/datum/effect/trail/afterimage/sandevistan/start()
	if(on)
		return
	on = TRUE
	if(holder)
		RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_move), override = TRUE)

/datum/effect/trail/afterimage/sandevistan/stop()
	if(!on)
		return
	on = FALSE
	if(holder)
		UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	last_spawned_afterimage = null
	tick_start_loc = null

/datum/effect/trail/afterimage/sandevistan/proc/on_move(datum/source, turf/old_loc, forced)
	SIGNAL_HANDLER
	if(!on || !holder)
		return

	var/turf/T = get_turf(holder)
	if(T == old_loc)
		return

	if(last_spawn_tick == world.time)
		if(last_spawned_afterimage && tick_start_loc)
			last_spawned_afterimage.set_dir(get_dir(tick_start_loc, T))
		return

	if(is_type_in_list(T, specific_turfs) && (!max_number || number < max_number))
		last_spawned_afterimage = new trail_type(old_loc)
		last_spawn_tick = world.time
		tick_start_loc = old_loc
		number++
		addtimer(new Callback(src, PROC_REF(decrement_number)), duration_of_effect)
		last_spawned_afterimage.setup(holder, duration_of_effect, end_matrix, trail_color)

/datum/effect/trail/afterimage/sandevistan/proc/decrement_number()
	number--

/datum/effect/trail/afterimage/sandevistan/effect(obj/effect/afterimage/sandevistan/T)
	return
