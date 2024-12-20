/obj/item/mech_equipment/clamp
	heat_generation = 25

/obj/item/mech_equipment/clamp/afterattack(atom/target, mob/living/user, inrange, params)
	if(!module_can_be_used(target, user, inrange))
		return
	target.mech_clamp_interaction(user, src)
/*
		//attacking - Cannot be carrying something, cause then your clamp would be full
		else if(istype(target,/mob/living))
			var/mob/living/M = target
			if(user.a_intent == I_HURT)
				admin_attack_log(user, M, "attempted to clamp [M] with [src] ", "Was subject to a clamping attempt.", ", using \a [src], attempted to clamp")
				owner.setClickCooldown(owner.arms ? owner.arms.action_delay * 3 : 30) //This is an inefficient use of your powers
				if(prob(33))
					owner.visible_message(SPAN_DANGER("[owner] swings its [src] in a wide arc at [target] but misses completely!"))
					return
				M.attack_generic(owner, (owner.arms ? owner.arms.melee_damage * 1.5 : 0), "slammed") //Honestly you should not be able to do this without hands, but still
				M.throw_at(get_edge_target_turf(owner ,owner.dir),5, 2)
				to_chat(user, SPAN_WARNING("You slam [target] with [src.name]."))
				owner.visible_message(SPAN_DANGER("[owner] slams [target] with the hydraulic clamp."))
			else
				step_away(M, owner)
				to_chat(user, "You push [target] out of the way.")
				owner.visible_message("[owner] pushes [target] out of the way.")
*/
