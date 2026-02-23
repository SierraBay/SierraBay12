var/global/list/rnd_corp_reward_packs = list(
	"hephaestus_recovery" = list(
		"pack_name" = "Hephaestus: Industrial Recovery Kit",
		"node_ids" = list("mining_prod")
	),
	"nanotrasen_esoteric" = list(
		"pack_name" = "NanoTrasen: Applied Data Suite",
		"node_ids" = list("adv_scanners", "netcard_w")
	),
	"veymed_bioproduct" = list(
		"pack_name" = "Vey-Med: Clinical Systems Bundle",
		"node_ids" = list("basic_medical_machines")
	),
	"ward_takahashi_tools" = list(
		"pack_name" = "Ward-Takahashi: Sensor Calibration Kit",
		"node_ids" = list("adv_tools")
	),
	"grayson_mining" = list(
		"pack_name" = "Grayson: Mining Logistics Bundle",
		"node_ids" = list("mining_prod")
	),
	"aether_atmos" = list(
		"pack_name" = "Aether: Atmospherics Package",
		"node_ids" = list("gas_heat")
	),
	"einstein_power" = list(
		"pack_name" = "Einstein: Power Systems Suite",
		"node_ids" = list("monitoring")
	),
	"xion_industrial" = list(
		"pack_name" = "Xion: Industrial Fabrication Kit",
		"node_ids" = list("adv_eng")
	),
	"slate_shipbuilding" = list(
		"pack_name" = "Slate Sisters: Shipwright Toolkit",
		"node_ids" = list("adv_tools")
	),
	"focal_power" = list(
		"pack_name" = "Focal Point: Power Grid Bundle",
		"node_ids" = list("monitoring")
	),
	"dais_network" = list(
		"pack_name" = "DAIS: Network Diagnostics Pack",
		"node_ids" = list("netcard_w")
	),
	"kappa_comms" = list(
		"pack_name" = "Kappa: Relay Stabilization Pack",
		"node_ids" = list("adv_scanners")
	),
	"mahimaku_precision" = list(
		"pack_name" = "Mahimaku: Precision Instrument Set",
		"node_ids" = list("adv_scanners")
	),
	"almaliki_ballistics" = list(
		"pack_name" = "Al-Maliki: Ballistic Systems Kit",
		"node_ids" = list("basic_ballistic_am")
	),
	"bishop_neural" = list(
		"pack_name" = "Bishop: Neural Interface Suite",
		"node_ids" = list("utility_implants_bishop")
	),
	"morpheus_synth" = list(
		"pack_name" = "Morpheus: Synthetic Diagnostics Pack",
		"node_ids" = list("basic_robotech_morpheus")
	),
	"shellguard_tactical" = list(
		"pack_name" = "SHELLGUARD: Tactical Recon Kit",
		"node_ids" = list("exosuit_weapon_control_shellguard")
	),
	"zeng_hu_pharma" = list(
		"pack_name" = "Zeng-Hu: Pharmaceutical Research Suite",
		"node_ids" = list("reagent_tools_zh")
	)
)

/proc/get_rnd_reward_tech_node_by_id(node_id)
	if(!node_id)
		return null

	for(var/_tech in SSresearch.all_tech_nodes)
		var/datum/technology/tech = _tech
		if(tech.id == node_id)
			return tech

	return null

/proc/get_rnd_reward_designs_from_nodes(list/node_ids)
	var/list/designs = list()
	if(!node_ids)
		return designs

	for(var/node_id in node_ids)
		var/datum/technology/tech = get_rnd_reward_tech_node_by_id(node_id)
		if(!tech)
			continue

		for(var/design_id in tech.unlocks_designs)
			if(!(design_id in designs))
				designs += design_id

	return designs

/proc/apply_rnd_mission_reward_pack(datum/rnd_mission/mission, reward_pack_id)
	if(!mission || !reward_pack_id)
		return FALSE

	var/list/pack = rnd_corp_reward_packs[reward_pack_id]
	if(!pack)
		return FALSE

	mission.reward_pack_name = pack["pack_name"] || mission.reward_pack_name
	var/list/node_ids = pack["node_ids"]
	if(node_ids && length(node_ids))
		mission.reward_design_ids = get_rnd_reward_designs_from_nodes(node_ids)

	return TRUE
