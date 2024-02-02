/obj/item/integrated_circuit
	name = "интегральная микросхема"
	desc = "Это крошечная микросхема! Однако, похоже, она мало что умеет."

/obj/item/integrated_circuit/rename_component()
	set name = "Rename Circuit"
	set category = "Object"
	set desc = "Rename your circuit, useful to stay organized."

	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = sanitizeName(input(M, "Как вы хотите переименовать это?", "Переименовать", name) as null|text, allow_numbers = TRUE)
	if(check_interactivity(M))
		if(!input)
			input = name
		to_chat(M, SPAN_NOTICE("Схема '[name]' теперь называется '[input]'."))
		displayed_name = input
/obj/item/integrated_circuit/interact(mob/user)
	. = ..()
	if(!check_interactivity(user))
		return

	var/window_height = 350
	var/window_width = 655

	var/table_edge_width = "30%"
	var/table_middle_width = "40%"
	var/list/HTML = list()
	HTML += "<html><head><title>[src.displayed_name]</title></head><body>"
	HTML += "<div align='center'>"
	HTML += "<table border='1' style='undefined;table-layout: fixed; width: 80%'>"

	if(assembly)
		HTML += "<a href='?src=\ref[src];return=1'>\[Вернуться к сборке\]</a><br>"

	HTML += "<a href='?src=\ref[src];refresh=1'>\[Обновить\]</a>  |  "
	HTML += "<a href='?src=\ref[src];rename=1'>\[Переименовать\]</a>  |  "
	HTML += "<a href='?src=\ref[src];scan=1'>\[Скопировать референс\]</a>"
	if(assembly && removable)
		HTML += "  |  <a href='?src=\ref[assembly];component=\ref[src];remove=1'>\[Вынуть\]</a>"
	HTML += "<br>"

	HTML += "<colgroup>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "<col style='width: [table_middle_width]'>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "</colgroup>"

	var/column_width = 3
	var/row_height = max(LAZYLEN(inputs), LAZYLEN(outputs), 1)

	for(var/i = 1 to row_height)
		HTML += "<tr>"
		for(var/j = 1 to column_width)
			var/datum/integrated_io/io = null
			var/words = list()
			var/height = 1
			switch(j)
				if(1)
					io = get_pin_ref(IC_INPUT, i)
					if(io)
						words += "<b><a href='?src=\ref[src];act=wire;pin=\ref[io]'>[io.display_pin_type()] [io.name]</a> \
						<a href='?src=\ref[src];act=data;pin=\ref[io]'>[io.display_data(io.data)]</a></b><br>"
						if(length(io.linked))
							for(var/k in 1 to length(io.linked))
								var/datum/integrated_io/linked = io.linked[k]
								words += "<a href='?src=\ref[src];act=unwire;pin=\ref[io];link=\ref[linked]'>[linked]</a> \
								@ <a href='?src=\ref[linked.holder]'>[linked.holder.displayed_name]</a><br>"

						if(LAZYLEN(outputs) > LAZYLEN(inputs))
							height = 1
				if(2)
					if(i == 1)
						words += "[src.displayed_name]<br>[src.name != src.displayed_name ? "([src.name])":""]<hr>[src.desc]"
						height = row_height
					else
						continue
				if(3)
					io = get_pin_ref(IC_OUTPUT, i)
					if(io)
						words += "<b><a href='?src=\ref[src];act=wire;pin=\ref[io]'>[io.display_pin_type()] [io.name]</a> \
						<a href='?src=\ref[src];act=data;pin=\ref[io]'>[io.display_data(io.data)]</a></b><br>"
						if(length(io.linked))
							for(var/k in 1 to length(io.linked))
								var/datum/integrated_io/linked = io.linked[k]
								words += "<a href='?src=\ref[src];act=unwire;pin=\ref[io];link=\ref[linked]'>[linked]</a> \
								@ <a href='?src=\ref[linked.holder]'>[linked.holder.displayed_name]</a><br>"

						if(LAZYLEN(inputs) > LAZYLEN(outputs))
							height = 1
			HTML += "<td align='center' rowspan='[height]'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	for(var/i in 1 to LAZYLEN(activators))
		var/datum/integrated_io/io = activators[i]
		var/words = list()

		words += "<b><a href='?src=\ref[src];act=wire;pin=\ref[io]'>[SPAN_COLOR("#ff0000", io)]</a> "
		words += "<a href='?src=\ref[src];act=data;pin=\ref[io]'>[SPAN_COLOR("#ff0000", io.data ? "\<PULSE OUT\>" : "\<PULSE IN\>")]</a></b><br>"
		if(length(io.linked))
			for(var/k in 1 to length(io.linked))
				var/datum/integrated_io/linked = io.linked[k]
				words += "<a href='?src=\ref[src];act=unwire;pin=\ref[io];link=\ref[linked]'>[SPAN_COLOR("#ff0000", linked)]</a> \
				@ <a href='?src=\ref[linked.holder]'>[SPAN_COLOR("#ff0000", linked.holder.displayed_name)]</a><br>"

		HTML += "<tr>"
		HTML += "<td colspan='3' align='center'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	HTML += "</table>"
	HTML += "</div>"

	HTML += "<br>[SPAN_COLOR("#0000aa", "Нагруженность: [complexity]")]"
	HTML += "<br>[SPAN_COLOR("#0000aa", "Откат активации: [cooldown_per_use/10] сек")]"
	if(ext_cooldown)
		HTML += "<br>[SPAN_COLOR("#0000aa", "Откат внешних манипуляций: [ext_cooldown/10] сек")]"
	if(power_draw_idle)
		HTML += "<br>[SPAN_COLOR("#0000aa", "Потребление энергии: [power_draw_idle] Вт (В покое)")]"
	if(power_draw_per_use)
		HTML += "<br>[SPAN_COLOR("#0000aa", "Потребление энергии: [power_draw_per_use] Вт (В активном состоянии)")]" // Borgcode says that powercells' checked_use() takes joules as input.
	HTML += "<br>[SPAN_COLOR("#0000aa", extended_desc)]"

	HTML += "</body></html>"
	var/HTML_merged = jointext(HTML, null)
	if(assembly)
		show_browser(user, HTML_merged, "window=assembly-\ref[assembly];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")
	else
		show_browser(user, HTML_merged, "window=circuit-\ref[src];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")

	onclose(user, "assembly-\ref[src.assembly]")

/obj/item/device/integrated_circuit_printer/interact(mob/user)
	if(!(in_range(src, user) || issilicon(user)))
		return

	if(isnull(current_category))
		current_category = SScircuit.circuit_fabricator_recipe_list[1]

	//Preparing the browser
	var/datum/browser/popup = new(user, "printernew", "Принтер интегральных цепей", 800, 630) // Set up the popup browser window

	var/list/HTML = list()
	HTML += "<center><h2>Принтер интегральных цепей</h2></center><br>"
	if(debug)
		HTML += "<center><h3>DEBUG PRINTER -- Infinite materials. Cloning available.</h3></center>"
	else
		HTML += "Материалы: "
		var/list/dat = list()
		for(var/material in materials)
			var/material/material_datum = SSmaterials.get_material_by_name(material)
			dat += "[materials[material]]/[metal_max] [material_datum.display_name]"
		HTML += jointext(dat, "; ")
		HTML += ".<br><br>"

	if(config.allow_ic_printing || debug)
		HTML += "Клонирование сборок: [can_clone ? (fast_clone ? "Мгновенное" : "Доступно") : "Недоступно"].<br>"

	HTML += "Доступные схемы: [upgraded || debug ? "Улучшенные":"Обычные"]."
	if(!upgraded)
		HTML += "<br>Зачеркнутые схемы означают, что принтер недостаточно модернизирован для создания данных схем."

	HTML += "<hr>"
	if((can_clone && config.allow_ic_printing) || debug)
		HTML += "Здесь вы можете загрузить скрипт для вашей сборки.<br>"
		if(!cloning)
			HTML += " <A href='?src=\ref[src];print=load'>{Загрузить программу}</a> "
		else
			HTML += " {Загрузить программу}"
		if(!program)
			HTML += " {[fast_clone ? "Печать" : "Начать печать"] сборки}"
		else if(cloning)
			HTML += " <A href='?src=\ref[src];print=cancel'>{Отменить печать}</a>"
		else
			HTML += " <A href='?src=\ref[src];print=print'>{[fast_clone ? "Печать" : "Начать печать"] сборки}</a>"

		HTML += "<br><hr>"
	HTML += "Категории:"
	for(var/category in SScircuit.circuit_fabricator_recipe_list)
		if(category != current_category)
			HTML += " <a href='?src=\ref[src];category=[category]'>\[[category]\]</a> "
		else // Bold the button if it's already selected.
			HTML += " <b>\[[category]\]</b> "
	HTML += "<hr>"
	HTML += "<center><h4>[current_category]</h4></center>"

	var/list/current_list = SScircuit.circuit_fabricator_recipe_list[current_category]
	for(var/path in current_list)
		var/obj/O = path
		var/can_build = TRUE
		if(ispath(path, /obj/item/integrated_circuit))
			var/obj/item/integrated_circuit/IC = path
			if((initial(IC.spawn_flags) & IC_SPAWN_RESEARCH) && (!(initial(IC.spawn_flags) & IC_SPAWN_DEFAULT)) && !upgraded)
				can_build = FALSE
		if(can_build)
			HTML += "<A href='?src=\ref[src];build=\ref[path]'>\[[initial(O.name)]\]</A>: [initial(O.desc)]<br>"
		else
			HTML += "<s>\[[initial(O.name)]\]</s>: [initial(O.desc)]<br>"

	popup.set_content(JOINTEXT(HTML))
	popup.open()

/obj/item/device/electronic_assembly/open_interact(mob/user)
	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/list/HTML = list()

	HTML += "<html><head><title>[name]</title></head><body>"

	HTML += "<a href='?src=\ref[src]'>\[Обновить\]</a>  |  <a href='?src=\ref[src];rename=1'>\[Переименовать\]</a><br>"
	HTML += "[total_part_size]/[max_components] занимаемое пространство в сборке.<br>"
	HTML += "[total_complexity]/[max_complexity] нагруженность сборки.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) заряд батареи. <a href='?src=\ref[src];remove_cell=1'>\[Вынуть\]</a>"
	else
		HTML += SPAN_DANGER("Батарея не обнаружена!")

	if(length(assembly_components))
		HTML += "<br><br>"
		HTML += "Компоненты:<br>"

		var/start_index = ((components_per_page * interact_page) + 1)
		for(var/i = start_index to min(length(assembly_components), start_index + (components_per_page - 1)))
			var/obj/item/integrated_circuit/circuit = assembly_components[i]
			HTML += "\[ <a href='?src=\ref[src];component=\ref[circuit];set_slot=1'>[i]</a> \] | "
			HTML += "<a href='?src=\ref[src];component=\ref[circuit];rename_component=1'>\[П\]</a> | "
			if(circuit.removable)
				HTML += "<a href='?src=\ref[src];component=\ref[circuit];remove=1'>\[-\]</a> | "
			else
				HTML += "\[-\] | "
			HTML += "<a href='?src=\ref[src];component=\ref[circuit];examine_component=1'>[circuit.displayed_name]</a>"
			HTML += "<br>"

		if(length(assembly_components) > components_per_page)
			HTML += "<br>\["
			for(var/i = 1 to ceil(length(assembly_components)/components_per_page))
				if((i-1) == interact_page)
					HTML += " [i]"
				else
					HTML += " <a href='?src=\ref[src];select_page=[i-1]'>[i]</a>"
			HTML += " \]"

	HTML += "</body></html>"
	show_browser(user, jointext(HTML, null), "window=assembly-\ref[src];size=655x350;border=1;can_resize=1;can_close=1;can_minimize=1")
