/obj/structure/ship_munition/disperser_charge/fire/military
	name = "M1050-NPLM"
	desc = "A charge to power the military impulse gun. This charge is designed to release a localised fire on impact."
	chargedesc = "NPLM"

/obj/structure/ship_munition/disperser_charge/fire/military/fire(turf/target, strength, range, shield_active_EM, shield_active_KTC)
	// Напалм не сработает, если активен кинетический щит
	if(shield_active_KTC)
		return
	var/datum/reagent/napalm/napalm_liquid = new /datum/reagent/napalm
	napalm_liquid.volume = 10 * strength
	for(var/atom/A in view(range * 1.5, target))
		if(ismob(A))
			napalm_liquid.touch_mob(A, 10 * strength)
		if(isturf(A))
			var/turf/T = A
			napalm_liquid.touch_turf(T, TRUE)
			// Воспламеняем все турфы и накидываем им соответствующую температуру
			var/power = napalm_liquid.accelerant_quality * strength
			T.IgniteTurf(power, napalm_liquid.fire_colour)
			T.hotspot_expose((power*3) + 380,500)

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
