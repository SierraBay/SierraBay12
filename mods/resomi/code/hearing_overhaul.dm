
/obj/item/gun
	var/sound_power = -1

/obj/item/gun/Initialize()
	. = ..()
	if(sound_power == -1)
		calculate_sound_power()

// Расчет мощности звука выстрела на основе калибра
/obj/item/gun/proc/calculate_sound_power()
	if(silenced || fire_sound == null)
		sound_power = 0
		return

	if(istype(src, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/P = src
		switch(P.caliber)
			if(CALIBER_PISTOL_SMALL, CALIBER_PISTOL_FLECHETTE)
				sound_power = 15
			if(CALIBER_PISTOL, CALIBER_PISTOL_ANTIQUE)
				sound_power = 25
			if(CALIBER_RIFLE)
				sound_power = 40
			if(CALIBER_PISTOL_MAGNUM, CALIBER_RIFLE_MILITARY)
				sound_power = 60
			if(CALIBER_SHOTGUN, CALIBER_GYROJET)
				sound_power = 80
			if(CALIBER_ANTIMATERIAL)
				sound_power = 130
			else
				sound_power = 30
	else
		sound_power = 10

/obj/item/gun/play_fire_sound(mob/user, obj/item/projectile/projectile)
	..()
	if(sound_power > 0)
		apply_resomi_hearing_damage()

// Нанесение урона по ушам при выстреле неподалеку
/obj/item/gun/proc/apply_resomi_hearing_damage()
	var/turf/T = get_turf(src)
	if(!T) return

	var/affect_range = round(sound_power / 6)
	if(affect_range < 1) return

	for(var/mob/living/carbon/human/H in range(affect_range, T))
		if(H.get_species() != SPECIES_RESOMI || H.get_sound_volume_multiplier() < 0.2)
			continue

		var/dist = get_dist(H, T)
		var/falloff = 1 - (dist / affect_range)
		if(falloff <= 0) continue

		var/applied_damage = sound_power * falloff
		H.adjustEarDamage(applied_damage * 0.4, applied_damage * 1.8)

		if(applied_damage > 12 && prob(50))
			to_chat(H, SPAN_DANGER("Грохот выстрела поблизости больно бьет по вашим чувствительным ушам!"))

// Увеличенный урон по ушам при взрывах
/mob/living/carbon/human/ex_act(severity)
	if(get_species() == SPECIES_RESOMI)
		var/old_ear_damage = ear_damage
		var/old_ear_deaf = ear_deaf
		..()
		var/added_damage = ear_damage - old_ear_damage
		var/added_deaf = ear_deaf - old_ear_deaf

		if(added_damage > 0 || added_deaf > 0)
			adjustEarDamage(added_damage * 2, added_deaf * 2)
			if(added_damage > 5)
				to_chat(src, SPAN_DANGER("Ударная волна взрыва буквально разрывает ваш тонкий слух!"))
	else
		..()

// Увеличенный урон по ушам от светошумовых гранат
/obj/item/grenade/flashbang/bang(turf/T, mob/living/carbon/M)
	var/old_ear_damage = M.ear_damage
	var/old_ear_deaf = M.ear_deaf
	..()
	if(M.get_species() == SPECIES_RESOMI)
		var/added_damage = M.ear_damage - old_ear_damage
		var/added_deaf = M.ear_deaf - old_ear_deaf
		if(added_damage > 0 || added_deaf > 0)
			M.adjustEarDamage(added_damage * 2, added_deaf * 2)
			to_chat(M, SPAN_DANGER("Оглушительный взрыв светошумовой гранаты перегружает ваши сверхчувствительные уши!"))

// Урон по ушам от звука взрыва на расстоянии
/mob/living/carbon/human/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global, extrarange)
	..()
	if(get_species() == SPECIES_RESOMI)
		var/is_explosion = (soundin == "explosion" || (soundin in GLOB.explosion_sound) || soundin == 'sound/effects/explosionfar.ogg')

		if(is_explosion && vol >= 30 && get_sound_volume_multiplier() >= 0.2)
			var/impact = (vol / 100) * 20
			adjustEarDamage(impact * 0.5, impact * 2)
			if(prob(30))
				to_chat(src, SPAN_DANGER("Отдаленный грохот взрыва болезненно отдается в ваших ушах!"))
