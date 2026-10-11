// Enable only in an isolated validation build, never in a game server build.
#ifdef TGUI_HEADLESS_TESTS
/world/New()
	SetupLogs()
	SSassets.load_assets()
	var/list/tests = list(/datum/unit_test/tgui_lifecycle, /datum/unit_test/tgui_inputs, /datum/unit_test/tgui_message, /datum/unit_test/tgui_assets, /datum/unit_test/tgui_nanoui)
	for(var/test_type in tests)
		var/datum/unit_test/test = new test_type
		test.test_start_time = uptime()
		try
			test.start_test()
		catch(var/exception/error)
			test.fail("Exception: [error]")
		if(!test.reported)
			test.fail("Test did not report a result.")
		qdel(test)
	var/result = "TGUI tests: [failed_unit_tests] failures; [GLOB.total_runtimes] runtime errors."
	to_world_log(result)
	text2file(result, "tgui-results.txt")
#endif
