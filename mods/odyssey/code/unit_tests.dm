/datum/unit_test/odyssey_sector_graph
	name = "ODYSSEY: Sector graph is deterministic and spans 3-5 shifts"


/datum/unit_test/odyssey_sector_graph/start_test()
	var/list/first = odyssey_generate_sector_graph("unit-test-seed")
	var/list/second = odyssey_generate_sector_graph("unit-test-seed")
	var/list/errors = odyssey_validate_graph(first)
	if (length(errors))
		fail("Generated graph is invalid: [json_encode(errors)]")
		return 1
	if (json_encode(first) != json_encode(second))
		fail("Sector graph is not deterministic for a stable seed.")
		return 1
	var/list/start_links = first[ODYSSEY_SECTOR_START]["links"]
	if (!islist(start_links) || length(start_links) < 2)
		fail("Start sector must branch into multiple routes.")
		return 1
	var/list/terminal_depths = list()
	var/cross_links = 0
	for (var/id in first)
		var/list/node = first[id]
		if (node["terminal"])
			terminal_depths |= node["depth"]
		var/list/links = node["links"]
		if (islist(links) && length(links) > 1)
			cross_links += 1
	if (cross_links < 3)
		fail("Expected multiple branching nodes, got [cross_links].")
		return 1
	for (var/depth in list(3, 4, 5))
		if (!(depth in terminal_depths))
			fail("No terminal route at shift [depth].")
			return 1
	var/list/other = odyssey_generate_sector_graph("other-unit-test-seed")
	var/same_layout = TRUE
	for (var/id in first)
		var/list/a = first[id]
		var/list/b = other[id]
		if (!islist(a) || !isnum(a["x"]) || !isnum(a["y"]))
			fail("Sector [id] missing generated map coordinates.")
			return 1
		if (islist(b) && (a["x"] != b["x"] || a["y"] != b["y"]))
			same_layout = FALSE
	if (same_layout)
		fail("Different seeds produced identical map layouts.")
		return 1
	pass("Graph is valid, deterministic, branching, laid out, and has terminal routes at shifts 3, 4 and 5.")
	return 1
