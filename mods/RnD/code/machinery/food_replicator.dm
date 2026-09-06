// Food Replicator
// Works like a standard fabricator but only prints food designs (FOOD_REPLICATOR build_type).
// Requires a beaker of nutriment reagent. Responds to voice commands: "menu", "status".
// Designs are stored on disks like any other fabricator.

/obj/machinery/fabricator/food_replicator
	name = "food replicator"
	desc = "A versatile machine that synthesises nourishing food from raw nutriment. Responds to voice commands like 'menu' and 'status'."
	icon = 'icons/obj/machines/fabricators/replicator.dmi'
	icon_state = "replicator"
	base_icon_state = "replicator"

	build_type = FOOD_REPLICATOR

	have_disk = TRUE
	have_disk2 = FALSE
	have_reagents = TRUE
	have_materials = FALSE
	have_recycling = FALSE

	base_type = /obj/machinery/fabricator/food_replicator

// Override design_list so built-in food designs are always available without a disk.
// Reads directly from SSresearch.all_designs (initialized before any player interaction).
/obj/machinery/fabricator/food_replicator/design_list()
	if(disk)
		return disk.find_files_by_type(/datum/computer_file/binary/design)

	var/list/result = list()
	for(var/datum/design/food/D in SSresearch.all_designs)
		if(D.file)
			result += D.file
	return result

/obj/machinery/fabricator/food_replicator/hear_talk(mob/M, text, verb, datum/language/speaking)
	if(speaking && !speaking.machine_understands)
		return ..()
	var/true_text = lowertext(html_decode(text))
	if(findtext(true_text, "status"))
		addtimer(new Callback(src, PROC_REF(state_status)), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	else if(findtext(true_text, "menu"))
		addtimer(new Callback(src, PROC_REF(state_menu)), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	else
		// Try to match a recipe name and queue it
		for(var/datum/computer_file/binary/design/F in design_list())
			if(!F.design)
				continue
			if(findtext(true_text, lowertext(F.design.name)))
				var/datum/computer_file/binary/design/FC = F.clone()
				addtimer(new Callback(src, TYPE_PROC_REF(/obj/machinery/fabricator, queue_design), FC, 1), 2 SECONDS)
				break
	..()

/obj/machinery/fabricator/food_replicator/proc/state_status()
	if(!container || !container.reagents)
		audible_message("<b>\The [src]</b> states, \"Nutriment storage: empty.\"")
		return
	var/amt = round(container.reagents.get_reagent_amount(/datum/reagent/nutriment), 0.1)
	var/max_amt = container.reagents.maximum_volume
	audible_message("<b>\The [src]</b> states, \"Nutriment storage at [round(amt / max_amt * 100)]% ([amt]/[max_amt] units).\"")

/obj/machinery/fabricator/food_replicator/proc/state_menu()
	var/list/menu = list()
	for(var/datum/computer_file/binary/design/F in design_list())
		if(F.design)
			menu += F.design.name
	if(length(menu))
		audible_message("<b>\The [src]</b> states, \"Greetings! I serve the following dishes: [english_list(menu)].\"")
	else
		audible_message("<b>\The [src]</b> states, \"Apologies! I cannot serve any dishes at the moment.\"")

// Circuit board for construction via machine frame
/obj/item/stock_parts/circuitboard/food_replicator
	name = "circuit board (food replicator)"
	build_path = /obj/machinery/fabricator/food_replicator
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
	)
