// Implements https://github.com/mafemergency/byond-tracy
// Client https://github.com/wolfpld/tracy


#ifdef PROFILE_FROM_BOOT
/world/New()
	profiler_init()
	return ..()
#endif


/client/proc/profiler_init_verb()
	set name = "Start Profiler"
	set category = "Debug"
	set desc = "Starts the tracy profiler, which will await the client connection."
	var/response = alert("Are you sure? The profiler will run until restart.", null, "No", "Yes")
	if (response != "Yes")
		return
	profiler_init()

/// Starts the profiler.
/proc/profiler_init()
	var/lib
	switch (world.system_type)
		if (MS_WINDOWS)
			lib = "tracy.dll"
		if (UNIX)
			lib = "tracy.so"
		else
			CRASH("Tracy initialization failed: unsupported platform or DLL not found.")
	var/init = CALL_EXT(lib, "init")()
	if(init != "0")
		CRASH("[lib] init error: [init]")
