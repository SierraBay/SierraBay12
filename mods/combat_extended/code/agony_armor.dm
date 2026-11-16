/*
	COMBAT_EXTENDED. Stopped projectiles and baton effects against armor.

	Projectiles retain upstream on_hit(): status effects use the damage block percentage,
	and agony receives its own armor query at the original agony amount. bullet_act() only
	gates effects when CE records a stopped hit or a blocked damage-free contact, then
	restores the projectile's effects. Penetrating projectiles are not pre-scaled.

	Baton effects use ce_get_agony_mult() in the apply_hit_effect() override.
*/

/// Multiplier for baton pain and stun from its armor pass share.
/proc/ce_get_agony_mult(pass_share)
	if(pass_share <= 0)
		return 0
	return min(pass_share, 1) ** ce_agony_pass_exponent


/**
 * Keep on_hit() responsible for damage-based status blocking and its separate
 * agony armor query. CE only suppresses effects for a stopped projectile or contact.
 */
/obj/item/projectile/proc/ce_block_stopped_effects(mob/living/target, def_zone)
	if(!ce_agony_armor_enabled)
		return
	var/pass_share = ce_armor_pass_share
	if(isnull(pass_share))
		if(damage > 0 && !nodamage)
			return
		pass_share = target.ce_get_armor_pass_share(def_zone, 0, damage_type, damage_flags())
	if(pass_share <= 0)
		ce_set_armor_effects(list(0, 0, 0, 0, 0, 0, 0))


/// Эффекты снаряда, которые гасит броня: `list(agony, stun, weaken, paralyze, stutter, eyeblur, drowsy)`.
/obj/item/projectile/proc/ce_get_armor_effects()
	return list(agony, stun, weaken, paralyze, stutter, eyeblur, drowsy)


/// Возвращает снаряду эффекты в виде списка из `ce_get_armor_effects()`.
/obj/item/projectile/proc/ce_set_armor_effects(list/effects)
	agony = effects[1]
	stun = effects[2]
	weaken = effects[3]
	paralyze = effects[4]
	stutter = effects[5]
	eyeblur = effects[6]
	drowsy = effects[7]
