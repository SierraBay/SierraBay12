/obj/item/psychic_power/telekinesis
	name = "telekinetic grip"
	maintain_cost = 3
	icon_state = "telekinesis"
	var/atom/movable/focus

/obj/item/psychic_power/telekinesis/Destroy()
	focus = null
	. = ..()

/obj/item/psychic_power/telekinesis/Process()
	if(!focus || !isturf(focus.loc) || get_dist(get_turf(focus), get_turf(owner)) > owner.psi.get_rank(PSI_PSYCHOKINESIS) * 3)
		owner.drop_from_inventory(src)
		return
	. = ..()

/obj/item/psychic_power/telekinesis/proc/set_focus(atom/movable/_focus)

	if(!_focus.simulated || !isturf(_focus.loc))
		return FALSE

	var/check_paramount
	if(ismob(_focus))
		var/mob/victim = _focus
		check_paramount = (victim.mob_size >= MOB_MEDIUM)
	else if(isobj(_focus))
		var/obj/thing = _focus
		check_paramount = (thing.w_class >= 5)
	else
		return FALSE

	if(check_paramount && owner.psi.get_rank(PSI_PSYCHOKINESIS) < PSI_RANK_GRANDMASTER)
		focus = _focus
		. = attack_self(owner)
		if(!.)
			to_chat(owner, SPAN_WARNING("\The [_focus] слишком тяжелый."))
		return FALSE

	focus = _focus
	ClearOverlays()
	var/image/I = image(icon = focus.icon, icon_state = focus.icon_state)
	I.color = focus.color
	I.CopyOverlays(focus)
	AddOverlays(I)
	return TRUE

/obj/item/psychic_power/telekinesis/attack_self(mob/user)
	user.visible_message(SPAN_NOTICE("\The [user] показывает странный жест."))
	sparkle()
	if (focus.do_simple_ranged_interaction(user))
		return focus.do_simple_ranged_interaction(user)
	else
		focus.attack_hand(user)

/obj/item/psychic_power/telekinesis/afterattack(atom/target, mob/living/user, proximity)

	if(!target || !user || (isobj(target) && !isturf(target.loc)) || !user.psi || !user.psi.can_use() || !user.psi.spend_power(8))
		return

	//user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.psi.set_cooldown(8)

	var/user_psi_leech = user.do_psionics_check(5, user)
	if(user_psi_leech)
		to_chat(user, SPAN_WARNING("Ты тянешься к \the [target], но твоя хватка размыта с помощью \the [user_psi_leech]..."))
		return

	if(target.do_psionics_check(5, user))
		to_chat(user, SPAN_WARNING("Твоя телекинетическая хватка пытается ухватить \the [target], но тщетно..."))
		return

	var/distance = get_dist(get_turf(user), get_turf(focus ? focus : target))
	if(distance > user.psi.get_rank(PSI_PSYCHOKINESIS) * 3)
		to_chat(user, SPAN_WARNING("Ты не дотягиваешься."))
		return FALSE

	if(target == focus)
		attack_self(user)
	else
		user.visible_message(SPAN_DANGER("\The [user] резко жестикулирует!"))
		sparkle()
		if(!isturf(focus.loc) && isitem(focus) && target.Adjacent(focus))
			var/obj/item/I = focus
			var/resolved = I.resolve_attackby(target, user)
			if(!resolved && target && I)
				I.afterattack(target,user,1) // for splashing with beakers
		else
			if(!focus.anchored)
				var/user_rank = owner.psi.get_rank(PSI_PSYCHOKINESIS)
				if(target == user)
					user.swap_hand()
					user.throw_mode_on()
					focus.throw_at(target, user_rank*2, 1, owner)
				else
					var/skill = (user.get_skill_value(SKILL_HAULING) - SKILL_MIN)/(SKILL_MAX - SKILL_MIN)
					focus.throw_at(target, user_rank*2, focus.throw_speed * skill + user_rank, owner)
				sleep(1)
				sparkle()
		//owner.drop_from_inventory(src)

/obj/item/psychic_power/telekinesis/proc/sparkle()
	set waitfor = 0
	if(focus)
		var/obj/overlay/O = new /obj/overlay(get_turf(focus))
		O.name = "sparkles"
		O.anchored = TRUE
		O.density = FALSE
		O.layer = FLY_LAYER
		O.set_dir(pick(GLOB.cardinal))
		O.icon = 'icons/effects/effects.dmi'
		O.icon_state = "nothing"
		flick("empdisable",O)
		sleep(5)
		qdel(O)
