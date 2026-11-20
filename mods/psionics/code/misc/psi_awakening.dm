#define PSI_AWAKENING_PULSES 3
#define PSI_AWAKENING_PULSE_DELAY (3 SECONDS)
#define PSI_AWAKENING_BASE_POINTS 2        // Стартовые очки, когда пробуждение никто не видел
#define PSI_AWAKENING_MAX_POINTS 14
#define PSI_AWAKENING_POINTS_PER_RANK 3    // Каждые столько очков открывают следующий ранг способностей
#define PSI_AWAKENING_WITNESS_RANGE 7      // Радиус, в котором персонажи считаются свидетелями

/datum/psi_complexus
	var/datum/psi_awakening/pending_awakening
	var/list/awakening_queue

/datum/psi_complexus/proc/queue_job_awakenings(list/faculty_ranks, source)
	for(var/faculty in faculty_ranks)
		if(!awakening_queue)
			awakening_queue = list()
		awakening_queue += list(list(faculty, faculty_ranks[faculty], source))
	start_next_awakening()

/datum/psi_complexus/proc/start_next_awakening()
	if(pending_awakening || !LAZYLEN(awakening_queue) || !owner)
		return
	var/list/entry = awakening_queue[1]
	awakening_queue.Cut(1, 2)
	var/datum/psi_awakening/awakening = new /datum/psi_awakening(src, entry[1], entry[3], FALSE, entry[2])
	awakening.begin()

/mob/living/proc/open_psi_awakening()
	set name = "Выбор способностей"
	set category = "IC"
	if(psi && psi.pending_awakening)
		psi.pending_awakening.open(src)

/proc/get_psi_awakening_cost(singleton/psionic_power/power)
	return max(1, power.min_rank - 1)

/datum/psi_awakening
	var/datum/psi_complexus/psi
	var/mob/living/owner
	var/faculty
	var/source
	var/redactive = FALSE
	var/job_rank = 0
	var/list/witnesses = list()
	var/points = 0
	var/max_rank = PSI_RANK_APPRENTICE
	var/ready = FALSE
	var/list/chosen = list()

/datum/psi_awakening/New(datum/psi_complexus/_psi, _faculty, _source, _redactive, _job_rank = 0)
	psi = _psi
	owner = _psi.owner
	faculty = _faculty
	source = _source
	redactive = _redactive
	job_rank = _job_rank
	record_witnesses()
	psi.pending_awakening = src
	owner.verbs += /mob/living/proc/open_psi_awakening

/datum/psi_awakening/proc/record_witnesses()
	if(!owner)
		return
	for(var/mob/living/M in oview(PSI_AWAKENING_WITNESS_RANGE, owner))
		if(M.stat == DEAD || !M.mind)
			continue
		witnesses |= M.mind

/datum/psi_awakening/proc/is_valid()
	return psi && !QDELETED(psi) && owner && !QDELETED(owner) && owner.psi == psi && owner.stat != DEAD

/datum/psi_awakening/proc/calculate_budget()
	if(job_rank)
		points = PSI_AWAKENING_BASE_POINTS + max(0, job_rank) * PSI_AWAKENING_POINTS_PER_RANK
		max_rank = job_rank
	else
		record_witnesses()
		points = PSI_AWAKENING_BASE_POINTS + LAZYLEN(witnesses)
		max_rank = clamp(PSI_RANK_APPRENTICE + floor(sqrt(LAZYLEN(witnesses)) + PSI_RANK_LATENT), PSI_RANK_APPRENTICE, PSI_RANK_GRANDMASTER)
	points = clamp(points, PSI_AWAKENING_BASE_POINTS, PSI_AWAKENING_MAX_POINTS)
	ready = TRUE

/datum/psi_awakening/proc/begin()
	set waitfor = FALSE

	if(!job_rank)
		psi.start_instability(PSI_AWAKENING_PULSES * PSI_AWAKENING_PULSE_DELAY + 30 SECONDS, 2)
		for(var/i in 1 to PSI_AWAKENING_PULSES)
			sleep(PSI_AWAKENING_PULSE_DELAY)
			if(!is_valid())
				cancel()
				return
			pulse(i)
			record_witnesses()

	if(!is_valid())
		cancel()
		return

	calculate_budget()

	if(!job_rank)
		to_chat(owner, SPAN_OCCULT("Боль отступает, и на её месте остаётся понимание того, что ты можешь. Выбери, чем распорядиться силой."))
	if(owner.client)
		open(owner)
	else
		auto_finish()
		return

/datum/psi_awakening/proc/pulse(number)
	owner.adjustBrainLoss(rand(3, 9))
	to_chat(owner, SPAN_DANGER(pick(
		"Разум раскалывается, и сквозь трещины льётся что-то чужое.",
		"Боль вспыхивает за глазами и растекается по всему телу.",
		"Внутренности бархатно чешутся.",
		"Жир в голове словно закипает и вытекает через нос.",
		"Ты чувствуешь, как внутри что-то разрывается и срастается заново.")))
	psi.instability_surge(number >= PSI_AWAKENING_PULSES ? 2 : 1)

/datum/psi_awakening/proc/cancel()
	if(owner)
		owner.verbs -= /mob/living/proc/open_psi_awakening
		owner << browse(null, "window=psi_awakening")
	if(psi && !QDELETED(psi))
		psi.pending_awakening = null
		psi.next_latency_trigger = world.time + rand(600, 1800)
	psi = null
	owner = null

/datum/psi_awakening/proc/get_spent()
	. = 0
	for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
		if(power.get_id() in chosen)
			. += get_psi_awakening_cost(power)

/datum/psi_awakening/proc/is_available(singleton/psionic_power/power)
	return power.min_rank <= max_rank

/datum/psi_awakening/proc/open(mob/user)
	if(!ready || !is_valid() || user != owner)
		return
	var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)
	var/spent = get_spent()
	var/left = points - spent
	var/rank_name = GLOB.psychic_ranks_to_strings[max_rank] || "[max_rank]"

	var/list/html = list()
	html += "<html><head><meta charset='UTF-8'></head><body style='background:#1b1b24; color:#ddd; font-family: Verdana, sans-serif; font-size: 12px'>"
	html += "<center><h2 style='margin:4px'>[job_rank ? "Псионика" : "Пробуждение"]: [faculty_singleton ? faculty_singleton.name : faculty]</h2></center>"
	if(job_rank)
		html += "<div style='margin-bottom:8px'>Очков: <b>[left]</b> из [points]. Доступен ранг способностей до: <b>[rank_name]</b>.<br>"
		html += "<small>Ранг и количество способностей определяются подготовкой, которую даёт должность.</small></div>"
	else
		html += "<div style='margin-bottom:8px'>Источник: [html_encode(source)].<br>"
		html += "Очков: <b>[left]</b> из [points]. Доступен ранг способностей до: <b>[rank_name]</b>.<br></div>"
		html += "<center><a href='?src=\ref[src];random=1' style='color:#aaa'>Довериться случаю</a><hr>"
		if(length(chosen))
			html += "<a href='?src=\ref[src];confirm=1' style='color:#fd8; font-size:14px'><b>Принять силу</b></a><br>"
		else
			html += "<span style='color:#777'>Выбери хотя бы одну способность</span><br>"
	html += "</center><table width='100%' cellspacing='0' cellpadding='3'>"
	html += "<tr style='background:#2b2b3a'><th align='left'>Способность</th><th>Ранг</th><th>Цена</th><th></th></tr>"

	for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
		var/id = power.get_id()
		var/cost = get_psi_awakening_cost(power)
		var/rank_text = GLOB.psychic_ranks_to_strings[power.min_rank] || "[power.min_rank]"
		var/description = html_encode(power.use_description)
		var/button
		var/row_style = ""
		if(id in chosen)
			row_style = "background:#1f4d2b"
			button = "<a href='?src=\ref[src];toggle=[id]' style='color:#9f9'>Убрать</a>"
		else if(!is_available(power))
			row_style = "color:#777"
			button = "<span title='Нужно больше урона'>Закрыто</span>"
		else if(cost > left)
			row_style = "color:#999"
			button = "<span title='Не хватает очков'>Не хватает</span>"
		else
			button = "<a href='?src=\ref[src];toggle=[id]' style='color:#8cf'>Выбрать</a>"
		html += "<tr style='[row_style]'><td title='[description]'><b>[power.name]</b></td><td align='center'>[rank_text]</td><td align='center'>[cost]</td><td align='center'>[button]</td></tr>"
		html += "<tr style='[row_style]'><td colspan='4'><small>[description]</small></td></tr>"

	html += "</table><br>"
	html += "</body></html>"

	show_browser(user, jointext(html, null), "window=psi[user.name];size=620x680")

/datum/psi_awakening/Topic(href, href_list)
	if(!ready || !is_valid() || usr != owner)
		return TRUE

	if(href_list["toggle"])
		var/singleton/psionic_power/target_power
		for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
			if(power.get_id() == href_list["toggle"])
				target_power = power
				break
		if(target_power)
			var/id = target_power.get_id()
			if(id in chosen)
				chosen -= id
			else if(is_available(target_power) && get_psi_awakening_cost(target_power) <= (points - get_spent()))
				chosen += id
		open(usr)
	else if(href_list["confirm"])
		finish()
	else if(href_list["random"])
		auto_finish()
	return TRUE

/datum/psi_awakening/proc/auto_finish()
	if(!ready)
		calculate_budget()
	while(TRUE)
		var/list/candidates = list()
		var/left = points - get_spent()
		for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
			if(is_available(power) && !(power.get_id() in chosen) && get_psi_awakening_cost(power) <= left)
				candidates += power
		if(!length(candidates))
			break
		var/singleton/psionic_power/picked = pick(candidates)
		chosen += picked.get_id()
	finish()

/datum/psi_awakening/proc/finish()
	if(!length(chosen) || !is_valid())
		return

	var/highest_rank = PSI_RANK_APPRENTICE
	var/list/names = list()
	for(var/singleton/psionic_power/power in get_selectable_psi_powers(faculty))
		if(power.get_id() in chosen)
			highest_rank = max(highest_rank, power.min_rank)
			names += power.name

	var/datum/psi_complexus/awakened = psi
	var/mob/living/awakened_owner = owner

	var/list/final_powers = awakened.get_selected_power_ids(faculty)
	final_powers |= chosen
	awakened.set_selected_powers(faculty, final_powers)
	awakened_owner.set_psi_rank(faculty, highest_rank, take_larger = TRUE)

	awakened.pending_awakening = null
	awakened_owner.verbs -= /mob/living/proc/open_psi_awakening
	awakened_owner << browse(null, "window=psi_awakening")
	if(!job_rank)
		awakened.start_instability(highest_rank * 60 SECONDS, clamp(highest_rank - 1, 1, 3))
	awakened.next_latency_trigger = world.time + rand(600, 1800) * highest_rank

	var/singleton/psionic_faculty/faculty_singleton = SSpsi.get_faculty(faculty)
	to_chat(awakened_owner, SPAN_NOTICE("Дисциплина [faculty_singleton ? faculty_singleton.name : faculty] окончательно приняла форму: [english_list(names)]."))
	log_and_message_admins("завершил [job_rank ? "выбор псионики по профессии" : "пробуждение"] [faculty_singleton ? faculty_singleton.name : faculty] (ранг [highest_rank], [job_rank ? "ранг должности [job_rank]" : "свидетелей [length(witnesses)]"], способности: [english_list(names)]), источник: [source].", awakened_owner)

	psi = null
	owner = null
	awakened.start_next_awakening()
