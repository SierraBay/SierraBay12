#if !defined(using_map_DATUM)

	// --- MAP MAINTENANCE --- //
	#include "dev_setup.dm"
	#include "dev_turfs.dm"

	//Всякая байда для совместимости с модом и прочим
	#include "../../../../maps/sierra/sierra_npcs.dm"
	#include "../../../../maps/sierra/sierra_presets.dm"
	#include "../../../../maps/sierra/sierra_snatch.dm"
	#include "../../../../maps/sierra/datums/uniforms.dm"
	#include "../../../../maps/sierra/datums/uniforms_civilian.dm"
	#include "../../../../maps/sierra/datums/uniforms_contractor.dm"
	#include "../../../../maps/sierra/datums/uniforms_employee.dm"
	#include "../../../../maps/sierra/datums/reports/command.dm"
	#include "../../../../maps/sierra/datums/reports/deck.dm"
	#include "../../../../maps/sierra/datums/reports/engineering.dm"
	#include "../../../../maps/sierra/datums/reports/exploration.dm"
	#include "../../../../maps/sierra/datums/reports/general.dm"
	#include "../../../../maps/sierra/datums/reports/iaa.dm"
	#include "../../../../maps/sierra/datums/reports/medical.dm"
	#include "../../../../maps/sierra/datums/reports/security.dm"
	#include "../../../../maps/sierra/datums/reports/science.dm"
	#include "../../../../maps/sierra/datums/shackle_law_sets.dm"
	#include "../../../../maps/sierra/datums/supplypacks/engineering.dm"
	#include "../../../../maps/sierra/datums/supplypacks/security.dm"
	#include "../../../../maps/sierra/datums/supplypacks/science.dm"
	#include "../../../../maps/sierra/datums/species/species_overrides.dm"
	#include "../../../../maps/sierra/game/languages.dm"
	#include "../../../../maps/sierra/game/lockdown.dm"
	// --- ITEMS --- //
	#include "../../../../maps/sierra/items/ammo.dm"
	#include "../../../../maps/sierra/items/cards_ids.dm"
	#include "../../../../maps/sierra/items/documents.dm"
	#include "../../../../maps/sierra/items/encryption_keys.dm"
	#include "../../../../maps/sierra/items/explo_shotgun.dm"
	#include "../../../../maps/sierra/items/guns.dm"
	#include "../../../../maps/sierra/items/headsets.dm"
	#include "../../../../maps/sierra/items/items.dm"
	#include "../../../../maps/sierra/items/lighting.dm"
	#include "../../../../maps/sierra/items/machinery.dm"
	#include "../../../../maps/sierra/items/modular_computer.dm"
	#include "../../../../maps/sierra/items/manuals.dm"
	#include "../../../../maps/sierra/items/mech.dm"
	#include "../../../../maps/sierra/items/papers.dm"
	#include "../../../../maps/sierra/items/rigs.dm"
	#include "../../../../maps/sierra/items/stamps.dm"
	#include "../../../../maps/sierra/items/pouches.dm"
	#include "../../../../maps/sierra/items/backpack.dm"
	#include "../../../../maps/sierra/items/cargo.dm"
	#include "../../../../maps/sierra/items/snacks.dm"
	#include "../../../../maps/sierra/items/recipes_microwave.dm"
	#include "../../../../maps/sierra/items/weapons/storage/firstaids.dm"
	#include "../../../../maps/sierra/items/datajack.dm"
	#include "../../../../maps/sierra/items/clothing/clothing.dm"
	#include "../../../../maps/sierra/items/clothing/exploration.dm"
	#include "../../../../maps/sierra/items/clothing/override.dm"
	#include "../../../../maps/sierra/items/clothing/storages.dm"
	#include "../../../../maps/sierra/items/clothing/security.dm"
	// --- JOB SECTION --- //
	#include "../../../../maps/sierra/job/_job_defines.dm"
	#include "../../../../maps/sierra/job/access.dm"
	#include "../../../../maps/sierra/job/jobs.dm"
	#include "../../../../maps/sierra/job/outfits.dm"
	#include "../../../../maps/sierra/job/infinity.dm"
	#include "../../../../maps/sierra/job/jobs_cargo.dm"
	#include "../../../../maps/sierra/job/jobs_command.dm"
	#include "../../../../maps/sierra/job/jobs_engineering.dm"
	#include "../../../../maps/sierra/job/jobs_exploration.dm"
	#include "../../../../maps/sierra/job/jobs_medical.dm"
	#include "../../../../maps/sierra/job/jobs_misc.dm"
	#include "../../../../maps/sierra/job/jobs_research.dm"
	#include "../../../../maps/sierra/job/jobs_security.dm"
	#include "../../../../maps/sierra/job/jobs_service.dm"
//Машины
	#include "../../../../maps/sierra/machinery/alarm.dm"
	#include "../../../../maps/sierra/machinery/doors.dm"
	#include "../../../../maps/sierra/machinery/keycard authentication.dm"
	#include "../../../../maps/sierra/machinery/machinery.dm"
	#include "../../../../maps/sierra/machinery/navbeacons.dm"
	#include "../../../../maps/sierra/machinery/power.dm"
	#include "../../../../maps/sierra/machinery/random.dm"
	#include "../../../../maps/sierra/machinery/suit_storage.dm"
	#include "../../../../maps/sierra/machinery/tcomms.dm"
	#include "../../../../maps/sierra/machinery/thrusters.dm"
	#include "../../../../maps/sierra/machinery/uniform_vendor.dm"
	#include "../../../../maps/sierra/machinery/vendors.dm"
//Структуры
	#include "../../../../maps/sierra/structures/closets.dm"
	#include "../../../../maps/sierra/structures/other.dm"
	#include "../../../../maps/sierra/structures/signs.dm"
	#include "../../../../maps/sierra/structures/closets/_closets_appearances.dm"
	#include "../../../../maps/sierra/structures/closets/armory.dm"
	#include "../../../../maps/sierra/structures/closets/command.dm"
	#include "../../../../maps/sierra/structures/closets/engineering.dm"
	#include "../../../../maps/sierra/structures/closets/exploration.dm"
	#include "../../../../maps/sierra/structures/closets/medical.dm"
	#include "../../../../maps/sierra/structures/closets/misc.dm"
	#include "../../../../maps/sierra/structures/closets/research.dm"
	#include "../../../../maps/sierra/structures/closets/security.dm"
	#include "../../../../maps/sierra/structures/closets/services.dm"
	#include "../../../../maps/sierra/structures/closets/supply.dm"
//Лодаут
	#include "../../../../maps/sierra/loadout/_defines.dm"
	#include "../../../../maps/sierra/loadout/loadout.dm"
	#include "../../../../maps/sierra/loadout/loadout_accessories.dm"
	#include "../../../../maps/sierra/loadout/loadout_ec_skillbages.dm"
	#include "../../../../maps/sierra/loadout/loadout_eyes.dm"
	#include "../../../../maps/sierra/loadout/loadout_gloves.dm"
	#include "../../../../maps/sierra/loadout/loadout_head.dm"
	#include "../../../../maps/sierra/loadout/loadout_pda.dm"
	#include "../../../../maps/sierra/loadout/loadout_shoes.dm"
	#include "../../../../maps/sierra/loadout/loadout_suit.dm"
	#include "../../../../maps/sierra/loadout/loadout_tactical.dm"
	#include "../../../../maps/sierra/loadout/loadout_uniform.dm"
	#include "../../../../maps/sierra/loadout/loadout_xeno.dm"
	#include "../../../../maps/sierra/loadout/~defines.dm"



	// --- INCLUDES FROM ANOTHER MAPS --- //
	//Нет

	// --- DATUMS SECTION --- //
	//Нет

	// --- MAP FILES --- //
	#include "../../maps/dev_map.dmm"
	// USED MODS
	// Keep them in ascending alphabetical order, please

	#include "../../../../mods/_maps/liberia/_map_liberia.dme"
	#include "../../../../mods/_maps/sentinel/_map_sentinel.dme"
	#include "../../../../mods/_maps/farfleet/_map_farfleet.dme"
	#include "../../../../mods/_maps/hand/_map_hand.dme"
	#include "../../../../mods/_maps/ascent_seedship/_map_ascent_seedship.dme"
	#include "../../../../mods/_maps/ascent_caulship/_map_ascent_caulship.dme"

	#include "../../../../mods/antagonists/_antagonists.dme"
	#include "../../../../mods/ascent/_ascent.dme"
	#include "../../../../mods/fancy_sofas/_fancy_sofas.dme"
	#include "../../../../mods/guns/_guns.dme"
	#include "../../../../mods/jukebox_tapes/_jukebox_tapes.dme"
	#include "../../../../mods/legalese_language/_legalese.dme"
	#include "../../../../mods/petting_zoo/_petting_zoo.dme"
	#include "../../../../mods/resomi/_resomi.dme"
	#include "../../../../mods/screentips/_screentips.dme"
	#include "../../../../mods/tajara/_tajara.dme"
	#include "../../../../mods/sauna_props/_sauna_props.dme"
	#include "../../../../mods/wyccbay_optimization/_wyccbay_optimization.dme"
	#include "../../../../mods/contraband_vending/_contraband_vending.dme"
	#include "../../../../mods/telecomms/_telecomms.dme"
	#include "../../../../mods/modernUI/_modernUI.dme"

	// UNUSED MODS
	// Keep them in ascending alphabetical order too, please

	// #include "../../mods/atmos_ret_field/_atm_ret_field.dme"
	// #include "../../mods/bluespace_kitty/_bluespace_kitty.dme"

	// Почему UNUSED MODS стоит хранить?
	// Потому что никто не проверяет использование тех или иных файлов
	// в коде, и мод просто исчезнет из поля зрения, когда находясь здесь
	// он всегда напоминает о своём существовании. Небольшая библиотека,
	// если так вообще можно выразиться.

	#include "../../../../packs/factions/iccgn/_pack.dm"
	#include "../../../../packs/factions/scga/_pack.dm"
	#include "../../../../packs/factions/fa/_pack.dm"
	#include "../../../../packs/infinity/_pack.dm"
	#include "../../../../packs/deepmaint/_pack.dm"

	//АВЕЙКИ
	#include "../../../../maps/away/mining/mining.dm"
	#include "../../../../maps/away/derelict/derelict.dm"
	#include "../../../../maps/away/bearcat/bearcat.dm"
	#include "../../../../maps/away/lost_supply_base/lost_supply_base.dm"
	#include "../../../../maps/away/smugglers/smugglers.dm"
	#include "../../../../maps/away/magshield/magshield.dm"
	#include "../../../../maps/away/casino/casino.dm"
	#include "../../../../maps/away/yacht/yacht.dm"
	#include "../../../../maps/away/blueriver/blueriver.dm"
	#include "../../../../maps/away/slavers/slavers_base.dm"
	#include "../../../../maps/away/mobius_rift/mobius_rift.dm"
	#include "../../../../maps/away/errant_pisces/errant_pisces.dm"
	#include "../../../../maps/away/lar_maria/lar_maria.dm"
	#include "../../../../maps/away/voxship/voxship.dm"
	#include "../../../../maps/away/skrellscoutship/skrellscoutship.dm"
	#include "../../../../maps/away/meatstation/meatstation.dm"
	#include "../../../../maps/away/miningstation/miningstation.dm"
	#include "../../../../maps/away/mininghome/mininghome.dm"
	#include "../../../../maps/away/scavver/scavver_gantry.dm"
	#include "../../../../maps/away/abandoned_hotel/abandoned_hotel.dm"
	#include "../../../../maps/event/iccgn_ship/icgnv_hound.dm"
	#include "../../../../maps/event/sfv_arbiter/sfv_arbiter.dm"
	#include "../../../../maps/event/placeholders/placeholders.dm"
	#include "../../../../maps/event/empty/empty.dm"



	#define using_map_DATUM /datum/map/dev

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring dev

#endif
