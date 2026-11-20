/mob/living/proc/show_psi_assay(mob/viewer, obj/machinery/psi_meter/machine)

	if(!viewer) viewer = usr

	var/list/dat = list()

	dat += "<h2>Сводка</h2>"
	dat += "<hr>"

	if(psi)
		var/use_rating
		var/effective_rating = psi.rating
		var/num_of_disps = LAZYLEN(psi.ranks)
		if(effective_rating > 1 && psi.suppressed)
			effective_rating = max(0, psi.rating-2)
		var/rating_descriptor
		if(mind && !psi.suppressed)
			if(GLOB.paramounts.is_antagonist(mind))
				use_rating = SPAN_COLOR(COLOR_ASSEMBLY_RED, "<b>ПОТЕНЦИАЛЬНЫЙ ПСИ-ДЕВИАНТ</b>")
				rating_descriptor = "This indicates a completely deviant psi complexus, either beyond or outside anything currently recorded. Approach with care."
			// This space intentionally left blank (for Omega-Minus psi vampires. todo)
			if(viewer != usr && GLOB.thralls.is_antagonist(mind) && ishuman(viewer))
				var/mob/living/H = viewer
				if(H.psi && H.psi.get_rank(PSI_KINESIS) >= PSI_RANK_OPERANT)
					dat += SPAN_COLOR(COLOR_ASSEMBLY_RED, "<b>Разум отдает признаки пси-подчинения</b>")

		if(!use_rating)
			switch(effective_rating)
				if(1)
					use_rating = "[num_of_disps-1]-Омикрон"
					rating_descriptor = "обозначает присутствие слабых психосил или латентность."
				if(2)
					use_rating = "[num_of_disps]-Омега"
					rating_descriptor = "обозначает присутствие умеренных психосил, сравнимых с уровнем Омега или выше."
				if(3)
					use_rating = SPAN_COLOR("#f4f441", "[num_of_disps]-Ламед")
					rating_descriptor = "обозначает присутствие психосил, сравнимых с уровнем Ламед или выше."
				if(4)
					use_rating = SPAN_COLOR("#f4bc42", "[num_of_disps]-Гиммель")
					rating_descriptor = "обозначает присутствие сильных психосил, сравнимых с уровнем Гиммель или выше."
				if(5)
					use_rating = SPAN_COLOR("#ff0000", "[num_of_disps]-Алеф")
					rating_descriptor = "обозначает присутствие мощных психосил, сравнимых с уровнем Алеф."
				else
					use_rating = "[num_of_disps]-Омикрон"
					rating_descriptor = "обозначает присутствие латентных психосил."

		dat += "Обнаружается обладание рейтингом [use_rating].<br><i>Это [rating_descriptor]</i><hr>"

		if(!istype(machine))

			dat += "Пси-силы <b>[psi.suppressed ? "подавляются" : "не подавляются"]</b> сейчас.<br>"
			dat += "Остаётся <b>[psi.stamina]/[psi.max_stamina]</b> пси энергии.<br>"
			dat += "<hr>"

			for(var/faculty_id in psi.ranks)
				var/singleton/psionic_faculty/faculty = SSpsi.get_faculty(faculty_id)
				if(psi.ranks[faculty_id] > 0)
					dat += "Владение рангом <b>[GLOB.psychic_ranks_to_strings[psi.ranks[faculty.id]]]</b> для пси-направленности <b>Пси-[faculty.name]</b>.<br>"
				else
					dat += "Не обладает пси-силами для Пси-<b>[faculty.name]</b>.<br>"
			dat += "<hr>"

			if(viewer == usr)
				dat += "<table width = 100% border = 1><tr><td colspan = 2><h2>Psi-power Usage</h2></td></tr>"
				for(var/faculty_id in psi.ranks)
					var/list/check_powers = psi.get_powers_by_faculty(faculty_id)
					if(LAZYLEN(check_powers))
						var/singleton/psionic_faculty/faculty = SSpsi.get_faculty(faculty_id)
						dat += "<tr><td colspan = 2>Владение соответствующими способностями <b>[faculty.name] </b>:</td></tr>"
						for(var/singleton/psionic_power/power in check_powers)
							dat += "<tr><td><b>[power.name]</b></td><td>[power.use_description]</td></tr>"
				dat += "</table>"
	else
		dat += "Не обладает фиксируемыми психонетическими способностями."

	if(istype(machine))
		dat += "<a href='?src=\ref[machine];print=1'>Print</a> <a href='?src=\ref[machine];clear=1'>Clear Buffer</a>"
		machine.last_assay = dat
		return

	var/datum/browser/popup = new(viewer, "psi_assay_\ref[src]", "Psi-Assay")
	popup.set_content(jointext(dat,null))
	popup.open()
