/datum/robolimb
	var/list/armor
	var/siemens_coefficient		//чем больше, тем хуже
	var/speed_modifier = 0
	var/coolingefficiency = 0.5 // это база // меньше лучше
	var/heat_generation = 0.75  // тепловыделение конечности за тик // меньше — холоднее
	var/brand = ""              // производитель; штраф если Hephaestus/Shellguard смешаны с другими марками
	var/expensive = 0 ///// 0 - бюджет протезы, 1 - нормальные, 2 - дорогие
	var/addmax_damage
	var/addmin_broken_damage
	var/have_synth_skin = FALSE
	var/self_repair_rate = 0    // скорость пассивного самовосстановления (Zeng-Hu nanites)

	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		rad = ARMOR_RAD_MINOR
	)

/obj/item/organ/external
	var/coolingefficiency
	var/heat_generation = 0.75
	var/brand = ""
	var/expensive = 0
	var/have_synth_skin = FALSE
	var/synth_skin_health
	var/self_repair_rate = 0    // скорость пассивного самовосстановления (Zeng-Hu nanites)

/mob/living/carbon/human/get_armors_by_zone(obj/item/organ/external/def_zone, damage_type, damage_flags)
	if(!def_zone)
		def_zone = ran_zone()
	if(!istype(def_zone))
		def_zone = get_organ(check_zone(def_zone))
	if(!def_zone)
		return ..()

	. = list()
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/obj/item/clothing/gear in protective_gear)
		if(length(gear.accessories))
			for(var/obj/item/clothing/accessory/bling in gear.accessories)
				if(bling.body_parts_covered & def_zone.body_part)
					var/armor = get_extension(bling, /datum/extension/armor)
					if(armor)
						. += armor
		if(gear.body_parts_covered & def_zone.body_part)
			var/armor = get_extension(gear, /datum/extension/armor)
			if(armor)
				. += armor
	var/obj/item/organ/external/p_limb
	for(var/limb in BP_ALL_LIMBS)
		var/obj/item/organ/external/E = src.get_organ(limb)
		if(def_zone == E)
			p_limb = organs_by_name[limb]
			if(BP_IS_ROBOTIC(p_limb))
				var/datum/extension/armor/prosthetics_armor = get_extension(p_limb, /datum/extension/armor)
				if(prosthetics_armor)
					. += prosthetics_armor
	// Add inherent armor to the end of list so that protective equipment is checked first
	. += ..()

/obj/item/organ/external/robotize(company, skip_prosthetics = 0, keep_organs = 0)
	if(BP_IS_ROBOTIC(src))
		return

	..()

	dislocated = -1
	remove_splint()
	update_icon(1)
	unmutate()

	slowdown = 0
	if(company)
		var/datum/robolimb/R = all_robolimbs[company]
		if(!istype(R) || (species && (species.name in R.species_cannot_use)) || \
			(species && !(species.get_bodytype(owner) in R.allowed_bodytypes)) || \
			(length(R.applies_to_part) && !(organ_tag in R.applies_to_part)))
			R = basic_robolimb
		else
			model = company
			force_icon = R.icon
			name = "robotic [initial(name)]"
		armor = R.armor
		siemens_coefficient = R.siemens_coefficient
		slowdown = R.speed_modifier
		coolingefficiency = R.coolingefficiency
		heat_generation = R.heat_generation
		brand = R.brand
		expensive = R.expensive
		if(model)
			desc = "[R.desc] It looks like it was produced by [R.company]. Repair grade: [get_repair_grade_name()]."
		self_repair_rate = R.self_repair_rate
		max_damage = max_damage +  R.addmax_damage
		min_broken_damage = min_broken_damage +  R.addmin_broken_damage
		set_extension(src, /datum/extension/armor, armor)
		have_synth_skin = R.have_synth_skin
		if(have_synth_skin)
			synth_skin_health = max_damage

	for(var/obj/item/organ/external/T in children)
		T.robotize(company, 1)

	if(owner)

		if(!skip_prosthetics)
			owner.full_prosthetic = null // Will be rechecked next isSynthetic() call.

		if(!keep_organs)
			for(var/obj/item/organ/thing in internal_organs)
				if(istype(thing))
					if(thing.vital || BP_IS_ROBOTIC(thing))
						continue
					internal_organs -= thing
					owner.internal_organs_by_name[thing.organ_tag] = null
					owner.internal_organs_by_name -= thing.organ_tag
					owner.internal_organs.Remove(thing)
					qdel(thing)

		while(null in owner.internal_organs)
			owner.internal_organs -= null

	CLEAR_FLAGS(status, ORGAN_ARTERY_CUT)

	return 1

/obj/item/organ/external/proc/get_repair_grade_name()
	switch(expensive)
		if(2)
			return "specialist"
		if(1)
			return "workshop"
		else
			return "field"

/obj/item/organ/external/proc/get_repair_grade_hint(damage_type)
	var/maker = length(brand) ? brand : "This"
	switch(expensive)
		if(2)
			if(damage_type == DAMAGE_BURN)
				return "[maker] [name] is specialist grade. Use a prosthetic wiring layerer or a rating-2 capacitor."
			return "[maker] [name] is specialist grade. Use an integrity repair tool or a rating-2 manipulator."
		if(1)
			if(damage_type == DAMAGE_BURN)
				return "[maker] [name] is workshop grade. Use nanopaste, a prosthetic wiring layerer, or a rating-1 capacitor."
			return "[maker] [name] is workshop grade. Use nanopaste, an integrity repair tool, or a rating-1 manipulator."
		else
			if(damage_type == DAMAGE_BURN)
				return "[maker] [name] is field grade. Cable works; workshop tools also work."
			return "[maker] [name] is field grade. A welder works; workshop tools also work."

/obj/item/organ/external/proc/can_repair_brute_with(obj/item/tool)
	if(!tool)
		return FALSE
	if(expensive >= 2)
		if(istype(tool, /obj/item/integrity_repair_tool))
			return TRUE
		if(istype(tool, /obj/item/stock_parts/manipulator))
			var/obj/item/stock_parts/manipulator/manip = tool
			return manip.rating >= 2
		return FALSE
	if(expensive == 1)
		if(istype(tool, /obj/item/integrity_repair_tool) || istype(tool, /obj/item/stack/nanopaste))
			return TRUE
		if(istype(tool, /obj/item/stock_parts/manipulator))
			var/obj/item/stock_parts/manipulator/manip = tool
			return manip.rating >= 1
		return FALSE
	return TRUE

/obj/item/organ/external/proc/can_repair_burn_with(obj/item/tool)
	if(!tool)
		return FALSE
	if(expensive >= 2)
		if(istype(tool, /obj/item/prosthetic_wiring_layerer))
			return TRUE
		if(istype(tool, /obj/item/stock_parts/capacitor))
			var/obj/item/stock_parts/capacitor/cap = tool
			return cap.rating >= 2
		return FALSE
	if(expensive == 1)
		if(istype(tool, /obj/item/prosthetic_wiring_layerer) || istype(tool, /obj/item/stack/nanopaste))
			return TRUE
		if(istype(tool, /obj/item/stock_parts/capacitor))
			var/obj/item/stock_parts/capacitor/cap = tool
			return cap.rating >= 1
		return FALSE
	return TRUE

/obj/item/organ/external/examine(mob/user, distance)
	. = ..()
	if(BP_IS_ROBOTIC(src) && (distance <= 1 || isghost(user)))
		to_chat(user, SPAN_NOTICE("Repair grade: [get_repair_grade_name()]."))
		to_chat(user, SPAN_NOTICE(get_repair_grade_hint(DAMAGE_BRUTE)))
		to_chat(user, SPAN_NOTICE(get_repair_grade_hint(DAMAGE_BURN)))

/obj/item/organ/external/get_wounds_desc()
	. = ..()
	if(!BP_IS_ROBOTIC(src))
		return
	var/grade = "[get_repair_grade_name()] repair grade"
	if(!.)
		return grade
	return "[.] ([grade])"


/datum/robolimb/bishop
	company = "Bishop"
	brand = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	unavailable_at_fab = 1

	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,               // люкс, не боевой
		laser = ARMOR_LASER_MINOR,
		energy = 0,               // металл проводит ток
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
	)
	speed_modifier = - 0.3
	coolingefficiency = 0.3
	heat_generation = 0.3  // высококачественные, отлично отводят тепло
	siemens_coefficient = 0.9  // лучшая изоляция в классе
	expensive = 2

/datum/robolimb/bishop/rook
	company = "Bishop Rook"
	desc = "This limb has a polished metallic casing and a holographic face emitter."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_rook.dmi'
	has_eyes = FALSE
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = 0,               // люкс, не боевой
		laser = ARMOR_LASER_MINOR,
		energy = 0,               // металл проводит ток
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SMALL
	)
	speed_modifier = - 0.2
	coolingefficiency = 0.4
	heat_generation = 0.38  // немного хуже bishop но всё ещё хорошо
	siemens_coefficient = 0.9
	expensive = 2

/datum/robolimb/bishop/alt
	company = "Bishop Alt."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/bishop/alt/monitor
	company = "Bishop Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/hephaestus
	company = "Hephaestus Industries"
	brand = "Hephaestus"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	unavailable_at_fab = 1

	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR, // военный ЭМИ-хардинг
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 0.8
	heat_generation = 1.0   // военные протезы, греются заметно
	siemens_coefficient = 0.95  // военная изоляция

/datum/robolimb/hephaestus/alt
	company = "Hephaestus Alt."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/hephaestus/titan
	company = "Hephaestus Titan"
	desc = "This limb has a casing of an olive drab finish, providing a reinforced housing look."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_titan.dmi'
	has_eyes = FALSE
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_HANDGUNS,
		energy = ARMOR_ENERGY_MINOR, // тяжёлый военный ЭМИ-хардинг
		bomb = ARMOR_BOMB_RESISTANT,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	expensive = 1
	speed_modifier = 0.5
	coolingefficiency = 1
	heat_generation = 1.35 // тяжёлая броня, серьёзный нагрев
	siemens_coefficient = 0.92  // лучше базового Hephaestus

/datum/robolimb/hephaestus/alt/monitor
	company = "Hephaestus Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/zenghu
	company = "Zeng-Hu"
	brand = "Zeng-Hu"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	can_eat = 1
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_HUMAN,SPECIES_IPC)
	self_repair_rate = 0.3  // встроенные нанайты медленно восстанавливают повреждения
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,               // синтетическая кожа не экранирует электро
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 0.4
	heat_generation = 0.38  // дорогие медицинские, синтетическая кожа хорошо рассеивает тепло
	siemens_coefficient = 0.95  // синтетическая кожа частично изолирует (было 0.8 — лучше органики, некорректно)
	have_synth_skin = TRUE
	expensive = 2


/datum/robolimb/zenghu/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black and white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,               // металл проводит ток
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = - 0.3
	coolingefficiency = 0.4
	heat_generation = 0.55  // средний класс zeng-hu
	siemens_coefficient = 1.0  // без синтетической кожи, как органика
	expensive = 1

/datum/robolimb/xion
	company = "Xion"
	brand = "Xion"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = 0,
		energy = 0,
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	siemens_coefficient = 1.2  // дешёвая изоляция

/datum/robolimb/xion/econo
	company = "Xion Econ"
	desc = "This skeletal mechanical limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_econo.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = 0,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 0.7
	heat_generation = 1.05 // бюджетный скелетный, плохой теплоотвод
	siemens_coefficient = 1.6  // голый металлический каркас, минимальная изоляция
	addmax_damage = - 8
	addmin_broken_damage = - 15

/datum/robolimb/xion/alt
	company = "Xion Alt."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/xion/alt/monitor
	company = "Xion Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	brand = "NanoTrasen"
	desc = "This limb is made from a cheap polymer."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 0.2
	coolingefficiency = 0.6
	heat_generation = 0.85  // дешёвый полимер, чуть выше нормы
	siemens_coefficient = 1.2  // плохая изоляция (уже было)

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	brand = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	can_eat = 1
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,               // металл проводит ток
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	siemens_coefficient = 1.1  // средний класс

/datum/robolimb/economy
	company = "Ward-Takahashi Econ."
	brand = "Ward-Takahashi"
	desc = "A simple robotic limb with retro design. Seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_economy.dmi'
	armor = list(
		melee = 0,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	coolingefficiency = 1.2
	heat_generation = 1.1   // самый дешёвый, наихудший теплоотвод
	siemens_coefficient = 1.3  // дешёвый ретро
	speed_modifier = 0.1
	addmax_damage = - 5
	addmin_broken_damage = - 10

/datum/robolimb/wardtakahashi/alt
	company = "Ward-Takahashi Alt."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/wardtakahashi/alt/monitor
	company = "Ward-Takahashi Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	allowed_bodytypes = list(SPECIES_IPC)
	can_eat = null
	unavailable_at_fab = 1
	has_screen = TRUE

/datum/robolimb/morpheus
	company = "Morpheus"
	brand = "Morpheus"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = 0,               // промышленный, не электрозащищённый
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	siemens_coefficient = 1.05  // промышленный стандарт

/datum/robolimb/morpheus/alt
	company = "Morpheus Atlantis"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_atlantis.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/blitz
	company = "Morpheus Blitz"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_blitz.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/airborne
	company = "Morpheus Airborne"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_airborne.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/morpheus/alt/prime
	company = "Morpheus Prime"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_prime.dmi'
	applies_to_part = list(BP_HEAD)
	has_eyes = FALSE
	unavailable_at_fab = 1

/datum/robolimb/mantis
	company = "Morpheus Mantis"
	brand = "Morpheus"
	desc = "This limb has a casing of sleek black metal and repulsive insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_mantis.dmi'
	unavailable_at_fab = 1
	has_eyes = FALSE
	armor = list(
		melee = ARMOR_MELEE_SMALL,
		bullet = ARMOR_BALLISTIC_MINOR, // лёгкий, не тяжелее базового Morpheus
		laser = ARMOR_LASER_MINOR,
		energy = 0,               // лёгкий, нет особой изоляции
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = - 0.1
	coolingefficiency = 0.52
	heat_generation = 0.7   // лёгкие и эффективные, чуть лучше базы
	siemens_coefficient = 1.0  // промышленный уровень

/datum/robolimb/morpheus/monitor
	company = "Morpheus Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_monitor.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1
	has_eyes = FALSE
	allowed_bodytypes = list(SPECIES_IPC)
	has_screen = 2

/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This high quality limb is nearly indistinguishable from an organic one."
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	can_eat = 1
	skintone = 1
	unavailable_at_fab = 1
	expensive = 2
	have_synth_skin = TRUE
	species_cannot_use = list(SPECIES_IPC)
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = 0,
		laser = 0,
		energy = 0,               // синтетическая кожа не экранирует электро
		bomb = ARMOR_BOMB_MINOR,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	siemens_coefficient = 0.9  // лучшая изоляция (синтетическая кожа)

/datum/robolimb/shellguard
	company = "Shellguard"
	brand = "Shellguard"
	desc = "This limb has a sturdy and heavy build to it."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	unavailable_at_fab = 1
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_MINOR, // аварийные службы, не фронт-линия
		laser = ARMOR_LASER_SMALL,
		energy = 0,               // не специализирован на электрозащите
		bomb = ARMOR_BOMB_RESISTANT, // их специализация
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 0.8
	coolingefficiency = 0.8
	heat_generation = 1.3   // тяжёлые бронированные, серьёзно греются
	siemens_coefficient = 1.0  // промышленный стандарт
	addmax_damage = 10
	addmin_broken_damage = 5

/datum/robolimb/shellguard/alt
	company = "Shellguard Alt."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1

/datum/robolimb/shellguard/alt/monitor
	company = "Shellguard Monitor."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	applies_to_part = list(BP_HEAD)
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_IPC)
	has_screen = TRUE

/datum/robolimb/vox
	company = "Arkmade"
	icon = 'icons/mob/human_races/cyberlimbs/vox/primalis.dmi'
	unavailable_at_fab = 1
	allowed_bodytypes = list(SPECIES_VOX)
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
	speed_modifier = 1.2
	coolingefficiency = 0.4
	addmax_damage = 10
	addmin_broken_damage = 5

/datum/robolimb/vox/crap
	company = "Improvised"
	icon = 'icons/mob/human_races/cyberlimbs/vox/improvised.dmi'
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)

/datum/robolimb/resomi
	company = "Small prosthetic"
	desc = "This prosthetic is small and fit for nonhuman proportions."
	armor = list(
		melee = 2,
		bullet = 0,
		laser = 0,
		energy = 0,
		bomb = 0,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_RESISTANT
	)
