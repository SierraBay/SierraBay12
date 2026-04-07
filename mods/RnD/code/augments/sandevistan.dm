// Sandevistan Augment
// Duration scales with Athletics skill (3s × level) and installed augment count (+0.5s × level per augment).
// Cooldown = 5× the actual time the Sandevistan was active.
// Deals melee strikes when phasing through mobs on harm intent.

/obj/item/organ/internal/augment/active/sandevistan
	name = "Sandevistan spine implant"
	desc = "A powerful spinal implant that overclocks the user's nervous system into overdrive, granting incredible speed and evasiveness. Performance scales with your athletics and installed cybernetics."
	icon = 'mods/RnD/icons/augment.dmi'
	icon_state = "sandevistan"
	action_button_name = "Activate Sandevistan"
	augment_slots = AUGMENT_CHEST
	augment_flags = AUGMENT_BIOLOGICAL | AUGMENT_MECHANICAL | AUGMENT_SCANNABLE
	origin_tech = list(TECH_COMBAT = 5, TECH_ESOTERIC = 5, TECH_BIO = 5)

	var/datum/effect/trail/afterimage/sandevistan/trail
	var/static/list/dodge_sounds = list('sound/weapons/punchmiss.ogg')
	var/next_tick = 0

	var/active = FALSE
	var/cooldown_until = 0  // world.time when cooldown expires
	var/activate_time = 0   // world.time when Sandevistan was activated

	/// Base duration per Athletics level, in deciseconds (default 30 = 3s)
	var/base_duration_per_level = 3 SECONDS
	/// Bonus duration per augment per Athletics level, in deciseconds (default 5 = 0.5s)
	var/aug_duration_per_level = 0.5 SECONDS
	/// Multiplier for cooldown time (default 5 = 5x)
	var/aug_cooldown_multiplier = 5
	/// If TRUE, deactivation applies zero cooldown
	var/no_cooldown = FALSE

/obj/item/device/augment_implanter/sandevistan
	name = "augment implanter (Sandevistan)"
	augment = /obj/item/organ/internal/augment/active/sandevistan

/datum/uplink_item/item/augment/aug_sandevistan
	name = "Sandevistan (chest, active)"
	desc = "An experimental spinal implant designed to supercharge neural signal processing. When activated, it creates a “time dilation” effect for the user, dramatically boosting speed, reflexes, and evasive capability. Requires excellent physical conditioning to withstand the intense strain it places on the body, and demands precise control to avoid overload"
	item_cost = 40
	path = /obj/item/device/augment_implanter/sandevistan

// ---------------------------------------------------------------------------
// Duration calculation
// ---------------------------------------------------------------------------

/// Returns duration in deciseconds: (3 + 0.5 * augment_count) * ath_level * 10
/obj/item/organ/internal/augment/active/sandevistan/proc/get_sandevistan_duration(mob/living/carbon/human/H)
	var/ath = H.get_skill_value(SKILL_HAULING) // 1-5
	var/augment_count = 0
	// Count internal augments (excluding self)
	for(var/I in H.internal_organs)
		if(istype(I, /obj/item/organ/internal/augment) && I != src)
			augment_count++
	// Count augment implants embedded in external limbs
	for(var/O in H.organs)
		var/obj/item/organ/external/limb = O
		if(length(limb.implants))
			for(var/imp in limb.implants)
				if(istype(imp, /obj/item/organ/internal/augment) && imp != src)
					augment_count++
	// base_duration_per_level per ath level base, +aug_duration_per_level per ath level per augment
	return (base_duration_per_level * ath) + (aug_duration_per_level * ath * augment_count)

// ---------------------------------------------------------------------------
// Cooldown gate
// ---------------------------------------------------------------------------

/obj/item/organ/internal/augment/active/sandevistan/can_activate()
	if(!..())
		return FALSE
	if(world.time < cooldown_until)
		var/remaining = round((cooldown_until - world.time) / 10, 0.1)
		to_chat(owner, SPAN_WARNING("Sandevistan is cooling down. [remaining]s remaining."))
		return FALSE
	return TRUE

// ---------------------------------------------------------------------------
// Process: auto-deactivate when duration expires
// ---------------------------------------------------------------------------

/obj/item/organ/internal/augment/active/sandevistan/Process()
	..()
	if(world.time <= next_tick)
		return
	next_tick = world.time + 1 SECOND
	if(active && owner && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(world.time >= activate_time + get_sandevistan_duration(H))
			deactivate_sandevistan(H)

// ---------------------------------------------------------------------------
// Activate / Deactivate
// ---------------------------------------------------------------------------

/obj/item/organ/internal/augment/active/sandevistan/activate()
	if(!can_activate())
		return
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	if(!active)
		to_chat(H, SPAN_DANGER("Your nervous system surges into overdrive as the Sandevistan engages!"))

		if(!trail)
			trail = new /datum/effect/trail/afterimage/sandevistan()
			var/matrix/M = matrix()
			M.Scale(1.05)
			trail.set_up(H, 12, M, "#00ffff")
		trail.organ_ref = src
		trail.start()

		H.playsound_local(get_turf(H), 'mods/RnD/sounds/sandy_act.ogg', 100, 1)
		activate_time = world.time
		active = TRUE
		var/dur = get_sandevistan_duration(H)
		to_chat(H, SPAN_NOTICE("Sandevistan active. Maximum duration: [round(dur / 10, 0.1)]s."))
	else
		deactivate_sandevistan(H)

/obj/item/organ/internal/augment/active/sandevistan/proc/deactivate_sandevistan(mob/living/carbon/human/H)
	if(!active)
		return
	active = FALSE

	var/used = world.time - activate_time
	if(no_cooldown)
		cooldown_until = 0
		if(trail)
			trail.stop()
		H.playsound_local(get_turf(H), 'mods/RnD/sounds/sandy_exit.ogg', 100, 1)
		to_chat(H, SPAN_NOTICE("Sandevistan deactivated. No cooldown."))
	else
		cooldown_until = world.time + used * aug_cooldown_multiplier
		if(trail)
			trail.stop()
		H.playsound_local(get_turf(H), 'mods/RnD/sounds/sandy_exit.ogg', 100, 1)
		to_chat(H, SPAN_NOTICE("Sandevistan deactivated. Cooldown: [round((used * aug_cooldown_multiplier) / 10, 0.1)]s."))

// ---------------------------------------------------------------------------
// Phasewalk melee strike
// ---------------------------------------------------------------------------

/// Strike victim with each non-gun melee weapon held in hand.
/obj/item/organ/internal/augment/active/sandevistan/proc/do_sandevistan_strike(mob/living/carbon/human/H, mob/living/victim)
	set waitfor = FALSE
	if(!H || !victim)
		return
	for(var/obj/item/weapon in list(H.l_hand, H.r_hand))
		if(!weapon)
			continue
		if(istype(weapon, /obj/item/gun))
			continue
		if(!weapon.force)
			continue
		victim.use_weapon(weapon, H)

// ---------------------------------------------------------------------------
// EMP Effect
// ---------------------------------------------------------------------------

/obj/item/organ/internal/augment/active/sandevistan/emp_act(severity)
	if(active && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		to_chat(H, SPAN_DANGER("Your Sandevistan forcefully shuts down from the electromagnetic pulse!"))
		deactivate_sandevistan(H)

	var/emp_cooldown = (severity == EMP_ACT_HEAVY) ? 120 SECONDS : 60 SECONDS
	cooldown_until = max(cooldown_until, world.time + emp_cooldown)
	if(ishuman(owner))
		to_chat(owner, SPAN_WARNING("Sandevistan system reports an EMP overload. Forced cooldown applied."))

	..()

// ---------------------------------------------------------------------------
// Bullet dodge
// ---------------------------------------------------------------------------

/obj/item/organ/internal/augment/active/sandevistan/proc/dodge_bullet(mob/living/carbon/human/user, obj/item/projectile/P, mob/attacker, def_zone)
	if(!active)
		return FALSE

	if(P)
		var/attack_dir = get_dir(get_turf(user), P.starting)
		var/bad_arc = reverse_direction(user.dir)
		if(attack_dir && (attack_dir & bad_arc))
			return FALSE

	user.visible_message(SPAN_DANGER("\The [user] moves with such speed that \the attack misses!"))
	user.dodge_animation(attacker = attacker)
	playsound(user.loc, pick(dodge_sounds), 50, 1)
	return TRUE

// ---------------------------------------------------------------------------
// Human hooks
// ---------------------------------------------------------------------------

// Dodge hand attacks
/mob/living/carbon/human/resolve_hand_attack(damage, mob/living/user, target_zone)
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(S.dodge_bullet(src, null, user, target_zone))
					return null
	return ..()

// Dodge item attacks; ALSO block gun use by an active Sandevistan wielder
/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, target_zone)
	// Dodge check for victim
	for(var/A in internal_organs)
		if(istype(A, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = A
			if(S.active)
				if(S.dodge_bullet(src, null, user, target_zone))
					return null
	return ..()

// Dodge projectiles
/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(S.dodge_bullet(src, P, null, def_zone))
					return PROJECTILE_FORCE_MISS
	return ..()

// Speed boost while active
/mob/living/carbon/human/movement_delay(singleton/move_intent/using_intent)
	. = ..()
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				. *= 0.25
				break

// Phasewalk: let Sandevistan user pass through mobs (and vice-versa)
/mob/living/carbon/human/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(ismob(mover))
		var/mob/M = mover
		if(ishuman(M))
			var/mob/living/carbon/human/HM = M
			for(var/I in HM.internal_organs)
				if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
					var/obj/item/organ/internal/augment/active/sandevistan/S = I
					if(S.active)
						return 1
	for(var/I in internal_organs)
		if(istype(I, /obj/item/organ/internal/augment/active/sandevistan))
			var/obj/item/organ/internal/augment/active/sandevistan/S = I
			if(S.active)
				if(ismob(mover))
					return 1
	return ..()

// ----------------------------------------------------
// Afterimage Trail
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
	/// Back-reference to the sandevistan organ for melee strike access
	var/obj/item/organ/internal/augment/active/sandevistan/organ_ref

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

	// Melee strikes: check mobs left behind at old_loc when phasing on harm intent
	if(organ_ref?.active && ishuman(holder))
		var/mob/living/carbon/human/H = holder
		if(H.a_intent == I_HURT)
			for(var/mob/living/victim in old_loc)
				if(victim != H)
					organ_ref.do_sandevistan_strike(H, victim)

	// Afterimage generation
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
