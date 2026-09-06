// SSao and SSlighting exhaust BYOND's 32-bit heap across 68+ Z-levels loaded by this test.
// This file is only compiled for the away_sites_testing build, so these overrides
// do not affect normal gameplay.
/datum/controller/subsystem/ao/fire(resume, no_mc_tick)
	return

/datum/controller/subsystem/lighting/fire(resumed, no_mc_tick)
	return

/datum/map/away_sites_testing
	lobby_tracks = list(/singleton/audio/track/absconditus)
