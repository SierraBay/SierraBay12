/*
	COMBAT_EXTENDED — боль дубинки проходит броню (`mods/combat_extended/code/agony_armor.dm`).
*/

/**
 * Удар по намерению вреда проходит броню как удар силой `force`, и боль и оглушение — по доле урона,
 * прошедшей броню. Тычок урона не наносит и касается брони с нулевым пробитием: его останавливает
 * любая броня против удара. Остановленный бронёй удар не причиняет боли и не оглушает.
 *
 * Доля считается до `..()`: сам удар изнашивает броню. Боль и оглушение дубинка берёт из
 * `agonyforce` и `stunforce` внутри `..()`, поэтому на время вызова они подменяются.
 */
/obj/item/melee/baton/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	if(!ce_agony_armor_enabled)
		return ..()
	// Урон наносит только удар по намерению вреда — то же условие, что в `..()`.
	var/damage = (user && user.a_intent == I_HURT) ? force : 0
	var/pass_share = target.ce_get_armor_pass_share(hit_zone, damage, damtype, damage_flags(), armor_penetration)
	var/full_agony = agonyforce
	var/full_stun = stunforce
	var/mult = ce_get_agony_mult(pass_share)
	agonyforce *= mult
	stunforce *= mult

	. = ..()

	agonyforce = full_agony
	stunforce = full_stun
