#define INVOKE_PSI_POWERS(holder, powers, target, return_on_invocation) \
	if(holder && holder.psi && holder.psi.can_use()) { \
		for(var/thing in powers) { \
			var/singleton/psionic_power/power = thing; \
			var/obj/item/result = power.invoke(holder, target); \
			if(result) { \
				power.handle_post_power(holder, target); \
				if(istype(result)) { \
					sound_to(holder, sound('sound/effects/psi/power_evoke.ogg')); \
					LAZYADD(holder.psi.manifested_items, result); \
					holder.put_in_hands(result); \
				} \
				return return_on_invocation; \
			} \
		} \
	}

/mob/living/UnarmedAttack(atom/A, proximity)
	. = ..()
	if(. && psi)
		INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_intent[a_intent]), A, FALSE)
		if(a_intent == I_HURT)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Energistics"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Psychokinesis"]), A, FALSE)
		if(a_intent == I_GRAB)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Psychokinesis"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Metakinesis"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Manifestation"]), A, FALSE)
		if(a_intent == I_DISARM)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Coercion"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Consciousness"]), A, FALSE)
		if(a_intent == I_HELP)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Redaction"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Energistics"]), A, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_melee_powers(SSpsi.faculties_by_name_new["Consciousness"]), A, FALSE)

/mob/living/RangedAttack(atom/A, params)
	if(psi)
		INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_intent[a_intent]), A, TRUE)
		if(a_intent == I_HURT)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Energistics"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Psychokinesis"]), A, TRUE)
		if(a_intent == I_GRAB)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Psychokinesis"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Metakinesis"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Manifestation"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Shaymanism"]), A, TRUE)
		if(a_intent == I_DISARM)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Coercion"]), A, TRUE)
		if(a_intent == I_HELP)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Energistics"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Redaction"]), A, TRUE)
			INVOKE_PSI_POWERS(src, psi.get_ranged_powers(SSpsi.faculties_by_name_new["Consciousness"]), A, TRUE)
	. = ..()

/mob/living/proc/check_psi_grab(obj/item/grab/grab)
	if(psi && ismob(grab.affecting))
		INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_intent[a_intent]), grab.affecting, FALSE)
		if(a_intent == I_HURT)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Energistics"]), grab.affecting, FALSE)
		if(a_intent == I_GRAB)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Psychokinesis"]), grab.affecting, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Metakinesis"]), grab.affecting, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Manifestation"]), grab.affecting, FALSE)
		if(a_intent == I_DISARM)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Coercion"]), grab.affecting, FALSE)
		if(a_intent == I_HELP)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Redaction"]), grab.affecting, FALSE)
			INVOKE_PSI_POWERS(src, psi.get_grab_powers(SSpsi.faculties_by_name_new["Consciousness"]), grab.affecting, FALSE)

/mob/living/attack_empty_hand(bp_hand)
	if(psi)
		INVOKE_PSI_POWERS(src, psi.get_manifestations(), src, FALSE)
	. = ..()

#undef INVOKE_PSI_POWERS
