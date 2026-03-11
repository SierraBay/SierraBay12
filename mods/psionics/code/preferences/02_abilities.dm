GLOBAL_LIST_AS(psi_level2cost, list(
	"Blunt"       = 0,
	"Latent"      = 2,
	"Apprentice"  = 6,
	"Operant"     = 16
))

GLOBAL_LIST_AS(psi_faculty2color, list(
	"Coercion"        = COLOR_RED,
	"Consciousness"   = COLOR_SURGERY_BLUE,
	"Energistics"     = COLOR_MEDICAL_UNKNOWN_IMPLANT,
	"Manifestation"   = COLOR_LIGHT_CYAN,
	"Metakinesis"     = COLOR_SEDONA,
	"Psychokinesis"   = COLOR_YELLOW,
	"Redaction"       = MANIFEST_COLOR_SERVICE,
	"Shaymanism"      = COLOR_CRYSTAL
))

GLOBAL_LIST_AS(psi_threat_level2free_points, list(6, 8, 12, 16))

/datum/preferences
	var/list/psi_abilities

/datum/preferences/proc/sanitize_psi_abilities()
	if(!psi_threat_level)
		return

	while(TRUE)
		for(var/faculty in psi_abilities)
			if(calculate_free_points() >= 0)
				return

			if(psi_abilities[faculty] > 1)
				--psi_abilities[faculty]


/datum/preferences/proc/calculate_free_points()
	. = GLOB.psi_threat_level2free_points[psi_threat_level]

	for(var/faculty in psi_abilities)
		for(var/level in 1 to LAZYLEN(GLOB.psi_level2cost))
			var/level_name = GLOB.psi_level2cost[level]
			var/level_cost = GLOB.psi_level2cost[level_name]

			if(psi_abilities[faculty] == level)
				. -= level_cost

/datum/category_item/player_setup_item/psionics/abilities
	name = "Abilities"
	sort_order = 3

	var/static/list/psi_faculties_names

/datum/category_item/player_setup_item/psionics/abilities/load_character(datum/pref_record_reader/R)
	pref.psi_abilities = R.read("psi_abilities")

/datum/category_item/player_setup_item/psionics/abilities/save_character(datum/pref_record_writer/W)
	W.write("psi_abilities", pref.psi_abilities)

/datum/category_item/player_setup_item/psionics/abilities/sanitize_character()
	if(LAZYLEN(pref.psi_abilities))
		return ..()

	if(!psi_faculties_names)
		psi_faculties_names = list()

		var/list/faculties = GET_SINGLETON_SUBTYPE_MAP(/singleton/psionic_faculty)
		for(var/ftype in faculties)
			var/singleton/psionic_faculty/faculty = faculties[ftype]
			psi_faculties_names += faculty.name

	pref.psi_abilities = list()
	for(var/faculty in psi_faculties_names)
		pref.psi_abilities[faculty] = 1

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

		. += "</style>"

		. += "<tt><center>"

		. += FONT_LARGE("<b>Points remaining: [pref.calculate_free_points()]</b>")

		. += "<table style='width: 100%' style='font-size: 15px; text-align: center' class='table'>"

		if(pref.species == SPECIES_TAJARA)
			. += available_disciples(PSI_TAJARAN_DISCIPLES)
		if(pref.species in HUMAN_SPECIES)
			. += available_disciples(PSI_HUMAN_DISCIPLES)

		. += "</tr>"

		. += "</table>"

		. += "</center></tt>"

	. = jointext(., null)

/datum/category_item/player_setup_item/psionics/abilities/proc/available_disciples(disciples)
	for(var/faculty in disciples)
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
	return .

/datum/category_item/player_setup_item/psionics/abilities/OnTopic(href, list/href_list, mob/user)
	if(..())
		return TOPIC_HANDLED

	if(href_list["select"])
		var/level   = text2num(href_list["select"])
		var/faculty = href_list["faculty"]

		if(!can_select_level(faculty, level))
			return TOPIC_HANDLED

		pref.psi_abilities[faculty] = level

	return TOPIC_REFRESH
