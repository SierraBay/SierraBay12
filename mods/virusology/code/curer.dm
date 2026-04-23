// Vaccine Synthesizer - game phases
#define CURER_PHASE_IDLE         0
#define CURER_PHASE_READY        1
#define CURER_PHASE_GAME         2
#define CURER_PHASE_SYNTHESIZING 3
#define CURER_PHASE_COMPLETE     4
#define CURER_PHASE_FAILED       5

// Sub-phases within CURER_PHASE_GAME
#define CURER_SUBPHASE_REVEAL    0
#define CURER_SUBPHASE_PICK      1

#define CURER_MAX_INTEGRITY  3
#define CURER_GRID_SIZE      12
#define CURER_SYNTH_TICKS    5

/obj/machinery/computer/curer
	name = "vaccine synthesizer"
	desc = "A complex machine capable of analyzing viral pathogens and synthesizing targeted vaccines."
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	idle_power_usage = 500

	var/obj/item/virusdish/loaded_dish = null

	// Game state
	var/game_phase = CURER_PHASE_IDLE
	var/list/grid_cells = list()
	var/list/target_antigens = list()
	var/list/found_antigens = list()
	var/integrity = CURER_MAX_INTEGRITY
	var/hint_text = ""
	var/synthesis_ticks = 0

	// Round system
	var/current_round = 1
	var/max_rounds = 1

	// Reveal/pick sub-phases
	var/game_subphase = CURER_SUBPHASE_REVEAL
	var/reveal_timer = 0
	var/reveal_duration = 6    // ticks to show codes before hiding

	// Grid mutation
	var/mutation_timer = 0
	var/mutation_interval = 4  // ticks between mutations during pick phase
	var/mutation_flash = FALSE // TRUE for one tick when mutation happens

/obj/machinery/computer/curer/Destroy()
	if(loaded_dish)
		loaded_dish.dropInto(loc)
		loaded_dish = null
	. = ..()

/// Called first in use_tool. Override in mods to intercept specific item types.
/// Return TRUE if handled, FALSE to fall through to normal curer logic.
/obj/machinery/computer/curer/proc/mission_use_tool_hook(obj/item/I, mob/user)
	return FALSE

/// Called after vaccine synthesis completes, before the dish is destroyed.
/// Override in mods to react to successful synthesis (e.g. advance mission objectives).
/obj/machinery/computer/curer/proc/on_synthesis_complete(obj/item/virusdish/dish, obj/item/reagent_containers/vaccine)
	return

/obj/machinery/computer/curer/use_tool(obj/item/I, mob/user, list/click_params)
	if(mission_use_tool_hook(I, user))
		return

	if(istype(I, /obj/item/virusdish))
		if(loaded_dish)
			to_chat(user, SPAN_WARNING("A culture dish is already loaded."))
			return
		if(game_phase == CURER_PHASE_SYNTHESIZING)
			to_chat(user, SPAN_WARNING("The machine is busy synthesizing."))
			return
		var/obj/item/virusdish/dish = I
		if(!dish.virus2)
			to_chat(user, SPAN_WARNING("This dish contains no viable viral culture."))
			return
		if(!user.unEquip(I, src))
			return
		loaded_dish = dish
		game_phase = CURER_PHASE_READY
		to_chat(user, SPAN_NOTICE("You insert \the [dish] into \the [src]."))
		SSnano.update_uis(src)
		return

	return ..()

/obj/machinery/computer/curer/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/curer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	var/list/data = list()
	data["phase"] = game_phase
	data["integrity"] = integrity
	data["max_integrity"] = CURER_MAX_INTEGRITY
	data["has_dish"] = !!loaded_dish

	if(loaded_dish && loaded_dish.virus2)
		data["virus_name"] = loaded_dish.virus2.name()

	if(game_phase == CURER_PHASE_GAME)
		data["subphase"] = game_subphase
		data["hint"] = hint_text
		data["targets_total"] = LAZYLEN(target_antigens)
		data["targets_found"] = LAZYLEN(found_antigens)
		data["current_round"] = current_round
		data["max_rounds"] = max_rounds
		data["mutation_flash"] = mutation_flash
		var/list/grid_data = list()
		for(var/i = 1 to LAZYLEN(grid_cells))
			var/list/cell = grid_cells[i]
			var/display_code = cell["code"]
			// During pick phase, hide unrevealed cells
			if(game_subphase == CURER_SUBPHASE_PICK && cell["state"] == 0)
				display_code = "??"
			grid_data += list(list(
				"code" = display_code,
				"index" = cell["index"],
				"state" = cell["state"]
			))
		data["grid"] = grid_data

	if(game_phase == CURER_PHASE_SYNTHESIZING)
		data["synth_progress"] = CURER_SYNTH_TICKS - synthesis_ticks
		data["synth_max"] = CURER_SYNTH_TICKS

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-vaccine_synthesizer.tmpl", "Vaccine Synthesizer", 460, 520)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/curer/Process()
	if(stat & (MACHINE_STAT_NOPOWER|MACHINE_IS_BROKEN(src)))
		return

	if(game_phase == CURER_PHASE_SYNTHESIZING)
		synthesis_ticks--
		if(synthesis_ticks <= 0)
			complete_synthesis()
		SSnano.update_uis(src)

	if(game_phase == CURER_PHASE_GAME)
		// Clear mutation flash after one tick
		if(mutation_flash)
			mutation_flash = FALSE

		if(game_subphase == CURER_SUBPHASE_REVEAL)
			reveal_timer--
			if(reveal_timer <= 0)
				game_subphase = CURER_SUBPHASE_PICK
				mutation_timer = mutation_interval
			SSnano.update_uis(src)

		else if(game_subphase == CURER_SUBPHASE_PICK)
			// Grid mutation timer
			mutation_timer--
			if(mutation_timer <= 0)
				mutate_grid()
				mutation_timer = mutation_interval
				SSnano.update_uis(src)

/obj/machinery/computer/curer/OnTopic(mob/user, href_list)
	if(href_list["close"])
		SSnano.close_user_uis(user, src, "main")
		return TOPIC_HANDLED

	if(href_list["begin"])
		if(game_phase == CURER_PHASE_READY && loaded_dish && loaded_dish.virus2)
			start_game()
		return TOPIC_REFRESH

	if(href_list["pick"])
		if(game_phase != CURER_PHASE_GAME || game_subphase != CURER_SUBPHASE_PICK)
			return TOPIC_REFRESH
		var/idx = text2num(href_list["pick"])
		if(!idx || idx < 1 || idx > LAZYLEN(grid_cells))
			return TOPIC_REFRESH
		handle_pick(idx, user)
		return TOPIC_REFRESH

	if(href_list["retry"])
		if(game_phase == CURER_PHASE_FAILED)
			start_game()
		return TOPIC_REFRESH

	if(href_list["eject"])
		if(game_phase != CURER_PHASE_SYNTHESIZING)
			eject_dish()
		return TOPIC_REFRESH

	if(href_list["collect"])
		if(game_phase == CURER_PHASE_COMPLETE)
			reset_state()
		return TOPIC_REFRESH

	return TOPIC_NOACTION

// --- Game logic ---

/// Calculate difficulty based on virus properties.
/// Returns rounds count (1-3) and reveal duration.
/obj/machinery/computer/curer/proc/calculate_difficulty()
	if(!loaded_dish || !loaded_dish.virus2)
		max_rounds = 1
		reveal_duration = 6
		mutation_interval = 5
		return

	var/datum/disease2/disease/V = loaded_dish.virus2
	var/antigen_count = LAZYLEN(V.antigen)
	var/effect_count = LAZYLEN(V.effects)

	// Difficulty score: more antigens and effects = harder virus
	var/difficulty = antigen_count + round(effect_count / 2)

	if(difficulty <= 2)
		// Easy: 1 round, long reveal, slow mutations
		max_rounds = 1
		reveal_duration = 6
		mutation_interval = 5
	else if(difficulty <= 3)
		// Medium: 2 rounds, medium reveal, medium mutations
		max_rounds = 2
		reveal_duration = 5
		mutation_interval = 4
	else
		// Hard: 3 rounds, short reveal, fast mutations
		max_rounds = 3
		reveal_duration = 4
		mutation_interval = 3

/obj/machinery/computer/curer/proc/start_game()
	game_phase = CURER_PHASE_GAME
	integrity = CURER_MAX_INTEGRITY
	current_round = 1
	found_antigens = list()

	calculate_difficulty()

	var/list/virus_antigens = loaded_dish.virus2.antigen
	target_antigens = virus_antigens.Copy()
	start_round()
	state("\The [src] whirs as pathogen analysis begins.")

/obj/machinery/computer/curer/proc/start_round()
	game_subphase = CURER_SUBPHASE_REVEAL
	reveal_timer = reveal_duration
	mutation_flash = FALSE
	found_antigens = list()
	generate_grid()

/obj/machinery/computer/curer/proc/generate_grid()
	grid_cells = list()

	// Start with target antigens
	var/list/cell_codes = target_antigens.Copy()

	// Fill remaining slots with decoys
	var/list/decoy_pool = ALL_ANTIGENS.Copy()
	for(var/ag in target_antigens)
		decoy_pool -= ag

	while(LAZYLEN(cell_codes) < CURER_GRID_SIZE)
		if(!LAZYLEN(decoy_pool))
			break
		var/d = pick(decoy_pool)
		decoy_pool -= d
		cell_codes += d

	// Shuffle
	cell_codes = shuffle(cell_codes)

	for(var/i = 1 to LAZYLEN(cell_codes))
		grid_cells += list(list(
			"code" = cell_codes[i],
			"index" = i,
			"state" = 0
		))

	// Generate hint from first target antigen
	if(LAZYLEN(target_antigens))
		var/first = target_antigens[1]
		var/letter = copytext(first, 1, 2)
		hint_text = "Spectral analysis detects a marker in antigen group '[letter]'"
		if(LAZYLEN(target_antigens) > 1)
			var/second = target_antigens[2]
			var/letter2 = copytext(second, 1, 2)
			if(letter != letter2)
				hint_text += " and group '[letter2]'"

/// Swap two random unrevealed cells in the grid (mutation).
/obj/machinery/computer/curer/proc/mutate_grid()
	var/list/mutable = list()
	for(var/i = 1 to LAZYLEN(grid_cells))
		var/list/cell = grid_cells[i]
		if(cell["state"] == 0)  // Only unrevealed cells
			mutable += i

	if(LAZYLEN(mutable) < 2)
		return

	var/idx_a = pick(mutable)
	mutable -= idx_a
	var/idx_b = pick(mutable)

	// Swap codes between cells
	var/list/cell_a = grid_cells[idx_a]
	var/list/cell_b = grid_cells[idx_b]
	var/temp_code = cell_a["code"]
	cell_a["code"] = cell_b["code"]
	cell_b["code"] = temp_code

	mutation_flash = TRUE
	playsound(src.loc, 'sound/effects/pop.ogg', 15, TRUE)

/obj/machinery/computer/curer/proc/handle_pick(index, mob/user)
	if(index < 1 || index > LAZYLEN(grid_cells))
		return

	var/list/cell = grid_cells[index]
	if(cell["state"] != 0) // Already revealed
		return

	var/code = cell["code"]
	if(code in target_antigens)
		// Correct pick
		cell["state"] = 1
		found_antigens += code
		playsound(src.loc, 'sound/machines/ping.ogg', 30, TRUE)
		if(LAZYLEN(found_antigens) >= LAZYLEN(target_antigens))
			advance_round()
	else
		// Wrong pick
		cell["state"] = 2
		integrity--
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		if(integrity <= 0)
			game_phase = CURER_PHASE_FAILED
			state("\The [src] buzzes. Calibration failed - sample integrity lost.")

/obj/machinery/computer/curer/proc/advance_round()
	if(current_round >= max_rounds)
		begin_synthesis()
		return

	current_round++
	state("\The [src] chirps. Round [current_round] of [max_rounds] - recalibrating grid...")
	start_round()

/obj/machinery/computer/curer/proc/begin_synthesis()
	game_phase = CURER_PHASE_SYNTHESIZING
	synthesis_ticks = CURER_SYNTH_TICKS
	state("\The [src] hums as vaccine compound synthesis begins.")

/obj/machinery/computer/curer/proc/complete_synthesis()
	if(!loaded_dish || !loaded_dish.virus2)
		reset_state()
		return

	// Create vaccine beaker with antibodies matching the virus antigens
	var/obj/item/reagent_containers/glass/beaker/vaccine = new(src.loc)
	vaccine.name = "vaccine beaker ([loaded_dish.virus2.name()])"
	var/list/final_antigens = loaded_dish.virus2.antigen
	var/list/antibody_data = list("antibodies" = final_antigens.Copy())
	vaccine.reagents.add_reagent(/datum/reagent/antibodies, 30, antibody_data)

	state("\The [src] chimes. Vaccine synthesis complete! Collect the beaker.")

	// Notify mods before destroying the dish
	on_synthesis_complete(loaded_dish, vaccine)

	// Destroy the virus dish
	qdel(loaded_dish)
	loaded_dish = null

	game_phase = CURER_PHASE_COMPLETE

/obj/machinery/computer/curer/proc/eject_dish()
	if(loaded_dish)
		loaded_dish.dropInto(loc)
		loaded_dish = null
	reset_state()

/obj/machinery/computer/curer/proc/reset_state()
	game_phase = CURER_PHASE_IDLE
	game_subphase = CURER_SUBPHASE_REVEAL
	grid_cells = list()
	target_antigens = list()
	found_antigens = list()
	integrity = CURER_MAX_INTEGRITY
	hint_text = ""
	synthesis_ticks = 0
	current_round = 1
	max_rounds = 1
	reveal_timer = 0
	mutation_timer = 0
	mutation_flash = FALSE

#undef CURER_PHASE_IDLE
#undef CURER_PHASE_READY
#undef CURER_PHASE_GAME
#undef CURER_PHASE_SYNTHESIZING
#undef CURER_PHASE_COMPLETE
#undef CURER_PHASE_FAILED
#undef CURER_SUBPHASE_REVEAL
#undef CURER_SUBPHASE_PICK
#undef CURER_MAX_INTEGRITY
#undef CURER_GRID_SIZE
#undef CURER_SYNTH_TICKS
