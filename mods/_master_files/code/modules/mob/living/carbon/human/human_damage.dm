/*
	COMBAT_EXTENDED — обёртка вокруг попадания по человеку.

	Кор `apply_damage()` читает из результата `modify_damage_by_armor()` только урон, тип и
	флаги, поэтому всё, что проход по слоям узнал сверх этого, живёт на человеке до конца
	вызова: контекст попадания для органов, отложенный остаточный удар, осколки брони и тупая
	волна от щита.

	После `..()` обёртка чистит все четыре. Это закрывает все ранние выходы из
	`take_external_damage()` — нулевой `brute_mod`, отрыв конечности, нет органов, — после
	которых контекст иначе висел бы до следующего попадания.

	Внешние значения откладываются на время вызова, а не просто затираются: попадание может
	породить вложенный `apply_damage()` по тому же человеку, и тот не должен ни съесть чужой
	контекст, ни нанести чужой остаточный удар или осколок.
*/
/mob/living/carbon/human/apply_damage(damage = 0, damagetype = DAMAGE_BRUTE, def_zone, damage_flags = FLAGS_OFF, obj/used_weapon, armor_pen, silent = FALSE, obj/item/organ/external/given_organ)
	var/list/outer_context = ce_hit_context
	var/list/outer_residual = ce_pending_residual
	var/list/outer_shards = ce_pending_shards
	var/list/outer_shock = ce_pending_shield_shock
	ce_hit_context = null
	ce_pending_residual = null
	ce_pending_shards = null
	ce_pending_shield_shock = null

	. = ..()

	var/list/residual = ce_pending_residual
	var/list/shards = ce_pending_shards
	var/list/shock = ce_pending_shield_shock
	ce_hit_context = outer_context
	ce_pending_residual = outer_residual
	ce_pending_shards = outer_shards
	ce_pending_shield_shock = outer_shock

	// Остаточный удар всегда тупой, поэтому своего остаточного удара у него не бывает:
	// рекурсия ограничена по построению.
	if(residual)
		ce_apply_residual(residual[1], residual[2], residual[3])
	// Осколок бьёт мимо брони, не через `apply_damage()`, и новых осколков не родит.
	for(var/list/shard as anything in shards)
		ce_apply_shard(shard[1], shard[2])
	// Тупая волна от щита или парирования тоже бьёт мимо брони и ничего не порождает.
	if(shock)
		ce_apply_shield_shock(shock[1], shock[2], shock[3])
