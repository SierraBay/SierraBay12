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

	if((istype(src, /obj/item/integrated_circuit/manipulation/weapon_firing) && src.vars["installed_gun"] != null) || (istype(src, /obj/item/integrated_circuit/manipulation/ai) && src.vars["controlling"] != null) || (istype(src, /obj/item/integrated_circuit/manipulation/grenade) && src.vars["attached_grenade"] != null))
		HTML += "<a href='?src=\ref[src];iremove=1'>\[Remove item\]</a>  |  "
	if(assembly)
		HTML += "<a href='?src=\ref[src];return=1'>\[Return to Assembly\]</a><br>"
	HTML += "<a href='?src=\ref[src];refresh=1'>\[Refresh\]</a>  |  "
	HTML += "<a href='?src=\ref[src];rename=1'>\[Rename\]</a>  |  "
	HTML += "<a href='?src=\ref[src];scan=1'>\[Copy Ref\]</a>"
	if(assembly && removable)
		HTML += "  |  <a href='?src=\ref[assembly];component=\ref[src];remove=1'>\[Remove\]</a>"
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

	HTML += "<br>[SPAN_COLOR("#0000aa", "Complexity: [complexity]")]"
	HTML += "<br>[SPAN_COLOR("#0000aa", "Cooldown per use: [cooldown_per_use/10] sec")]"
	if(ext_cooldown)
		HTML += "<br>[SPAN_COLOR("#0000aa", "External manipulation cooldown: [ext_cooldown/10] sec")]"
	if(power_draw_idle)
		HTML += "<br>[SPAN_COLOR("#0000aa", "Power Draw: [power_draw_idle] W (Idle)")]"
	if(power_draw_per_use)
		HTML += "<br>[SPAN_COLOR("#0000aa", "Power Draw: [power_draw_per_use] W (Active)")]" // Borgcode says that powercells' checked_use() takes joules as input.
	HTML += "<br>[SPAN_COLOR("#0000aa", extended_desc)]"

	HTML += "</body></html>"
	var/HTML_merged = jointext(HTML, null)
	if(assembly)
		show_browser(user, HTML_merged, "window=assembly-\ref[assembly];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")
	else
		show_browser(user, HTML_merged, "window=circuit-\ref[src];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")

	onclose(user, "assembly-\ref[src.assembly]")

/obj/item/integrated_circuit/Topic(href, href_list, state = GLOB.physical_state)
	if(href_list["iremove"])
		if(istype(src,/obj/item/integrated_circuit/manipulation/weapon_firing))
			var/obj/item/integrated_circuit/manipulation/weapon_firing/B = src
			B.eject_gun(usr)
		else if(istype(src,/obj/item/integrated_circuit/manipulation/ai))
			var/obj/item/integrated_circuit/manipulation/ai/B = src
			B.unload_ai()
		else if(istype(src,/obj/item/integrated_circuit/manipulation/grenade))
			var/obj/item/integrated_circuit/manipulation/grenade/B = src
			B.detach_grenade()
		internal_examine(usr)
	..()