/*
	COMBAT_EXTENDED — выстрел при обезоруживании.

	В Bay попытка обезоружить человека с ружьём в руке бросает 60% (за вторую руку — 30%) минус 30%
	за уровень разницы навыка ближнего боя (оверрайд Sierra в `_master_files/.../species/species.dm`),
	и ружьё стреляет в случайную клетку в поле зрения. Намерение держащего и его умение стрелять не
	важны, а сообщение о выстреле пишется, даже если ружьё на предохранителе и не стреляет.

	Здесь до всего остального обезоруживания — два броска:
	- реакция — навык стрельбы держащего против навыка ближнего боя обезоруживающего: успел ли
	  держащий нажать на спуск. Не успел — обезоруживание идёт как обычно;
	- борьба за ружьё — навык ближнего боя держащего против того же навыка обезоруживающего.
	  Держащий её выиграл — стреляет в обезоруживающего в упор. Проиграл — тот отводит ствол, и
	  ружьё стреляет в случайную клетку в поле зрения, кроме клеток их обоих.
	Шанс каждого броска — `ce_disarm_gunfire_chance` плюс `ce_disarm_gunfire_chance_per_skill` за
	уровень разницы навыков в пользу держащего. Нажатый спуск заканчивает попытку обезоружить.

	Не стреляет ружьё на предохранителе и ружьё того, кто на намерении помощи. Бросок Bay на ружьё
	выключен (`on_disarm_attempt()` в `_master_files/.../projectiles/gun.dm`): второй раз оно не
	стреляет.
*/

/// Шанс броска, 0–100, по разнице навыков `advantage` в пользу держащего ружьё.
/proc/ce_get_disarm_gunfire_chance(advantage)
	return clamp(ce_disarm_gunfire_chance + advantage * ce_disarm_gunfire_chance_per_skill, 0, 100)


/// Шансы двух бросков: `list(реакция, борьба за ружьё)`.
/proc/ce_get_disarm_gunfire_chances(mob/living/holder, mob/living/disarmer)
	RETURN_TYPE(/list)
	var/disarmer_combat = disarmer.get_skill_value(SKILL_COMBAT)
	return list(
		ce_get_disarm_gunfire_chance(holder.get_skill_value(SKILL_WEAPONS) - disarmer_combat),
		ce_get_disarm_gunfire_chance(holder.get_skill_value(SKILL_COMBAT) - disarmer_combat)
	)


/// Ружьё, которое может выстрелить, пока человека обезоруживают: в активной руке, иначе во второй.
/mob/living/carbon/human/proc/ce_get_disarm_gun()
	for(var/obj/item/gun/gun in list(get_active_hand(), get_inactive_hand()))
		return gun
	return null


/**
 * Два броска выстрела, пока `disarmer` обезоруживает `holder`. Возвращает `CE_DISARM_GUNFIRE_*`:
 * спуск не нажат (0), ружьё отвели в сторону или держащий выстрелил в обезоруживающего.
 */
/obj/item/gun/proc/ce_disarm_gunfire(mob/living/carbon/human/holder, mob/living/carbon/human/disarmer)
	if(holder.a_intent == I_HELP || safety())
		return CE_DISARM_GUNFIRE_NONE
	var/list/chances = ce_get_disarm_gunfire_chances(holder, disarmer)
	if(!prob(chances[1]))
		return CE_DISARM_GUNFIRE_NONE
	if(prob(chances[2]))
		holder.visible_message(SPAN_DANGER("\The [holder] pulls the trigger of \the [src] point-blank at \the [disarmer]!"))
		Fire(disarmer, holder, null, TRUE)
		return CE_DISARM_GUNFIRE_DISARMER
	holder.visible_message(SPAN_DANGER("\The [disarmer] knocks \the [src] aside as \the [holder] pulls the trigger!"))
	var/turf/stray = ce_get_stray_turf(holder, disarmer)
	if(stray)
		Fire(stray, holder)
	return CE_DISARM_GUNFIRE_STRAY


/// Случайная клетка в поле зрения держащего ружьё, кроме его клетки и клетки обезоруживающего.
/proc/ce_get_stray_turf(mob/living/holder, mob/living/disarmer)
	var/list/turfs = list()
	for(var/turf/T in view(holder))
		turfs += T
	turfs -= get_turf(holder)
	turfs -= get_turf(disarmer)
	return length(turfs) ? pick(turfs) : null
