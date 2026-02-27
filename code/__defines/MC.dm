#define TICK_CHECK ( world.tick_usage > Master.current_ticklimit )

#define CHECK_TICK if TICK_CHECK stoplag()

#define MC_TICK_CHECK ( ( world.tick_usage > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )


#define GAME_STATE 2 ** (Master.current_runlevel - 1)


#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count


#define MC_SPLIT_TICK \
	if(split_tick_phases > 1){\
		Master.current_ticklimit = ((original_tick_limit - world.tick_usage) / split_tick_phases) + world.tick_usage;\
		--split_tick_phases;\
	} else {\
		Master.current_ticklimit = original_tick_limit;\
	}


// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))

#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))

#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

#define MC_AVG_SLOW_UP_FAST_DOWN(average, current) (average < current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))


/****
* Subsystem helper macros
****/

/// Attempt to ensure that the subsystem is a singleton. Do not use directly.
#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover(varname);qdel(varname);}varname = src;}

/// Boilerplate for a new global subsystem object and its associated type.
#define SUBSYSTEM_DEF(X) var/global/datum/controller/subsystem/##X/SS##X;\
/datum/controller/subsystem/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/##X

#define TIMER_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/timer/##X);\
/datum/controller/subsystem/timer/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/timer/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/timer/##X

/// Boilerplate for a new global processing subsystem object and its associated type.
#define PROCESSING_SUBSYSTEM_DEF(X) var/global/datum/controller/subsystem/processing/##X/SS##X;\
/datum/controller/subsystem/processing/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/processing/##X/Recover() {\
	if(istype(SS##X.processing)) {\
		processing = SS##X.processing; \
	}\
}\
/datum/controller/subsystem/processing/##X

/// Register a datum to be processed with a processing subsystem.
#define START_PROCESSING(Processor, Datum) \
if (Datum.is_processing) {\
	if(Datum.is_processing != #Processor)\
	{\
		crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on [#Processor]."); \
	}\
} else {\
	Datum.is_processing = #Processor;\
	Processor.processing += Datum;\
}

/// Unregister a datum with a processing subsystem.
#define STOP_PROCESSING(Processor, Datum) \
if(Datum.is_processing) {\
	if(Processor.processing.Remove(Datum)) {\
		Datum.is_processing = null;\
	} else {\
		crash_with("Failed to stop processing. [log_info_line(Datum)] is being processed by [Datum.is_processing] but de-queue attempt occured on [#Processor]."); \
	}\
}

/// Register a datum to be processed with a named list on a subsystem.
#define START_PROCESSING_SUBSYSTEM_LIST(Subsystem, Datum, List, Label) \
if (Datum.is_processing) {\
	if(Datum.is_processing != Label)\
	{\
		crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on [Label]."); \
	}\
} else {\
	Datum.is_processing = Label;\
	Subsystem.List += Datum;\
}

/// Unregister a datum from a named list on a subsystem.
#define STOP_PROCESSING_SUBSYSTEM_LIST(Subsystem, Datum, List, Label) \
if(Datum.is_processing) {\
	if(Subsystem.List.Remove(Datum)) {\
		Datum.is_processing = null;\
	} else {\
		crash_with("Failed to stop processing. [log_info_line(Datum)] is being processed by [Datum.is_processing] and not found in [Label]"); \
	}\
}

/// START/STOP specific to atmospheric pipe networks.
#define START_PROCESSING_PIPENET(Datum) START_PROCESSING_SUBSYSTEM_LIST(SSpipenets, Datum, pipenets, "SSpipenets.pipenets")
#define STOP_PROCESSING_PIPENET(Datum) STOP_PROCESSING_SUBSYSTEM_LIST(SSpipenets, Datum, pipenets, "SSpipenets.pipenets")

/// START/STOP specific to power networks.
#define START_PROCESSING_POWERNET(Datum) START_PROCESSING_SUBSYSTEM_LIST(SSpowernets, Datum, powernets, "SSpowernets.powernets")
#define STOP_PROCESSING_POWERNET(Datum) STOP_PROCESSING_SUBSYSTEM_LIST(SSpowernets, Datum, powernets, "SSpowernets.powernets")

/// START/STOP specific to power-draining objects.
#define START_PROCESSING_POWER_OBJECT(Datum) START_PROCESSING_SUBSYSTEM_LIST(SSpowernets, Datum, power_objects, "SSpowernets.power_objects")
#define STOP_PROCESSING_POWER_OBJECT(Datum) STOP_PROCESSING_SUBSYSTEM_LIST(SSpowernets, Datum, power_objects, "SSpowernets.power_objects")

/// START specific to SSmachines
#define START_PROCESSING_MACHINE(machine, flag)\
	if(!istype(machine, /obj/machinery)) CRASH("A non-machine [log_info_line(machine)] was queued to process on the machinery subsystem.");\
	machine.processing_flags |= flag;\
	START_PROCESSING(SSmachines, machine)

/// STOP specific to SSmachines. Also handles machines registered via START_LAZY_PROCESSING_MACHINE.
#define STOP_PROCESSING_MACHINE(machine, flag)\
	machine.processing_flags &= ~flag;\
	if(machine.processing_flags == 0) {\
		if(machine.is_processing == "SSmachines_lazy") {\
			SSmachines.processing_lazy -= machine;\
			machine.is_processing = null;\
		} else {\
			STOP_PROCESSING(SSmachines, machine)\
		}\
	}

/// Queue machine for lazy (slow, ~N*2s) processing on SSmachines. Effective rate is processing_lazy_slice_n fires (~8s at default wait=2s).
/// Use for machines that don't need 2s granularity (cameras, status displays, passive dispensers, etc).
/// Cannot be combined with START_PROCESSING_MACHINE on the same machine without stopping lazy first.
#define START_LAZY_PROCESSING_MACHINE(machine)\
	if(!istype(machine, /obj/machinery)) CRASH("A non-machine [log_info_line(machine)] was queued for lazy processing on the machinery subsystem.");\
	if(!machine.is_processing) {\
		machine.is_processing = "SSmachines_lazy";\
		SSmachines.processing_lazy += machine;\
	}

/// Remove machine from lazy processing on SSmachines. Safe to call even if machine is not lazy-registered.
#define STOP_LAZY_PROCESSING_MACHINE(machine)\
	if(machine.is_processing == "SSmachines_lazy") {\
		SSmachines.processing_lazy -= machine;\
		machine.is_processing = null;\
	}


/****
* Subsystem Flags
****/

/// The subsystem's Initialize() will not be called.
#define SS_NO_INIT FLAG_01

/// The subsystem's fire() will not be called. This is preferable to can_fire = FALSE because it will not be added to the MC's list of active systems.
#define SS_NO_FIRE FLAG_02

/// The subsystem runs on spare CPU time, after all non-background subsystems have run that tick. Priority is considered against other SS_BACKGROUND subsystems.
#define SS_BACKGROUND FLAG_03

/// The subsystem does not tick check and should not run unless enough time can be guaranteed or it must to stay current.
#define SS_NO_TICK_CHECK FLAG_04

/// Treat the value of the subsystem's wait as ticks, not time. Forces it to run in the first tick. Implicitly has all runlevels. Ignores SS_BACKGROUND if set. Intended for systems that act like a mini-MC, like timers.
#define SS_TICKER FLAG_05

/// Attempt to keep the subsystem's timing real-world regular by adjusting fire timing to be earlier the later it previously ran.
#define SS_KEEP_TIMING FLAG_06

/// Calculate the subsystem's next fire time from when it finished, not when it started.
#define SS_POST_FIRE_TIMING FLAG_07

/// Run Shutdown() on server shutdown so the SS can finalize state.
#define SS_NEEDS_SHUTDOWN FLAG_08


/****
* Subsystem states
****/

/// The subsystem is not running.
#define SS_IDLE 0

/// The subsystem is queued to be run.
#define SS_QUEUED 1

/// The subsystem is currently being run.
#define SS_RUNNING 2

/// The subsystem's run is paused by MC_TICK_CHECK and will resume later.
#define SS_PAUSED 3

/// The subsystem is sleeping during its run.
#define SS_SLEEPING 4

/// The subsystem is in the process of being paused.
#define SS_PAUSING 5

/****
* Subsystem initialization states
****/

#define SS_INITSTATE_NONE 0

#define SS_INITSTATE_STARTED 1

#define SS_INITSTATE_DONE 2


/****
* SStimer
****/

#define addtimer(args...) _addtimer(args, source ="[__FILE__]#[__LINE__]")
