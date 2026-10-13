/obj/aura/psi
	name = "Psi Armour"
	var/mob/living/carbon/human/owner

/obj/aura/psi/New(mob/living/target)
	..()
	owner = target

/obj/aura/psi/aura_check_bullet(obj/item/projectile/proj, def_zone)
	if(owner.disrupts_psionics() || proj.disrupts_psionics())
		return FLAGS_OFF
	if(owner.psi.check_armour("energy"))
		if(istype(proj, /obj/item/projectile/beam)) // Из-за того что у тазеров нет флага ЛАЗЕР, зато есть у остальных лазеров, я вынужден проверять тип, а не флаг
			var/psi_spend_amount = proj.damage * (1 - (owner.psi.check_armour("energy") * 0.1))
			var/energy_rank = owner.psi.get_rank(PSI_ENERGISTICS) - 1
			if(prob(energy_rank * 25) && owner.psi.stamina >= psi_spend_amount)
				owner.psi.spend_power_armor(psi_spend_amount)
				visible_message(SPAN_WARNING("\The [owner] отражает [proj.name]!"))
				var/obj/item/projectile/beam/rebound = new proj.type(owner)
				rebound.starting = get_turf(owner)
				rebound.shot_from = user
				var/rank_accuracy = 8 - energy_rank
				var/targetturf = locate(proj.starting.x + rand(-rank_accuracy, rank_accuracy), proj.starting.y + rand(-rank_accuracy, rank_accuracy), owner.z)
				rebound.launch(targetturf, user.zone_sel.selecting)
				// proj.redirect(proj.starting.x + rand(-2,2), proj.starting.x + rand(-2,2), get_turf(owner), owner) = Параша не работает, оставляю подсказку себе на потом
				return AURA_FALSE|AURA_CANCEL
			var/meta_rank = owner.psi.get_rank(PSI_METAKINESIS) - 1
			if(prob(meta_rank * 25) && owner.psi.stamina >= psi_spend_amount)
				owner.psi.spend_power_armor(psi_spend_amount)
				visible_message(SPAN_DANGER("\The [owner] поглощает [proj.name]!"))
				new /obj/temporary(get_turf(src), 5, 'icons/effects/effects.dmi', "fire_goon")
				playsound(owner,'mods/psionics/sounds/absorbheat.ogg',35,1)
				owner.psi.spend_power(-(proj.damage))
				return AURA_FALSE|AURA_CANCEL
			else
				to_chat(owner, SPAN_NOTICE("Ты блокируешь часть энергии."))
				proj.damage *= (1.1 - (owner.psi.check_armour("energy") * 0.1))
				return FLAGS_OFF
	if(owner.psi.check_armour("bullet"))
		if (HAS_FLAGS(proj.damage_flags(), DAMAGE_FLAG_BULLET))
			var/psi_spend_amount = proj.damage * (1 - (owner.psi.check_armour("bullet") * 0.1))
			var/kinesis_rank = owner.psi.get_rank(PSI_PSYCHOKINESIS) - 1
			if(prob(kinesis_rank * 25) && owner.psi.stamina >= psi_spend_amount)
				owner.psi.spend_power_armor(psi_spend_amount)
				visible_message(SPAN_DANGER("\The [owner] отклоняет [proj.name]!"))
				var/obj/item/projectile/rebound = new proj.type(owner)
				rebound.starting = get_turf(owner)
				rebound.shot_from = user
				rebound.muzzle_type = null
				var/rank_accuracy = 8 - kinesis_rank
				var/targetturf = locate(proj.starting.x + rand(-rank_accuracy, rank_accuracy), proj.starting.y + rand(-rank_accuracy, rank_accuracy), owner.z)
				rebound.launch(targetturf, user.zone_sel.selecting)
				return AURA_FALSE|AURA_CANCEL
			var/manifestation_rank = owner.psi.get_rank(PSI_MANIFESTATION) - 1
			if(prob(manifestation_rank * 25) && owner.psi.stamina >= psi_spend_amount)
				owner.psi.spend_power_armor(psi_spend_amount)
				visible_message(SPAN_DANGER("\The [owner] блокирует [proj.name]!"))
				new /obj/temporary(get_turf(src), 5, 'icons/effects/effects.dmi', "shield-old")
				playsound(owner,'sound/effects/projectile_impact/bullet_metal3.ogg',35,1)
				return AURA_FALSE|AURA_CANCEL
			else
				to_chat(owner, SPAN_NOTICE("Ты смягчаешь силу летящей пули."))
				proj.damage *= (1.1 - (owner.psi.check_armour("bullet") * 0.1))
				return FLAGS_OFF
	return FLAGS_OFF

/obj/aura/psi/aura_check_unarmed(mob/living/carbon/human/H)
	if(owner.disrupts_psionics() || H.disrupts_psionics())
		return FLAGS_OFF
	if(owner.psi.check_armour("melee"))
		var/con_rank = owner.psi.get_rank(PSI_CONSCIOUSNESS) - 1
		if(prob(25 * con_rank) && owner.psi.stamina >= 20)
			owner.psi.spend_power_armor(5)
			owner.dodge_animation(attacker = H)
			to_chat(owner, SPAN_WARNING("Ты реагируешь на мысль [H] атаковать тебя!"))
			return AURA_FALSE|AURA_CANCEL
		var/manifestation_rank = owner.psi.get_rank(PSI_MANIFESTATION) - 1
		if(prob(25 * manifestation_rank) && owner.psi.stamina >= 20)
			owner.psi.spend_power_armor(10)
			visible_message(SPAN_DANGER("\The [owner] манифестирует преграду от [H]!"))
			new /obj/temporary(get_turf(src), 5, 'icons/effects/effects.dmi', "shield-old")
			playsound(owner,'sound/effects/footstep/hull5.ogg',35,1)
			return AURA_FALSE|AURA_CANCEL
		var/sheyman_rank = owner.psi.get_rank(PSI_SHAYMANISM) - 1
		if(prob(25 * sheyman_rank) && owner.psi.stamina >= 10)
			owner.psi.spend_power_armor(5)
			owner.dodge_animation(attacker = H)
			to_chat(owner, SPAN_WARNING("Духи ведут тебя от удара!"))
			return AURA_FALSE|AURA_CANCEL
	return FLAGS_OFF

/obj/aura/psi/aura_check_weapon(obj/item/weapon, mob/attacker, click_params)
	if(owner.disrupts_psionics() || attacker.disrupts_psionics())
		return FLAGS_OFF
	if(owner.psi.check_armour("melee"))
		var/coercion_rank = owner.psi.get_rank(PSI_COERCION) - 1
		if(prob(25 * coercion_rank) && owner.psi.stamina >= 20)
			if(attacker.get_active_hand().simulated && attacker.unEquip(attacker.get_active_hand()))
				owner.psi.spend_power_armor(20)
				playsound(attacker, 'sound/weapons/Egloves.ogg', 50, 1, -1)
				new /obj/temporary(get_turf(attacker),3, 'icons/effects/effects.dmi', "blue_electricity_constant")
				to_chat(attacker, SPAN_DANGER("Моя рука невольно разжимается!"))
				return AURA_FALSE|AURA_CANCEL
		var/kinesis_rank = owner.psi.get_rank(PSI_PSYCHOKINESIS) - 1
		if(prob(25 * kinesis_rank) && owner.psi.stamina >= 20)
			if(attacker.get_active_hand().simulated && attacker.unEquip(attacker.get_active_hand()))
				owner.psi.spend_power_armor(20)
				playsound(owner, 'sound/effects/psi/power_used.ogg', 50, 1, -1)
				weapon.throw_at(CircularRandomTurfAround(get_turf(weapon), frand(2, 6) * kinesis_rank), 5, 5 * kinesis_rank)
				to_chat(attacker, SPAN_DANGER("Оружие из моей руки вырывается!"))
				new /obj/temporary(get_turf(attacker),3, 'icons/effects/effects.dmi', "cyan_sparkles")
				return AURA_FALSE|AURA_CANCEL
		var/con_rank = owner.psi.get_rank(PSI_CONSCIOUSNESS) - 1
		if(prob(25 * con_rank) && owner.psi.stamina >= weapon.force)
			owner.psi.spend_power_armor(weapon.force * 0.5)
			owner.dodge_animation(attacker = attacker)
			to_chat(owner, SPAN_WARNING("Ты реагируешь на мысль [attacker] атаковать тебя!"))
			visible_message(SPAN_DANGER("[owner] уклоняется!"))
			return AURA_FALSE|AURA_CANCEL
		var/manifestation_rank = owner.psi.get_rank(PSI_MANIFESTATION) - 1
		if(prob(25 * manifestation_rank) && owner.psi.stamina >= weapon.force)
			owner.psi.spend_power_armor(weapon.force)
			visible_message(SPAN_DANGER("\The [owner] манифестирует преграду от [attacker]!"))
			new /obj/temporary(get_turf(src), 5, 'icons/effects/effects.dmi', "shield-old")
			playsound(owner,'sound/effects/footstep/hull5.ogg',35,1)
			return AURA_FALSE|AURA_CANCEL
		var/sheyman_rank = owner.psi.get_rank(PSI_SHAYMANISM) - 1
		if(prob(25 * sheyman_rank) && owner.psi.stamina >= weapon.force)
			owner.psi.spend_power_armor(weapon.force)
			owner.dodge_animation(attacker = attacker)
			to_chat(owner, SPAN_WARNING("Духи ведут тебя от удара!"))
			visible_message(SPAN_DANGER("[owner] уклоняется!"))
			return AURA_FALSE|AURA_CANCEL
		else
			if(prob(owner.psi.check_armour("melee")))
				to_chat(owner, SPAN_WARNING("Тебе удается ослабить силу удара"))
				weapon.force *= 1 - (owner.psi.check_armour("melee") * 0.1)
			return FLAGS_OFF
	return FLAGS_OFF
