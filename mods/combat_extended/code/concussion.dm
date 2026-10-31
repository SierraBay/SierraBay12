/*
	COMBAT_EXTENDED — контузия от взрыва вместо отключки.

	В Bay `human/ex_act()` на лёгком и тяжёлом взрыве бросает `prob(50)` и `prob(70)` на
	`Paralyse(10)`: около 20 секунд без сознания с чёрным экраном, мимо любой брони. Оверрайд
	`ex_act()` в `_master_files` этот бросок откатывает и контузит: носитель остаётся в сознании и
	видит, что происходит, но его шатает — `confused` уводит шаги в сторону, а о стену он падает, —
	в глазах плывёт, голова кружится, речь сбивается.

	Сила контузии — ступень взрыва (лёгкий 1, тяжёлый 2, разрушительный 3), умноженная на долю
	взрыва, которую пропускает броня по ключу `bomb` на зонах `ce_concussion_zones`. Доля считается
	тем же `get_blocked_ratio()` и тем же уроном, что у самого `ex_act()`. Лёжа контузия слабее.
	Тяжёлый взрыв ещё и коротко сбивает с ног — только того, кто стоит и не носит никакой брони
	`bomb` на этих зонах.

	Слух не трогается: глухоту и урон ушей ставит сам `ex_act()`, и защита ушей от них уже
	спасает. Урон взрыва тоже остаётся: болевой шок от него по-прежнему отключает, но это рана,
	а не бросок.
*/

// Урон `b_loss` кор `human/ex_act()` по ступеням взрыва: по нему броня `bomb` считает долю блока.
#define CE_BLAST_DAMAGE_LIGHT 30
#define CE_BLAST_DAMAGE_HEAVY 60
#define CE_BLAST_DAMAGE_DEVASTATING 400


/// Сила контузии от взрыва ступени `severity` (`EX_ACT_*`): 0 — не контузит, 1 — лёгкий взрыв без защиты.
/mob/living/carbon/human/proc/ce_get_concussion_strength(severity)
	var/steps
	var/blast_damage
	switch(severity)
		if(EX_ACT_DEVASTATING)
			steps = 3
			blast_damage = CE_BLAST_DAMAGE_DEVASTATING
		if(EX_ACT_HEAVY)
			steps = 2
			blast_damage = CE_BLAST_DAMAGE_HEAVY
		if(EX_ACT_LIGHT)
			steps = 1
			blast_damage = CE_BLAST_DAMAGE_LIGHT
	if(!steps || !length(ce_concussion_zones))
		return 0

	var/pass_share = 0
	for(var/zone in ce_concussion_zones)
		pass_share += 1 - get_blocked_ratio(zone, DAMAGE_BRUTE, DAMAGE_FLAG_EXPLODE, 0, blast_damage)
	pass_share /= length(ce_concussion_zones)
	if(lying)
		pass_share *= ce_concussion_prone_mult
	return steps * pass_share


/**
 * Сбивает ли взрыв ступени `severity` с ног: только тяжёлый и сильнее и только того, кто ничем не
 * защищён, — стоит и не носит брони `bomb` ни на одной из зон `ce_concussion_zones`. Защита
 * считается по наличию, а не по доле: каска тяжёлый взрыв по формуле Bay не гасит, но с ног
 * носителя уже не сбивает.
 */
/mob/living/carbon/human/proc/ce_is_knocked_down_by_blast(severity)
	if(severity > EX_ACT_HEAVY || lying)
		return FALSE
	for(var/zone in ce_concussion_zones)
		if(ce_has_bomb_armor(zone))
			return FALSE
	return TRUE


/// Есть ли на зоне хоть один слой с бронёй `bomb`. Зональная броня читается по этой зоне.
/mob/living/carbon/human/proc/ce_has_bomb_armor(zone)
	var/outer_body_part = ce_set_hit_body_part(ce_get_hit_body_part(zone))
	. = FALSE
	for(var/datum/extension/armor/armor_datum as anything in get_armors_by_zone(zone, DAMAGE_BRUTE, DAMAGE_FLAG_EXPLODE))
		if(armor_datum.get_value("bomb") > 0)
			. = TRUE
			break
	ce_set_hit_body_part(outer_body_part)


/**
 * Контузит с силой `strength` из `ce_get_concussion_strength()`, с `knockdown` — ещё и сбивает с
 * ног (`ce_is_knocked_down_by_blast()`). Сознания не отнимает. Сила, от которой не набирается и
 * одного тика замешательства, не контузит вовсе — остальные эффекты от неё тоже округлились бы в
 * ноль.
 */
/mob/living/carbon/human/proc/ce_concuss(strength, knockdown = FALSE)
	var/confusion = round(strength * ce_concussion_confusion)
	if(confusion <= 0 || stat == DEAD)
		return
	mod_confused(confusion)
	eye_blurry = max(eye_blurry, round(strength * ce_concussion_eye_blur))
	make_dizzy(round(strength * ce_concussion_dizziness))
	if(status_flags & CANSTUN)
		stuttering = max(stuttering, round(strength * ce_concussion_stutter))
	if(knockdown)
		Weaken(ce_concussion_knockdown)
		to_chat(src, SPAN_DANGER("The blast knocks you off your feet and rattles your skull!"))
	else if(strength >= 1)
		to_chat(src, SPAN_DANGER("The blast rattles your skull and the world reels around you!"))
	else
		to_chat(src, SPAN_WARNING("The blast leaves you dazed."))


#undef CE_BLAST_DAMAGE_LIGHT
#undef CE_BLAST_DAMAGE_HEAVY
#undef CE_BLAST_DAMAGE_DEVASTATING
