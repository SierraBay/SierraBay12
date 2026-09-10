#if !defined(using_map_DATUM)

	#include "blank.dmm"
	#include "../away/empty.dmm"

	// Torch/SolGov clothing & related code (same snatch as Sierra; required by Sentinel/Phobos/Hand)
	#include "../sierra/sierra_snatch.dm"
	#include "../sierra/machinery/suit_storage.dm"
	#include "lobby_host_ranks.dm"
	#include "lobby_host_modes.dm"

	#include "../../mods/screentips/_screentips_includes.dm"

	#include "../../packs/factions/iccgn/_pack.dm"
	#include "../../packs/factions/scga/_pack.dm"
	#include "../../packs/factions/scgf/_pack.dm"
	#include "../../packs/infinity/_pack.dm"
	#include "../../packs/deepmaint/_pack.dm"

	#include "../../mods/antagonists/_antagonists_includes.dm"
	#include "../../mods/ascent/_ascent_includes.dm"
	#include "../../mods/fancy_sofas/_fancy_sofas_includes.dm"
	#include "../../mods/jukebox_tapes/_jukebox_tapes_includes.dm"
	#include "../../mods/legalese_language/_legalese_includes.dm"
	#include "../../mods/resomi/_resomi_includes.dm"
	#include "../../mods/tajara/_tajara_includes.dm"
	#include "../../mods/sauna_props/_sauna_props_includes.dm"
	#include "../../mods/telecomms/_telecomms_includes.dm"
	#include "../../mods/modernUI/_modernUI_includes.dm"
	#include "../../mods/vr/_vr_includes.dm"

	// Away site code (areas/templates) — needed by global mods like RnD; DMM still loads at runtime
	#include "../away/mining/mining.dm"
	#include "../away/derelict/derelict.dm"
	#include "../away/lost_supply_base/lost_supply_base.dm"
	#include "../away/smugglers/smugglers.dm"
	#include "../away/magshield/magshield.dm"
	#include "../away/casino/casino.dm"
	#include "../away/yacht/yacht.dm"
	#include "../away/blueriver/blueriver.dm"
	#include "../away/slavers/slavers_base.dm"
	#include "../away/mobius_rift/mobius_rift.dm"
	#include "../away/errant_pisces/errant_pisces.dm"
	#include "../away/lar_maria/lar_maria.dm"
	#include "../away/voxship/voxship.dm"
	#include "../away/skrellscoutship/skrellscoutship.dm"
	#include "../away/meatstation/meatstation.dm"
	#include "../away/miningstation/miningstation.dm"
	#include "../away/mininghome/mininghome.dm"
	#include "../../mods/_maps/scavver/scavver_gantry.dm"
	#include "../away/abandoned_hotel/abandoned_hotel.dm"
	#include "../away/spy_station/spy_station.dm"
	#include "../away/salvage_shuttle/salvage_shuttle.dm"
	#include "../event/iccgn_ship/icgnv_hound.dm"
	#include "../event/sfv_arbiter/sfv_arbiter.dm"
	#include "../event/placeholders/placeholders.dm"
	#include "../event/empty/empty.dm"
	#include "../bluespace_interlude/bluespace_interlude.dm"
	#include "../bluespace_interlude/bluespace_interlude.dmm"

	// Playable ships + remaining map packs (code only; DMM loads at runtime / vote)
	#include "../../mods/_maps/bearcat_revived/_map_bearcat_revived.dme"
	#include "../../mods/_maps/liberia/_map_liberia.dme"
	#include "../../mods/_maps/sentinel/_map_sentinel.dme"
	#include "../../mods/_maps/farfleet/_map_farfleet.dme"
	#include "../../mods/_maps/general_maps/_map_general_maps.dme"
	#include "../../mods/_maps/hand/_map_hand.dme"
	#include "../../mods/_maps/insidiae_pack/_map_insidiae_pack.dme"
	#include "../../mods/_maps/voxship/_map_voxship.dme"
	#include "../../mods/_maps/verne/_map_verne.dme"
	#include "../../mods/_maps/mininghome/_map_mininghome.dme"
	#include "../../mods/_maps/ascent_seedship/_map_ascent_seedship.dme"
	#include "../../mods/_maps/ascent_caulship/_map_ascent_caulship.dme"
	#include "../../mods/_maps/phobos/_map_phobos.dme"

	#define using_map_DATUM /datum/map/lobby_host

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Lobby Host

#endif
