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
// Place on cable node → secure with wrench → cell generates power into the network.
// Measure power on the wire with a multitool to deduce the bio-conversion coefficient.
// Use a PDA with research scanner installed on the cell to input the coefficient.
// Correct input (±0.05) → calibration report spawns. Wrong → EMP.
// Wrench again to disconnect.
// ============================================================

/obj/structure/derelict_mission_artifact/bio_cell
	name = "biological power cell prototype"
	icon_state = "biocell"
	desc = "Экспериментальная ксенофлоральная биоэнергетическая ячейка. Органические филаменты внутри пульсируют слабым биолюминесцентным свечением. Установите на кабельный узел, закрепите гаечным ключом, измерьте коэффициент биоконверсии мультитулом и подтвердите данные сканнером КПК."
	density = TRUE
	anchored = FALSE

	var/power_gen = 30000             // Base power output in watts
	var/power_multiplier = 0          // 1.20 - 2.00, randomized at spawn
	var/calibrated = FALSE            // TRUE after correct coefficient input
	var/obj/structure/cable/connected_cable = null

/obj/structure/derelict_mission_artifact/bio_cell/New()
	..()
	power_multiplier = 1.2 + (rand(0, 80) / 100.0)

/obj/structure/derelict_mission_artifact/bio_cell/Destroy()
	if(anchored && connected_cable)
		STOP_PROCESSING(SSobj, src)
		connected_cable = null
	return ..()

/obj/structure/derelict_mission_artifact/bio_cell/Process()
	if(!connected_cable || !connected_cable.powernet)
		connected_cable = null
		anchored = FALSE
		STOP_PROCESSING(SSobj, src)
		return
	connected_cable.powernet.avail += power_gen * power_multiplier

/obj/structure/derelict_mission_artifact/bio_cell/examine(mob/user)
	. = ..()
	if(!anchored)
		to_chat(user, SPAN_NOTICE("Ячейка отключена. Установите её на кабельный узел и закрепите гаечным ключом."))
	else if(!calibrated)
		to_chat(user, SPAN_NOTICE("Ячейка активна. Мощность в сеть: [round(power_gen * power_multiplier / 1000, 0.1)] кВт. Требуется калибровка — измерьте коэффициент мультитулом и введите его через КПК со сканером."))
	else
		to_chat(user, SPAN_NOTICE("Ячейка активна и откалибрована. Мощность в сеть: [round(power_gen * power_multiplier / 1000, 0.1)] кВт."))

/obj/structure/derelict_mission_artifact/bio_cell/use_tool(obj/item/tool, mob/living/user, list/click_params)
	// Wrench — connect to cable node or disconnect
	if(istype(tool, /obj/item/wrench))
		if(anchored)
			to_chat(user, SPAN_NOTICE("Вы откручиваете [src] от кабельного узла..."))
			if(!do_after(user, 2 SECONDS, src))
				return TRUE
			anchored = FALSE
			connected_cable = null
			STOP_PROCESSING(SSobj, src)
			icon_state = "biocell"
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, SPAN_NOTICE("Ячейка отключена от сети."))
			visible_message(SPAN_NOTICE("[src] тускнеет, когда [user] откручивает её."))
		else
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(!C)
				to_chat(user, SPAN_WARNING("Нет кабельного узла. Проложите кабель с точкой соединения (узлом) под ячейкой."))
				return TRUE
			if(!C.powernet)
				to_chat(user, SPAN_WARNING("Кабельный узел не подключён к сети. Подсоедините провод к источнику питания."))
				return TRUE
			to_chat(user, SPAN_NOTICE("Вы закручиваете [src] на кабельный узел..."))
			if(!do_after(user, 2 SECONDS, src))
				return TRUE
			anchored = TRUE
			connected_cable = C
			icon_state = "biocell_active"
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, SPAN_NOTICE("Ячейка закреплена. Мощность в сеть: [round(power_gen * power_multiplier / 1000, 0.1)] кВт. Введите коэффициент биоконверсии через КПК со сканером."))
			visible_message(SPAN_NOTICE("[src] ярко пульсирует, когда [user] закрепляет её на кабеле."))
			START_PROCESSING(SSobj, src)
		return TRUE

	// PDA with research scanner — calibration input
	if(istype(tool, /obj/item/modular_computer))
		var/obj/item/modular_computer/pda = tool
		if(!istype(pda.scanner, /obj/item/stock_parts/computer/scanner/research))
			to_chat(user, SPAN_WARNING("Для калибровки требуется КПК с установленным модулем полевого сканера."))
			return TRUE
		if(!anchored)
			to_chat(user, SPAN_WARNING("Ячейка не подключена к сети. Сначала закрепите её на кабельном узле."))
			return TRUE
		if(calibrated)
			to_chat(user, SPAN_NOTICE("Ячейка уже откалибрована. Коэффициент биоконверсии: [round(power_multiplier, 0.01)]x."))
			return TRUE
		var/input_value = input(user, "Введите измеренный коэффициент биоконверсии:", "Биоячейка — Калибровка") as null|num
		if(!input_value || !user.Adjacent(src))
			return TRUE
		if(abs(input_value - power_multiplier) <= 0.05)
			calibrated = TRUE
			research_progress = 100
			to_chat(user, SPAN_NOTICE("Калибровка подтверждена. Коэффициент биоконверсии: [round(power_multiplier, 0.01)]x. Источник: ксенофлоральная биоконверсия."))
			visible_message(SPAN_NOTICE("[user] завершает калибровку [src]."))
			// Spawn the deliverable sample required by the mission (target_item_type = biocell_sample)
			new /obj/item/derelict_mission_sample/biocell_sample(get_turf(src))
		else
			to_chat(user, SPAN_DANGER("ОШИБКА КАЛИБРОВКИ! Неверный коэффициент — электромагнитный выброс!"))
			visible_message(SPAN_DANGER("[src] испускает электромагнитный импульс!"))
			empulse(src, 1, 3)
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
// TACTICAL TERMINAL WIRES (standard /datum/wires integration)
// ============================================================

var/global/const/TACTICAL_WIRE_DATA = 1
var/global/const/TACTICAL_WIRE_POWER = 2
var/global/const/TACTICAL_WIRE_SECURITY = 4
var/global/const/TACTICAL_WIRE_GROUND = 8
var/global/const/TACTICAL_WIRE_ANTENNA = 16
var/global/const/TACTICAL_WIRE_AUX = 32

/datum/wires/tactical_terminal
	holder_type = /obj/item/tactical_terminal
	random = 1
	wire_count = 6
	descriptions = list(
		new /datum/wire_description(TACTICAL_WIRE_DATA, "A narrow-gauge wire with consistent high-frequency digital oscillations.", "Data Port", SKILL_EXPERIENCED),
		new /datum/wire_description(TACTICAL_WIRE_POWER, "A thick wire carrying heavy electrical current.", "Power Feed", SKILL_TRAINED),
		new /datum/wire_description(TACTICAL_WIRE_SECURITY, "A wire leading to the security alarm module.", "Security", SKILL_TRAINED),
		new /datum/wire_description(TACTICAL_WIRE_GROUND, "A thick grounding cable.", "Ground"),
		new /datum/wire_description(TACTICAL_WIRE_ANTENNA, "A shielded antenna transceiver wire.", "Antenna"),
		new /datum/wire_description(TACTICAL_WIRE_AUX, "A power routing wire with minor interference artifacts.", "Auxiliary")
	)

/datum/wires/tactical_terminal/CanUse(mob/living/L)
	var/obj/item/tactical_terminal/T = holder
	if(T.hack_phase != 1)
		return FALSE
	return TRUE

/datum/wires/tactical_terminal/GetInteractWindow(mob/user)
	. = ..()
	if(.)
		. += "<br><i>Locate the data port by pulsing the correct wire.</i>"

/datum/wires/tactical_terminal/UpdatePulsed(index)
	var/obj/item/tactical_terminal/T = holder
	if(T.hack_phase != 1)
		return
	switch(index)
		if(TACTICAL_WIRE_DATA)
			to_chat(usr, SPAN_NOTICE("HIGH-FREQUENCY DIGITAL SIGNAL DETECTED. Data port established!"))
			T.visible_message(SPAN_NOTICE("[usr] successfully locates the data port on [T]."))
			T.hack_phase = 2
			close_browser(usr, "window=wires")
		if(TACTICAL_WIRE_POWER)
			to_chat(usr, SPAN_DANGER("POWER FEED — you take a sharp shock!"))
			if(isliving(usr))
				var/mob/living/L = usr
				L.apply_damage(5, DAMAGE_BURN, "chest")
		if(TACTICAL_WIRE_SECURITY)
			to_chat(usr, SPAN_WARNING("Security circuit triggered!"))
			playsound(get_turf(T), 'sound/machines/buzz-two.ogg', 80, FALSE)
			T.visible_message(SPAN_WARNING("[T] emits a piercing alarm tone!"))
			T.trigger_security_alarm()
		else
			to_chat(usr, SPAN_NOTICE("No digital signal detected. Incorrect circuit."))

/datum/wires/tactical_terminal/UpdateCut(index, mended)
	switch(index)
		if(TACTICAL_WIRE_DATA)
			if(!mended)
				to_chat(usr, SPAN_WARNING("The data port wire goes dead. You can mend it to restore it."))
		if(TACTICAL_WIRE_SECURITY)
			if(!mended)
				to_chat(usr, SPAN_NOTICE("The security alarm circuit is disabled."))

// ============================================================
// TACTICAL TERMINAL (slavers / Shellguard)
// Hack: use datajack on terminal → wire panel → find data wire → enter access code
// Access code found on a physical log spawned nearby (see slavers_base.dm)
// ============================================================

/obj/item/tactical_terminal
	name = "tactical operations terminal"
	icon = 'mods/RnD/icons/derelict_mission.dmi'
	icon_state = "terminal"
	desc = "A hardened military-grade terminal. Encrypted with Shellguard security protocols. A datajack interface port is visible on the side."
	w_class = ITEM_SIZE_NO_CONTAINER

	var/hack_phase = 0          // 0=locked, 1=wires_exposed, 2=awaiting_code, 3=complete
	var/access_code = ""        // 4-char hex, printed on companion document
	var/datum/wires/tactical_terminal/wires

/obj/item/tactical_terminal/New()
	..()
	derelict_mission_objects += src
	var/a = rand(0, 0xFFFF)
	access_code = uppertext(pad_left(num2hex(a), 4, "0"))
	wires = new(src)

/obj/item/tactical_terminal/Destroy()
	derelict_mission_objects -= src
	QDEL_NULL(wires)
	return ..()

/obj/item/tactical_terminal/examine(mob/user)
	. = ..()
	switch(hack_phase)
		if(0)
			to_chat(user, SPAN_WARNING("The terminal is locked. A datajack interface port is visible on the side."))
		if(1)
			to_chat(user, SPAN_NOTICE("The wire panel is exposed. Use a datajack to interact with the wires."))
		if(2)
			to_chat(user, SPAN_NOTICE("Data port established. Use a datajack on the terminal to enter the access code."))
		if(3)
			to_chat(user, SPAN_NOTICE("Terminal decrypted. Tactical data has been extracted."))

/obj/item/tactical_terminal/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/device/multitool/multimeter/datajack))
		terminal_interact(user)
		return TRUE
	if(isWirecutter(W) && hack_phase == 1)
		wires.Interact(user)
		return TRUE
	. = ..()

/obj/item/tactical_terminal/attack_self(mob/living/user)
	if(hack_phase == 3)
		to_chat(user, SPAN_NOTICE("The terminal is already decrypted."))
		return
	if(hack_phase == 2)
		// Code entry works from hand — just need datajack somewhere
		if(!istype(user, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = user
		if(terminal_user_has_datajack(H))
			terminal_prompt_code(user)
		else
			to_chat(user, SPAN_WARNING("You need a datajack to enter the access code."))
		return
	// Phases 0-1: wire panel needs datajack in active hand clicking ON the terminal
	to_chat(user, SPAN_NOTICE("Place the terminal on a surface and use your datajack on it to access the wire panel."))

/obj/item/tactical_terminal/proc/terminal_interact(mob/living/user)
	if(hack_phase == 3)
		to_chat(user, SPAN_NOTICE("The terminal is already decrypted."))
		return
	if(hack_phase == 0)
		to_chat(user, SPAN_NOTICE("You connect your datajack to the terminal's maintenance port. The wire panel clicks open."))
		hack_phase = 1
	if(hack_phase == 1)
		wires.Interact(user)
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

/obj/item/tactical_terminal/proc/trigger_security_alarm()
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
