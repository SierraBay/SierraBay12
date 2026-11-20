GLOBAL_LIST_AS(psi_level2cost, list(
	"Нет"       = 0,
	"Латент"      = 2,
	"Омега"       = 6,
	"Ламед"       = 16
))

GLOBAL_LIST_AS(psi_faculty2color, list(
	"Kinesis"         = COLOR_YELLOW,
	"Patia"           = COLOR_SURGERY_BLUE,
	"Praxia"          = MANIFEST_COLOR_SERVICE
))

GLOBAL_LIST_AS(psi_threat_level2free_points, list(6, 8, 12, 16))

// Сколько способностей можно выбрать внутри школы, в зависимости от её уровня: Blunt, Latent, Omega, Lamed
GLOBAL_LIST_AS(psi_level2power_slots, list(0, 0, 5, 4))

/datum/preferences
	var/list/psi_abilities      // Школа (имя) -> уровень (индекс в psi_level2cost)
	var/list/psi_powers         // Список id выбранных способностей (см. /singleton/psionic_power/proc/get_id)
	var/psi_powers_set = FALSE  // Выбор способностей уже был сделан (или проставлен автоматически для старых персонажей)

/datum/preferences/proc/get_psi_faculty_rank(faculty_name)
	var/level = 1
	if(islist(psi_abilities))
		level = psi_abilities[faculty_name] || 1
	return level - 1

/datum/preferences/proc/get_psi_power_slots(faculty_name)
	var/level = get_psi_faculty_rank(faculty_name) + 1
	return GLOB.psi_level2power_slots[clamp(level, 1, length(GLOB.psi_level2power_slots))]

/datum/preferences/proc/get_available_psi_powers(faculty_name)
	. = list()
	var/index = GLOB.psi_faculty_names.Find(faculty_name)
	if(!index)
		return
	var/rank = get_psi_faculty_rank(faculty_name)
	for(var/singleton/psionic_power/power in get_selectable_psi_powers(GLOB.psi_faculty_ids[index]))
		if(power.min_rank <= rank)
			. += power

/datum/preferences/proc/get_chosen_psi_powers(faculty_name)
	. = list()
	var/index = GLOB.psi_faculty_names.Find(faculty_name)
	if(!index || !islist(psi_powers))
		return
	for(var/singleton/psionic_power/power in get_selectable_psi_powers(GLOB.psi_faculty_ids[index]))
		if(power.get_id() in psi_powers)
			. += power

/datum/preferences/proc/calculate_free_points()
	if(!psi_threat_level)
		return 0
	. = GLOB.psi_threat_level2free_points[psi_threat_level]

	if(!islist(psi_abilities))
		return
	for(var/faculty in psi_abilities)
		var/level = psi_abilities[faculty]
		if(level >= 1 && level <= length(GLOB.psi_level2cost))
			var/level_name = GLOB.psi_level2cost[level]
			. -= GLOB.psi_level2cost[level_name]

/datum/preferences/proc/sanitize_psi_data()
	psi_threat_level = isnum(psi_threat_level) ? clamp(psi_threat_level, 0, 4) : 0

	var/list/fixed = list()
	for(var/faculty_name in GLOB.psi_faculty_names)
		fixed[faculty_name] = 1

	if(islist(psi_abilities))
		for(var/key in psi_abilities)
			var/level = psi_abilities[key]
			if(!isnum(level))
				continue
			var/faculty_name = key
			if(!(faculty_name in fixed))
				faculty_name = GLOB.psi_legacy_faculty_names[faculty_name]
			if(!faculty_name)
				continue
			fixed[faculty_name] = max(fixed[faculty_name], clamp(round(level), 1, length(GLOB.psi_level2cost)))
	psi_abilities = fixed

	if(psi_threat_level)
		var/guard = 0
		while(calculate_free_points() < 0 && guard++ < 50)
			for(var/faculty_name in psi_abilities)
				if(calculate_free_points() >= 0)
					break
				if(psi_abilities[faculty_name] > 1)
					--psi_abilities[faculty_name]
	else
		for(var/faculty_name in psi_abilities)
			psi_abilities[faculty_name] = 1

	sanitize_psi_powers()

/datum/preferences/proc/sanitize_psi_powers()
	var/list/old = islist(psi_powers) ? psi_powers : list()
	var/list/result = list()

	for(var/faculty_name in GLOB.psi_faculty_names)
		var/slots = get_psi_power_slots(faculty_name)
		var/list/available_ids = list()
		for(var/singleton/psionic_power/power in get_available_psi_powers(faculty_name))
			available_ids += power.get_id()

		var/list/chosen = list()
		for(var/id in old)
			if(length(chosen) >= slots)
				break
			if((id in available_ids) && !(id in chosen))
				chosen += id

		if(!psi_powers_set)
			for(var/id in available_ids)
				if(length(chosen) >= slots)
					break
				if(!(id in chosen))
					chosen += id

		result += chosen

	psi_powers = result
	psi_powers_set = TRUE

/datum/preferences/proc/sanitize_psi_abilities()
	sanitize_psi_data()

/datum/category_item/player_setup_item/psionics/abilities
	name = "Abilities"
	sort_order = 3

/datum/category_item/player_setup_item/psionics/abilities/load_character(datum/pref_record_reader/R)
	pref.psi_abilities = R.read("psi_abilities")
	pref.psi_powers = R.read("psi_powers")
	pref.psi_powers_set = R.read("psi_powers_set")

/datum/category_item/player_setup_item/psionics/abilities/save_character(datum/pref_record_writer/W)
	W.write("psi_abilities", pref.psi_abilities)
	W.write("psi_powers", pref.psi_powers)
	W.write("psi_powers_set", pref.psi_powers_set)

/datum/category_item/player_setup_item/psionics/abilities/sanitize_character()
	pref.sanitize_psi_data()
	return ..()

/datum/category_item/player_setup_item/psionics/abilities/proc/can_select_level(faculty, level)
	if(level <= 1)
		return TRUE // safe measure

	return (pref.calculate_free_points() + GLOB.psi_level2cost[GLOB.psi_level2cost[pref.psi_abilities[faculty]]]) >= GLOB.psi_level2cost[GLOB.psi_level2cost[level]]

/datum/category_item/player_setup_item/psionics/abilities/content(mob/user)
	. = list()
	if(!whitelist_lookup(SPECIES_PSI, user.ckey))
		. += "<b> </b><br>"
	else

		if(!pref.psi_threat_level || !whitelist_lookup(SPECIES_PSI, user.ckey))
			return ..()

		if(!pref.psi_abilities)
			sanitize_character()

		. += "<style>"
		. += ".Current{background: #2f943c}"
		. += ".Unavailable{background: #404040}"
		. += ".Selectable, a.Selectable{float:none; border:none; margin:none !important; padding:none !important}"
		. += ".center { margin: auto; }"
		. += ".candystripe { background-color: rgba(148, 148, 148, 0.25);}"
		. += ".candystripe:nth-child(odd) {background-color: rgba(0, 0, 0, 0.16);}"
		. += ".power { display: inline-block; margin: 2px; padding: 2px 6px; }"

		. += "</style>"

		. += "<tt><center>"

		. += FONT_LARGE("<b>Очки: [pref.calculate_free_points()]</b>")

		. += "<table style='width: 100%' style='font-size: 15px; text-align: center' class='table'>"

		if(pref.species == SPECIES_TAJARA || (pref.species in HUMAN_SPECIES))
			. += available_faculties()

		. += "</table>"

		. += "</center></tt>"

	. = jointext(., null)

/datum/category_item/player_setup_item/psionics/abilities/proc/available_faculties()
	. = list()
	var/max_rank = length(GLOB.psi_level2cost) - 1
	for(var/faculty in GLOB.psi_faculty_names)
		. += "<tr class='candystripe'>"
		. += "<th><div class='average' style='color: [GLOB.psi_faculty2color[faculty]]'>[faculty]:</div></th>"
		for(var/level_index in 1 to LAZYLEN(GLOB.psi_level2cost))
			var/level_name = GLOB.psi_level2cost[level_index]
			if(pref.psi_abilities[faculty] == level_index)
				. += "<td class='Current'><div class='center'>[level_name]</div></td>"
			else if(can_select_level(faculty, level_index))
				. += "<td class style='background: #40628a;'><div class='center'><a class='Selectable' href='?src=\ref[src];select=[level_index];faculty=[faculty]'>[level_name]</a></div></td>"
			else
				. += "<td class='Unavailable'><div class='center'>[level_name]</div></td>"
		. += "</tr>"

		var/slots = pref.get_psi_power_slots(faculty)
		var/list/chosen = pref.get_chosen_psi_powers(faculty)
		. += "<tr class='candystripe'><td colspan='[LAZYLEN(GLOB.psi_level2cost) + 1]' style='text-align: left'>"
		. += "<small>Abilities: [length(chosen)]/[slots]</small><br>"

		var/index = GLOB.psi_faculty_names.Find(faculty)
		for(var/singleton/psionic_power/power in get_selectable_psi_powers(GLOB.psi_faculty_ids[index]))
			if(power.min_rank > max_rank)
				continue
			var/power_id = power.get_id()
			var/description = html_encode(power.use_description)
			var/required = GLOB.psi_level2cost[power.min_rank + 1]
			if(power in chosen)
				. += "<a class='power Current' title='[description]' href='?src=\ref[src];toggle_power=[power_id];faculty=[faculty]'>[power.name]</a>"
			else if(power.min_rank <= pref.get_psi_faculty_rank(faculty) && length(chosen) < slots)
				. += "<a class='power Selectable' style='background: #40628a;' title='[description]' href='?src=\ref[src];toggle_power=[power_id];faculty=[faculty]'>[power.name]</a>"
			else
				. += "<span class='power Unavailable' title='Requires level [required]. [description]'>[power.name]</span>"
		. += "</td></tr>"
	return jointext(., null)

/datum/category_item/player_setup_item/psionics/abilities/OnTopic(href, list/href_list, mob/user)
	if(..())
		return TOPIC_HANDLED

	var/faculty = href_list["faculty"]
	if(faculty && !(faculty in GLOB.psi_faculty_names))
		return TOPIC_HANDLED

	if(href_list["select"])
		var/level = text2num(href_list["select"])
		if(!faculty || level < 1 || level > length(GLOB.psi_level2cost))
			return TOPIC_HANDLED

		if(!can_select_level(faculty, level))
			return TOPIC_HANDLED

		pref.psi_abilities[faculty] = level
		pref.sanitize_psi_powers() // слотов могло стать меньше

	else if(href_list["toggle_power"])
		if(!faculty)
			return TOPIC_HANDLED

		var/power_id = href_list["toggle_power"]
		var/singleton/psionic_power/target_power
		for(var/singleton/psionic_power/power in pref.get_available_psi_powers(faculty))
			if(power.get_id() == power_id)
				target_power = power
				break
		if(!target_power)
			return TOPIC_HANDLED

		if(power_id in pref.psi_powers)
			pref.psi_powers -= power_id
		else if(length(pref.get_chosen_psi_powers(faculty)) < pref.get_psi_power_slots(faculty))
			pref.psi_powers += power_id

	return TOPIC_REFRESH
