/obj/structure/ship_munition/disperser_charge/fire/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	if(shield_active_KTC)
		return
	for(var/turf/T in range(range, target))
		var/obj/fake_fire/bluespace/disperserf = new(T)
		disperserf.lifetime = strength * 20

/obj/structure/ship_munition/disperser_charge/fire/military
	name = "M1050-NPLM"
	desc = "A charge to power the military impulse gun. This charge is designed to release a localised fire on impact."
	chargedesc = "NPLM"

/obj/structure/ship_munition/disperser_charge/fire/military/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	// Напалм не сработает, если активен кинетический щит
	if(shield_active_KTC)
		return
	var/datum/reagent/napalm/napalm_liquid = new /datum/reagent/napalm
	napalm_liquid.volume = 100 * strength // примерно в 5 раз больше при максимальной силе, чем в баке огнемета
	for(var/atom/A in RANGE_TURFS(target, range))
		if(ismob(A))
			napalm_liquid.touch_mob(A, 10 * strength)
		if(isturf(A) && !A.density && !istype(A, /turf/space))
			var/turf/T = A
			napalm_liquid.touch_turf(T, TRUE)
			// Воспламеняем все турфы
			T.hotspot_expose(1000,500,1) // хотспот как у игнайтера

/obj/structure/ship_munition/disperser_charge/mining/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	if(shield_active_KTC)
		return
	var/list/victims = range(range * 3, target)
	for(var/turf/simulated/mineral/M in victims)
		if(prob(strength * 100 / 6)) //6 instead of 5 so there are always leftovers
			M.GetDrilled(TRUE) //no artifacts survive this
	for(var/mob/living/L in victims)
		to_chat(L, SPAN_DANGER("You feel an incredible force ripping and tearing at you."))
		L.ex_act(EX_ACT_LIGHT) //no artif- I mean idiot/unfortunate bystanders survive this... much

/obj/structure/ship_munition/disperser_charge/emp/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	// ОФД не сработает на ЭМ щит
	if(shield_active_EM)
		return
	empulse(target, strength * range / 3, strength * range)

/obj/structure/ship_munition/disperser_charge/emp/military
	name = "M850-EM"
	desc = "A charge to power the military impulse gun. This charge is designed to release a blast of electromagnetic pulse on impact."
	chargedesc = "EMS"

/obj/structure/ship_munition/disperser_charge/emp/military/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	// Добавляем модификатор, если стреляем цели с ЭМ щитом
	var/shield_mod = 1
	if(shield_active_EM)
		shield_mod = 0.5
	empulse(target, strength * range / 2 * shield_mod , strength * range * 1.5 * shield_mod)

/obj/structure/ship_munition/disperser_charge/explosive/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	if(shield_active_KTC)
		return
	var/explosion_range = max(1, round((strength * range) / 3))
	explosion(target, explosion_range)

/obj/structure/ship_munition/disperser_charge/explosive/military
	name = "M950-HE"
	desc = "A charge to power the military impulse gun. This charge is designed to explode on impact."
	chargedesc = "HES"

/obj/structure/ship_munition/disperser_charge/explosive/military/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	var/shield_mod = 1
	// Снижаем эффективность взрыва, если есть кинетический щит
	if(shield_active_KTC)
		shield_mod = 0.75
	explosion(target,max(1,strength * range / 8 * shield_mod),strength * range / 6 * shield_mod,strength * range / 4 * shield_mod)
