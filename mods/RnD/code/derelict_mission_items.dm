// Derelict Mission Items & Artifacts
// Small items for simple missions (hand-held, submitted via drone pad)
// Large artifacts for complex missions (draggable, researched on Sierra)
// Mission sensor for deploy_sensor objectives

// ============================================================
// BASE: Small mission sample (simple missions)
// ============================================================
/obj/item/derelict_mission_sample
	name = "research sample"
	desc = "A sample collected from a derelict site for corporate research purposes."
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "disk"
	w_class = ITEM_SIZE_NORMAL

/obj/item/derelict_mission_sample/New()
	..()
	derelict_mission_objects += src

/obj/item/derelict_mission_sample/Destroy()
	derelict_mission_objects -= src
	return ..()

// --- Simple mission items per derelict ---

/obj/item/derelict_mission_sample/carp_genetic
	name = "genetic sample of space carp"
	icon_state = "biomatter_tank_medium"
	desc = "A sealed container with genetic material extracted from space carp specimens. Valuable for xenobiological research."

/obj/item/derelict_mission_sample/shield_frequency
	name = "magnetic shield frequency log"
	icon_state = "data"
	desc = "A data module containing recorded frequencies from an orbital magnetic shield generator. Einstein Engines would pay well for this."

/obj/item/derelict_mission_sample/encrypted_disk
	name = "encrypted intelligence disk"
	desc = "A heavily encrypted data storage device recovered from a SCGDF surveillance station. Contains classified signal intelligence."
	icon_state = "disk"

/obj/item/derelict_mission_sample/entertainment_ai
	name = "entertainment AI core"
	icon_state = "core_air"
	desc = "A compact AI core module that managed entertainment systems aboard a passenger liner. Ward-Takahashi specializes in this technology."

/obj/item/derelict_mission_sample/structural_blueprint
	name = "structural engineering blueprint"
	icon_state = "blueprints"
	desc = "Detailed construction blueprints from an abandoned orbital construction project. Contains industrial fabrication data for Hephaestus."

/obj/item/derelict_mission_sample/automation_log
	name = "automation system log"
	icon_state = "data_core"
	desc = "A data core from automated hotel management systems. The degradation patterns are of great interest to Morpheus Cybernetics."

/obj/item/derelict_mission_sample/supply_manifest
	name = "supply logistics manifest"
	icon_state = "data-white"
	desc = "A comprehensive logistics database from an abandoned supply station. Contains industrial supply chain data valuable to Xion."

/obj/item/derelict_mission_sample/contraband_weapons
	name = "contraband weapons data"
	icon_state = "data-red"
	desc = "Encrypted files detailing smuggled weapons designs and modifications. Al-Maliki & Mosley could reverse-engineer these."

/obj/item/derelict_mission_sample/anomaly_readings
	name = "anomalous energy readings"
	icon_state = "data-blue"
	desc = "A sensor module saturated with readings from a non-Euclidean spatial anomaly. Focal Point Energetics would find this invaluable."

// ============================================================
// BASE: Large mission artifact (complex missions)
// ============================================================
/obj/structure/derelict_mission_artifact
	name = "research artifact"
	desc = "A large object recovered from a derelict site requiring detailed study."
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "disk"
	density = TRUE
	anchored = FALSE
	var/research_progress = 0           // 0-100, mission completes at 100
	var/datum/derelict_mission/bound_mission

/obj/structure/derelict_mission_artifact/New()
	..()
	derelict_mission_objects += src

/obj/structure/derelict_mission_artifact/Destroy()
	derelict_mission_objects -= src
	return ..()

/obj/structure/derelict_mission_artifact/proc/ensure_bound_mission()
	if(!bound_mission)
		bound_mission = find_derelict_mission_for_artifact(src)
	return bound_mission

/obj/structure/derelict_mission_artifact/examine(mob/user)
	. = ..()
	if(research_progress >= 100)
		to_chat(user, SPAN_NOTICE("Research complete. Ready for data submission."))

// --- Complex mission artifacts per derelict ---

// ============================================================
// VIRUS CONTAINER (lar_maria / Zeng-Hu)
// Hand-held biohazard container, too large for bags.
// Right-click verb to extract virus sample into culture dish.
// ============================================================

/obj/item/derelict_mission_artifact/virus_container
	name = "Type-8 serum containment unit"
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "serum"
	desc = "Компактный биоконтейнер с образцами экспериментального боевого вируса. Наклейка предупреждает: ПАТОГЕН 4-ГО КЛАССА — АЭРОЗОЛЬНЫЙ СИНДРОМ АГРЕССИИ. Слишком громоздкий для сумок. Используйте ПКМ для извлечения образца."
	w_class = ITEM_SIZE_NO_CONTAINER

	var/datum/disease2/disease/lar_maria/stored_virus = null
	var/sample_extracted = FALSE

/obj/item/derelict_mission_artifact/virus_container/New()
	..()
	derelict_mission_objects += src
	stored_virus = new /datum/disease2/disease/lar_maria()

/obj/item/derelict_mission_artifact/virus_container/Destroy()
	derelict_mission_objects -= src
	QDEL_NULL(stored_virus)
	return ..()

/obj/item/derelict_mission_artifact/virus_container/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_WARNING("Контейнер помечен BIOHAZARD. Обращение без средств биозащиты нежелательно."))
	if(sample_extracted)
		to_chat(user, SPAN_NOTICE("Образец уже был извлечён."))
	else
		to_chat(user, SPAN_NOTICE("Используйте ПКМ (правую кнопку мыши) для извлечения вирусного образца."))

/obj/item/derelict_mission_artifact/virus_container/pickup(mob/living/user)
	. = ..()
	if(!istype(user, /mob/living/carbon))
		return
	var/mob/living/carbon/C = user
	// Risk of airborne exposure on pickup
	if(C.internal)
		return
	var/chance = infection_chance(C, "Airborne")
	if(chance > 0 && prob(chance / 3))
		to_chat(user, SPAN_DANGER("Слабый аэрозоль вырывается из уплотнителей контейнера, когда вы его поднимаете!"))
		infect_virus2(C, stored_virus)

/obj/item/derelict_mission_artifact/virus_container/verb/extract_sample()
	set name = "Extract Sample"
	set category = "Object"
	set src in view(usr, 1)

	if(!istype(usr, /mob/living/carbon))
		return
	var/mob/living/carbon/C = usr

	if(sample_extracted)
		to_chat(usr, SPAN_WARNING("Образец уже был извлечён из контейнера."))
		return

	to_chat(usr, SPAN_NOTICE("Вы осторожно извлекаете вирусный образец из контейнера..."))
	if(!do_after(usr, 4 SECONDS, src))
		return

	// Airborne exposure risk during extraction
	if(!C.internal)
		var/chance = infection_chance(C, "Airborne")
		if(chance > 0 && prob(chance / 2))
			to_chat(usr, SPAN_DANGER("Вы чувствуете лёгкий аэрозоль на лице во время извлечения!"))
			infect_virus2(C, stored_virus)

	// Create culture dish with virus copy
	var/obj/item/virusdish/lar_maria/dish = new(get_turf(usr))
	dish.virus2 = stored_virus.getcopy()
	dish.basic_info = "Type-8 Serum (Lar Maria Weaponised Strain) — Take to virology curer for antidote synthesis."
	sample_extracted = TRUE
	to_chat(usr, SPAN_NOTICE("Образец извлечён в чашку Петри. Доставьте её в вирусологическую лабораторию для синтеза антидота."))

// Culture dish subtype — handed to curer for antidote synthesis
/obj/item/virusdish/lar_maria
	name = "Type-8 serum culture dish"
	desc = "A sealed culture dish containing a live sample of the weaponised Lar Maria virus. Bring it to a virology curer machine to synthesize an antidote."

// ============================================================
// BIO CELL (meatstation / Vey-Med)
// Connect cable → bio-cell multiplies power on nearby cable → player measures wire
// → calculates bio-conversion ratio → inputs via multitool on cell → correct = success, wrong = EMP
// ============================================================

/obj/structure/derelict_mission_artifact/bio_cell
	name = "biological power cell prototype"
	icon_state = "biocell"
	desc = "Экспериментальная ксенофлоральная биоэнергетическая ячейка. Органические филаменты внутри пульсируют слабым биолюминесцентным свечением. Подключите кабель, измерьте мощность на проводе мультитулом и введите коэффициент биоконверсии."
	density = TRUE
	anchored = FALSE

	var/connected = FALSE
	var/measured = FALSE
	var/power_multiplier = 0         // 1.20 - 2.00, randomized
	var/reference_power = 0          // Power snapshot at connection time
	var/obj/structure/cable/connected_cable

/obj/structure/derelict_mission_artifact/bio_cell/New()
	..()
	power_multiplier = 1.2 + (rand(0, 80) / 100.0)

/obj/structure/derelict_mission_artifact/bio_cell/Destroy()
	if(connected && connected_cable)
		STOP_PROCESSING(SSobj, src)
		connected_cable = null
	return ..()

/obj/structure/derelict_mission_artifact/bio_cell/Process()
	if(connected && connected_cable && connected_cable.powernet)
		connected_cable.powernet.avail += reference_power * (power_multiplier - 1)
	else if(connected)
		STOP_PROCESSING(SSobj, src)

/obj/structure/derelict_mission_artifact/bio_cell/examine(mob/user)
	. = ..()
	if(!connected)
		to_chat(user, SPAN_NOTICE("Ячейка неактивна. Подключите кабель для активации."))
	else if(!measured)
		to_chat(user, SPAN_NOTICE("Кабель подключён — энергия поступает в сеть. Измерьте мощность на проводе мультитулом, вычислите коэффициент биоконверсии и введите его."))
	else
		to_chat(user, SPAN_NOTICE("Коэффициент биоконверсии подтверждён. Данные записаны."))

/obj/structure/derelict_mission_artifact/bio_cell/use_tool(obj/item/tool, mob/living/user, list/click_params)
	// Step 1: cable_coil → connect to nearest cable and start pumping power
	if(istype(tool, /obj/item/stack/cable_coil))
		if(connected)
			to_chat(user, SPAN_WARNING("Кабель уже подключён."))
			return TRUE
		var/obj/item/stack/cable_coil/coil = tool
		if(coil.amount < 1)
			to_chat(user, SPAN_WARNING("Катушка кабеля пуста."))
			return TRUE
		// Find a cable on our turf
		var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(src)
		if(!C)
			to_chat(user, SPAN_WARNING("Под ячейкой нет силового кабеля. Проложите провод под ячейкой."))
			return TRUE
		to_chat(user, SPAN_NOTICE("Вы начинаете подключать кабель к [src]..."))
		if(!do_after(user, 3 SECONDS, src))
			return TRUE
		coil.use(1)
		connected = TRUE
		connected_cable = C
		if(C.powernet)
			reference_power = C.powernet.avail
		else
			reference_power = 0
		START_PROCESSING(SSobj, src)
		to_chat(user, SPAN_NOTICE("Кабель подключён. Ячейка начала модифицировать энергопоток. Измерьте мощность на проводе мультитулом."))
		visible_message(SPAN_NOTICE("[src] ярко пульсирует когда [user] подключает кабель."))
		return TRUE

	// Step 2: multitool → input bio-conversion ratio
	if(istype(tool, /obj/item/device/multitool))
		if(!connected)
			to_chat(user, SPAN_WARNING("Ячейка не подключена. Сначала подключите кабель."))
			return TRUE
		if(measured)
			to_chat(user, SPAN_NOTICE("Коэффициент биоконверсии уже подтверждён: [round(power_multiplier, 0.01)]x."))
			return TRUE
		var/input_value = input(user, "Введите измеренный коэффициент биоконверсии:", "Биоячейка") as null|num
		if(!input_value || !user.Adjacent(src))
			return TRUE
		if(abs(input_value - power_multiplier) <= 0.05)
			// Correct!
			measured = TRUE
			to_chat(user, SPAN_NOTICE("Калибровка подтверждена:"))
			to_chat(user, SPAN_NOTICE("  Коэффициент биоконверсии: [round(power_multiplier, 0.01)]x"))
			to_chat(user, SPAN_NOTICE("  Источник: ксенофлоральная биоконверсия"))
			to_chat(user, SPAN_NOTICE("  Статус: СТАБИЛЬНЫЙ"))
			to_chat(user, SPAN_NOTICE("Данные записаны. Vey-Med ожидает отчёт."))
			visible_message(SPAN_NOTICE("[user] подтверждает калибровку [src]."))
			research_progress = 100
		else
			// Wrong — EMP!
			to_chat(user, SPAN_DANGER("ОШИБКА КАЛИБРОВКИ! Неверный коэффициент — электромагнитный выброс!"))
			visible_message(SPAN_DANGER("[src] испускает электромагнитный импульс!"))
			empulse(src, 1, 3)
		return TRUE

	// Block modular computer (research scanner)
	if(istype(tool, /obj/item/modular_computer))
		to_chat(user, SPAN_WARNING("Подключите кабель, измерьте мощность на проводе мультитулом и введите коэффициент биоконверсии."))
		return TRUE
	return ..()

// ============================================================
// ALIEN MISSION ARTIFACTS — subtype /obj/machinery/artifact
// Researched via xenoarch anomaly analyser on Sierra, not research scanner
// ============================================================

/obj/machinery/artifact/mission
	anchored = FALSE
	var/datum/derelict_mission/bound_mission
	var/deliverable_paper_type = /obj/item/paper/anomaly_scan/mission  // Subtype to produce when scanned

/obj/machinery/artifact/mission/New()
	..()
	derelict_mission_objects += src
	// Replace the random effects with mission-specific fixed ones
	QDEL_NULL(my_effect)
	QDEL_NULL(secondary_effect)
	setup_mission_effects()
	setup_destructibility()

/obj/machinery/artifact/mission/Destroy()
	derelict_mission_objects -= src
	return ..()

/// Override in subtypes to assign my_effect and secondary_effect
/obj/machinery/artifact/mission/proc/setup_mission_effects()
	return

/obj/machinery/artifact/mission/proc/ensure_bound_mission()
	if(!bound_mission)
		bound_mission = find_derelict_mission_for_artifact(src)
	return bound_mission

/// Called by artifact_analyser when scan of this object completes.
/// The analyser prints an anomaly_scan/mission report. Player must submit it to R&D console to advance objective.
/obj/machinery/artifact/mission/proc/on_analysis_complete()
	visible_message(SPAN_NOTICE("[src]: Анализ завершён. Подайте распечатанный отчёт в консоль НИО для засчёта контракта."))

// --- Alien artifact (miningstation / Grayson) ---
// EMP pulse + radiation aura. Responds to energy weapons.
/obj/machinery/artifact/mission/alien_artifact
	name = "unidentified alien artifact"
	desc = "A mysterious alien device discovered in an abandoned Grayson mining facility. Its surface pulses with electromagnetic interference. Bring it to the xenoarch analyzer for study."
	deliverable_paper_type = /obj/item/paper/anomaly_scan/mission/alien_artifact

/obj/machinery/artifact/mission/alien_artifact/New()
	..()
	icon_num = 9
	icon_state = "ano90"

/obj/machinery/artifact/mission/alien_artifact/setup_mission_effects()
	my_effect = new /datum/artifact_effect/emp(src)
	secondary_effect = new /datum/artifact_effect/radiate(src)

// --- Alien fragment (blueriver) ---
// Cold aura + pushback touch. Dangerous to approach without protection.
/obj/machinery/artifact/mission/alien_fragment
	name = "alien structural fragment"
	desc = "A large fragment of unknown alien construction material from an underground hive. It exudes pervasive cold and distorts nearby gravity. Bring it to the xenoarch analyzer for study."
	deliverable_paper_type = /obj/item/paper/anomaly_scan/mission/alien_fragment

/obj/machinery/artifact/mission/alien_fragment/New()
	..()
	icon_num = 7
	icon_state = "ano70"

/obj/machinery/artifact/mission/alien_fragment/setup_mission_effects()
	my_effect = new /datum/artifact_effect/cold(src)
	secondary_effect = new /datum/artifact_effect/pushback(src)

// ============================================================
// TACTICAL TERMINAL (slavers / Shellguard)
// Two-phase hack: ping wires with datajack → enter access code
// Access code found on a physical log spawned nearby (see slavers_base.dm)
// ============================================================


// --- Tactical terminal (portable item) ---
/obj/item/tactical_terminal
	name = "tactical operations terminal"
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "terminal"
	desc = "A hardened military-grade terminal. Encrypted with Shellguard security protocols. A datajack interface port is visible on the side."
	w_class = ITEM_SIZE_NO_CONTAINER

	var/hack_phase = 0          // 0=locked, 1=wires_exposed, 2=awaiting_code, 3=complete
	var/correct_wire = 0        // 1-6, randomized per round
	var/access_code = ""        // 4-char hex, printed on companion document
	var/list/wire_descs = list()// Per-position descriptions (correct wire gets data hint)

/obj/item/tactical_terminal/New()
	..()
	derelict_mission_objects += src
	var/a = rand(0, 0xFFFF)
	access_code = uppertext(pad_left(num2hex(a), 4, "0"))
	correct_wire = rand(1, 6)

	// Build wire descriptions: correct wire always gets the data-signature hint
	var/list/wrong_descs = list(
		"A thick wire carrying heavy electrical current.",
		"A secondary power distribution cable.",
		"A shielded antenna transceiver wire.",
		"A wire leading to the security alarm module.",
		"A thick grounding cable.",
		"A power routing wire with minor interference artifacts."
	)
	shuffle(wrong_descs)
	wire_descs = list("", "", "", "", "", "")
	var/wrong_idx = 1
	for(var/i = 1 to 6)
		if(i == correct_wire)
			wire_descs[i] = "A narrow-gauge wire with consistent high-frequency digital oscillations."
		else
			wire_descs[i] = wrong_descs[wrong_idx]
			wrong_idx++

/obj/item/tactical_terminal/Destroy()
	derelict_mission_objects -= src
	return ..()

/obj/item/tactical_terminal/examine(mob/user)
	. = ..()
	switch(hack_phase)
		if(0)
			to_chat(user, SPAN_WARNING("The terminal is locked. A datajack interface port is visible on the side."))
		if(1)
			to_chat(user, SPAN_NOTICE("The wire panel is exposed. Six wires are accessible."))
		if(2)
			to_chat(user, SPAN_NOTICE("Data port established. The terminal is awaiting an access code."))
		if(3)
			to_chat(user, SPAN_NOTICE("Terminal decrypted. Tactical data has been extracted."))

/obj/item/tactical_terminal/attack_self(mob/living/user)
	if(hack_phase == 3)
		to_chat(user, SPAN_NOTICE("The terminal is already decrypted."))
		return
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!terminal_user_has_datajack(H))
		to_chat(user, SPAN_WARNING("You need a datajack to interface with this terminal."))
		return
	if(hack_phase == 0)
		to_chat(user, SPAN_NOTICE("You connect your datajack to the terminal's maintenance port. The wire panel clicks open."))
		hack_phase = 1
	if(hack_phase == 1)
		terminal_open_wire_panel(user)
	else if(hack_phase == 2)
		terminal_prompt_code(user)

/obj/item/tactical_terminal/proc/terminal_user_has_datajack(mob/living/carbon/human/H)
	if(istype(H.l_hand, /obj/item/device/multitool/multimeter/datajack) || istype(H.r_hand, /obj/item/device/multitool/multimeter/datajack))
		return TRUE
	if(istype(H.back, /obj/item/rig))
		var/obj/item/rig/R = H.back
		if(R.suit_is_deployed())
			for(var/obj/item/rig_module/M in R.installed_modules)
				if(istype(M, /obj/item/rig_module/datajack) && M.active)
					return TRUE
	return FALSE

/obj/item/tactical_terminal/proc/terminal_open_wire_panel(mob/living/user)
	var/list/options = list()
	for(var/i = 1 to 6)
		options += "Wire [i]: [wire_descs[i]]"
	options += "Close panel"

	var/choice = input(user, "Six wires are exposed inside the terminal panel.\nPing a wire to locate the data port.", "Terminal Wire Panel") as null|anything in options
	if(!choice || choice == "Close panel")
		return

	var/wire_num = text2num(copytext(choice, 6, 7))
	if(!wire_num)
		return
	terminal_ping_wire(user, wire_num)

/obj/item/tactical_terminal/proc/terminal_ping_wire(mob/living/user, wire_num)
	if(hack_phase != 1)
		return
	to_chat(user, SPAN_NOTICE("You send a test signal through Wire [wire_num]..."))
	if(!do_after(user, 2 SECONDS, src))
		return
	if(wire_num == correct_wire)
		to_chat(user, SPAN_NOTICE("Wire [wire_num]: HIGH-FREQUENCY DIGITAL SIGNAL DETECTED. Data port established!"))
		visible_message(SPAN_NOTICE("[user] successfully locates the data port on [src]."))
		hack_phase = 2
		terminal_prompt_code(user)
	else
		var/desc_lower = lowertext(wire_descs[wire_num])
		if(findtext(desc_lower, "current") || findtext(desc_lower, "power"))
			to_chat(user, SPAN_DANGER("Wire [wire_num]: POWER FEED — you take a sharp shock!"))
			user.apply_damage(5, DAMAGE_BURN, "chest")
		else if(findtext(desc_lower, "security") || findtext(desc_lower, "alarm"))
			to_chat(user, SPAN_WARNING("Wire [wire_num]: Security circuit triggered!"))
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 80, FALSE)
			visible_message(SPAN_WARNING("[src] emits a piercing alarm tone!"))
			trigger_security_alarm()
		else
			to_chat(user, SPAN_NOTICE("Wire [wire_num]: No digital signal. Incorrect circuit."))

/obj/item/tactical_terminal/proc/trigger_security_alarm()
	// Lock nearby airlocks (7 tile radius)
	for(var/obj/machinery/door/airlock/A in range(7, src))
		if(!A.locked)
			A.lock(forced = 1)

/obj/item/tactical_terminal/proc/terminal_prompt_code(mob/living/user)
	if(hack_phase != 2)
		return
	var/code_input = input(user, "Data port active. Enter the 4-character access verification code.\n\n(Check nearby documents for the access code.)", "Terminal Interface — Code Entry") as text|null
	if(!code_input)
		return
	if(uppertext(trimtext(code_input)) == access_code)
		to_chat(user, SPAN_NOTICE("ACCESS GRANTED. Terminal decrypted. Extracting Shellguard tactical data..."))
		visible_message(SPAN_NOTICE("[src] beeps rapidly as [user] extracts the encrypted tactical data."))
		hack_phase = 3
		// Advance the Shellguard mission study_artifact objective
		for(var/datum/derelict_mission/M in derelict_missions_list)
			if(M.corporation_id != RND_MISSION_CORP_SHELLGUARD)
				continue
			if(M.state != RND_MISSION_STATE_AVAILABLE)
				continue
			var/datum/derelict_mission_objective/study = M.get_objective_by_type("study_artifact")
			if(study && !study.completed)
				study.advance()
			break
		// Spawn the deliverable data disk
		var/obj/item/derelict_mission_sample/shellguard_data/disk = new(get_turf(src))
		visible_message(SPAN_NOTICE("[src]: Tactical data extracted. Package [disk] and submit via drone pad."))
	else
		to_chat(user, SPAN_WARNING("ACCESS DENIED. Incorrect code."))

// ============================================================
// Deliverable items — produced by complex mission research steps
// Submitted through drone pad to finalize the mission
// ============================================================

// alien_artifact / alien_fragment — the anomaly analyser prints a mission-specific anomaly_scan subtype.
// Each artifact type produces its own unique report, preventing cross-mission abuse.
/obj/item/paper/anomaly_scan/mission
	name = "xenoarchaeological analysis report"
	desc = "A stamped analysis report from the anomaly analyser, documenting an unidentified alien artefact. Marked for corporate transmission — submit via drone pad."

/obj/item/paper/anomaly_scan/mission/New()
	..()
	derelict_mission_objects += src

/obj/item/paper/anomaly_scan/mission/Destroy()
	derelict_mission_objects -= src
	return ..()

/obj/item/paper/anomaly_scan/mission/alien_artifact
	name = "Grayson artifact analysis report"
	desc = "A stamped analysis report from the anomaly analyser documenting the unidentified alien device recovered from the Grayson mining station. Submit via drone pad."

/obj/item/paper/anomaly_scan/mission/alien_fragment
	name = "alien structure fragment analysis report"
	desc = "A stamped analysis report from the anomaly analyser documenting the alien structural fragment recovered from the Arctic Dwarf Planet. Submit via drone pad."

/obj/item/derelict_mission_sample/biocell_sample
	name = "xenofloral bio-organic sample"
	icon_state = "data-blue"
	desc = "A sealed vial containing a microscopic xenofloral sample extracted during output measurement. The organic matter continues to generate faint bioluminescence. Ready for Vey-Med delivery via drone pad."

/obj/item/derelict_mission_sample/shellguard_data
	name = "Shellguard operations disk"
	icon_state = "disk"
	desc = "A compact data disk extracted from the Shellguard tactical terminal, containing decrypted operational records and tactical positioning data. Ready for corporate delivery via drone pad."


// ============================================================
// Mission Sensor (deploy_sensor objective)
// ============================================================
/obj/item/device/mission_sensor
	name = "research sensor module"
	desc = "A portable sensor designed to collect environmental and structural data. Deploy it at a research site and wait for data collection."
	icon = 'icons/obj/modular_components.dmi'
	icon_state = "aislot"
	w_class = ITEM_SIZE_SMALL
	var/deployed = FALSE
	var/collecting = FALSE
	var/collection_complete = FALSE
	var/collection_time = 30 SECONDS
	var/datum/derelict_mission/bound_mission

/obj/item/device/mission_sensor/attack_self(mob/user)
	if(deployed)
		to_chat(user, SPAN_WARNING("The sensor has already been deployed."))
		return
	if(!isturf(user.loc))
		to_chat(user, SPAN_WARNING("You need to be standing on solid ground."))
		return

	to_chat(user, SPAN_NOTICE("You begin deploying [src]..."))
	if(!do_after(user, 3 SECONDS, src))
		return

	deployed = TRUE
	user.drop_from_inventory(src)
	anchored = TRUE

	// Find matching mission with deploy_sensor objective
	if(!bound_mission)
		for(var/datum/derelict_mission/M in derelict_missions_list)
			if(M.state != RND_MISSION_STATE_AVAILABLE)
				continue
			var/datum/derelict_mission_objective/sensor_obj = M.get_objective_by_type("deploy_sensor")
			if(sensor_obj && !sensor_obj.completed)
				bound_mission = M
				break

	to_chat(user, SPAN_NOTICE("[src] deployed. Data collection will take approximately [collection_time / 10] seconds."))
	start_collection()

/obj/item/device/mission_sensor/proc/start_collection()
	if(collecting || collection_complete)
		return
	collecting = TRUE
	addtimer(new Callback(src, PROC_REF(finish_collection)), collection_time)

/obj/item/device/mission_sensor/proc/finish_collection()
	collecting = FALSE
	collection_complete = TRUE
	visible_message(SPAN_NOTICE("[src] emits a confirmation tone. Data collection complete."))

	// Advance the deploy_sensor objective on the bound mission
	if(bound_mission)
		bound_mission.advance_objective("deploy_sensor")

/obj/item/device/mission_sensor/examine(mob/user)
	. = ..()
	if(!deployed)
		to_chat(user, SPAN_NOTICE("Ready to deploy. Use in hand to activate."))
	else if(collecting)
		to_chat(user, SPAN_NOTICE("Currently collecting data..."))
	else if(collection_complete)
		to_chat(user, SPAN_NOTICE("Data collection complete. Sensor can be retrieved."))
