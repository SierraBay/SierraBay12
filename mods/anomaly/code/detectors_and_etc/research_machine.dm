/obj/machinery/urm
	name = "universal research machine"
	desc = "A large device that combines spectrometers, irradiators, all types of microscopes and other very necessary equipment. The dream of any scientific department."
	icon = 'mods/anomaly/icons/urm.dmi'
	icon_state = "urm"
	anchored = TRUE
	idle_power_usage = 5
	power_channel = EQUIP
	var/obj/item/cell/charging = null
	var/chargelevel = -1
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	var/obj/item/artefact/artefact_inside
	var/last_interaction_output
	var/busy = TRUE
	var/list/stored_interactions = list()


	var/last_interaction_reward
	var/last_interaction_id

/obj/machinery/urm/use_tool(obj/item/tool, mob/living/user, list/click_params)
	. = ..()
	if(istype(tool, /obj/item/artefact))
		try_insert_artefact_in_machine(tool, user)

/obj/machinery/urm/proc/try_insert_artefact_in_machine(obj/item/artefact/tool, mob/living/user)
	if(artefact_inside)
		to_chat(user, SPAN_BAD("Machine already have artefact inside"))
		return
	else
		insert_artefact_in_machine(tool, user)

/obj/machinery/urm/proc/insert_artefact_in_machine(obj/item/artefact/tool, mob/living/user)
	if(!user.unEquip(tool))
		return
	to_chat(user, SPAN_NOTICE("you placed [tool] on the [src] stock and closed the protective cover."))
	artefact_inside = tool
	artefact_inside.stored_in_urm = src
	tool.forceMove(src)

/obj/machinery/urm/proc/try_pop_out_artefact_from_machine(mob/living/user)
	if(!artefact_inside)
		to_chat(user, SPAN_BAD("Machine is empty"))
		return
	else
		pop_out_artefact_from_machine(user)

/obj/machinery/urm/proc/pop_out_artefact_from_machine(mob/living/user)
	artefact_inside.stored_in_urm = null
	artefact_inside.forceMove(get_turf(src))
	user.put_in_hands(artefact_inside)
	artefact_inside = null

/obj/machinery/urm/attack_hand(mob/user)
	. = ..()
	interact_with_urm(user)

/obj/machinery/urm/proc/interact_with_urm(mob/user)
	if(!busy)
		to_chat(user, SPAN_NOTICE("Machine currently busy."))
	else
		var/list/options = list("Облучение радиацией", "Облучить лазером", "Провести электричество через обьект", "Облучить обьект плазмой", "Облучить обьект фороном", "Осмотреть обьект набором микроскопов", "Пересмотреть запись последнего взаимодействия", "Извлечь обьект из аппарата", "Напечатать отчёт последнего взаимодействия")
		var/choose = input(usr, "Choose research instrument","Choose") as null|anything in options
		if(!artefact_inside)
			to_chat(user, SPAN_NOTICE("No object inside."))
			return
		if(!user.Adjacent(src))
			return
		if(choose == "Облучение радиацией")
			var/interaction_output = artefact_inside.urm_radiation(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Облучить лазером")
			var/interaction_output = artefact_inside.urm_laser(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Провести электричество через обьект")
			var/interaction_output = artefact_inside.urm_electro(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Облучить обьект плазмой")
			var/interaction_output = artefact_inside.urm_plasma(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Облучить обьект фороном")
			var/interaction_output = artefact_inside.urm_phoron(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Осмотреть обьект набором микроскопов")
			var/interaction_output = artefact_inside.urm_microscope(user)
			last_interaction_output = interaction_output
			to_chat (user, SPAN_NOTICE(interaction_output))
		else if(choose == "Пересмотреть запись последнего взаимодействия")
			if(!last_interaction_output)
				to_chat(user, SPAN_NOTICE("No data"))
			else
				to_chat(user, SPAN_NOTICE("[last_interaction_output]"))
		else if(choose == "Напечатать отчёт последнего взаимодействия")
			if(last_interaction_id && last_interaction_reward)
				create_artefact_report(last_interaction_id, last_interaction_reward)
			else
				to_chat(user, SPAN_NOTICE("No data"))
		else if(choose == "Извлечь обьект из аппарата")
			try_pop_out_artefact_from_machine(user)


/obj/machinery/artifact_analyser/get_scan_info(obj/scanned_obj)
	switch(scanned_obj.type)
		if(/obj/machinery/auto_cloner)
			return "Automated cloning pod - appears to rely on an artificial ecosystem formed by semi-organic nanomachines and the contained liquid.<br>The liquid resembles protoplasmic residue supportive of unicellular organism developmental conditions.<br>The structure is composed of a titanium alloy."
		if(/obj/machinery/power/supermatter)
			return "Superdense phoron clump - appears to have been shaped or hewn, structure is composed of matter aproximately 20 times denser than ordinary refined phoron."
		if(/obj/structure/constructshell)
			return "Tribal idol - subject resembles statues/emblems built by superstitious pre-warp civilisations to honour their gods. Material appears to be a rock/plastcrete composite."
		if(/obj/machinery/giga_drill)
			return "Automated mining drill - structure composed of titanium-carbide alloy, with tip and drill lines edged in an alloy of diamond and phoron."
		if(/obj/structure/cult/pylon)
			return "Tribal pylon - subject resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/machinery/replicator)
			return "Automated construction unit - subject appears to be able to synthesize various objects given a material, some with simple internal circuitry. Method unknown."
		if(/obj/machinery/artifact)
			var/obj/machinery/artifact/A = scanned_obj
			var/out = "Anomalous alien device - composed of an unknown alloy.<br><br>"

			if(A.my_effect)
				out += A.my_effect.getDescription()

			if(A.secondary_effect)
				out += "<br><br>Internal scans indicate ongoing secondary activity operating independently from primary systems.<br><br>"
				out += A.secondary_effect.getDescription()

			if (A.damage_desc)
				out += "<br><br>[A.damage_desc]"
			return out
		if(/obj/machinery/artifact/no_anomalies)
			var/obj/machinery/artifact/A = scanned_obj
			var/out = "Anomalous alien device - composed of an unknown alloy.<br><br>"

			if(A.my_effect)
				out += A.my_effect.getDescription()

			if(A.secondary_effect)
				out += "<br><br>Internal scans indicate ongoing secondary activity operating independently from primary systems.<br><br>"
				out += A.secondary_effect.getDescription()

			if (A.damage_desc)
				out += "<br><br>[A.damage_desc]"

			return out
		else
			return "[scanned_obj.name] - mundane application."









/datum/design/circuit/urm
	name = "Universal research machine"
	id = "urm"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4, TECH_BLUESPACE = 4)
	build_path = /obj/item/stock_parts/circuitboard/urm
	sort_string = "HABAM"

/obj/item/stock_parts/circuitboard/urm
	name = "circuit board (universal research machine)"
	build_path = /obj/machinery/urm
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4)
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/small_artefact_scan_disk
	name = "URM data disk"
	desc = "Unical data disk with specific analytic data inside."
	icon = 'mods/anomaly/icons/urm.dmi'
	icon_state = "data_disk"
	var/interaction_id
	var/rnd_points_reward = 1000

/obj/machinery/urm/proc/create_artefact_report(input_interaction_id, input_rnd_reward)
	var/obj/item/small_artefact_scan_disk/disk = new /obj/item/small_artefact_scan_disk(src.loc)
	disk.interaction_id = input_interaction_id
	disk.rnd_points_reward = input_rnd_reward
