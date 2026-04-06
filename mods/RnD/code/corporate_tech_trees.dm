/// Tech tree category system - organized by technology type with corporation branches
var/global/list/rnd_tech_categories = list(
	"engineering" = list(
		"name" = "Engineering",
		"trees" = list(
			RND_MISSION_CORP_NANOTRASEN = list(
				"name" = "NanoTrasen",
				"nodes" = list(
					"basic_engineering_nt",
					"research_tech_nt",
					"xenoarch_nt",
					"excavation_drill_nt",
					"doppler_array_nt"
				)
			),
			RND_MISSION_CORP_WARD_TAKAHASHI = list(
				"name" = "Ward-Takahashi GMB",
				"nodes" = list(
					"basic_engineering_wt",
					"advanced_tools_wt",
					"modular_computer_frames_wt"
				)
			),
			RND_MISSION_CORP_GRAYSON = list(
				"name" = "Grayson Manufactories Ltd.",
				"nodes" = list(
					"basic_engineering_grayson",
					"industrial_processing_grayson",
					"basic_mining_grayson",
					"mining_production_grayson",
					"advanced_mining_grayson"
				)
			),
			RND_MISSION_CORP_AETHER = list(
				"name" = "Aether Atmospherics",
				"nodes" = list(
					"basic_engineering_aether",
					"gas_systems_aether",
					"portable_atmos_aether",
					"jetpack_aether"
				)
			),
			RND_MISSION_CORP_EINSTEIN = list(
				"name" = "Einstein Engines",
				"nodes" = list(
					"basic_engineering_einstein",
					"super_power_generation_einstein",
					"experimental_power_generation_einstein"
				)
			),
			RND_MISSION_CORP_XION = list(
				"name" = "Xion Industrial",
				"nodes" = list(
					"basic_engineering_xion",
					"integrated_circuits_xion",
					"ic_upgrade_xion",
					"advanced_engineering_xion",
					"super_parts_xion"
				)
			),
			RND_MISSION_CORP_SLATE = list(
				"name" = "Slate Sisters Engineering",
				"nodes" = list(
					"ship_equipment_slate",
					"ship_coordination_slate",
					"ship_control_slate",
					"ion_thrusters_slate",
					"shield_systems_slate"
				)
			),
			RND_MISSION_CORP_FOCAL = list(
				"name" = "Focal Point Energetics",
				"nodes" = list(
					"advanced_power_solar_focal",
					"super_power_storage_focal",
					"hyper_power_induction_focal",
					"advanced_storage_focal"
				)
			)
		)
	),
	"telecommunications" = list(
		"name" = "Bluespace & Telecom",
		"trees" = list(
			RND_MISSION_CORP_DAIS = list(
				"name" = "DAIS",
				"nodes" = list(
					"ntnet_relay_communications_dais",
					"communication_monitoring_dais",
					"communication_crew_controls_dais"
				)
			),
			RND_MISSION_CORP_KAPPA = list(
				"name" = "Kappa Communications",
				"nodes" = list(
					"subspace_broadcasting_kappa",
					"subspace_mainframes_kappa",
					"bluespace_relay_kappa",
					"tracking_devices_kappa",
					"telecom_parts_kappa"
				)
			),
			RND_MISSION_CORP_NANOTRASEN = list(
				"name" = "NanoTrasen",
				"nodes" = list(
					"bluespace_tech_nt",
					"teleporter_tech_nt",
					"bluespace_snare_nt"
				)
			)
		)
	),
	"biotech" = list(
		"name" = "Biotech",
		"trees" = list(
			RND_MISSION_CORP_ZENG_HU = list(
				"name" = "Zeng Hu Pharmaceuticals",
				"nodes" = list(
					"reagent_tools_zh",
					"adv_reagent_tools_zh",
					"implant_injection_zh",
					"adv_injection_zh"
				)
			),
			RND_MISSION_CORP_VEYMED = list(
				"name" = "VeyMed",
				"nodes" = list(
					"basic_biotech_veymed",
					"basic_medical_tools_veymed",
					"adv_biotech_veymed",
					"adv_medical_tools_veymed"
				)
			),
			RND_MISSION_CORP_WARD_TAKAHASHI = list(
				"name" = "Ward-Takahashi GMB",
				"nodes" = list(
					"hydroponics_wt_bio",
					"food_processing_wt_bio",
					"advanced_hydroponics_wt_bio"
				)
			)
		)
	),
	"cybernetics" = list(
		"name" = "Cybernetics",
		"trees" = list(
			RND_MISSION_CORP_GRAYSON = list(
				"name" = "Grayson Manufactories Ltd.",
				"nodes" = list(
					"hardsuit_mining_grayson",
					"advanced_hardsuit_mining_grayson",
					"heavy_duty_mining_grayson"
				)
			),
			RND_MISSION_CORP_MORPHEUS = list(
				"name" = "Morpheus Cybernetics",
				"nodes" = list(
					"basic_robotech_morpheus",
					"robots_upgrade_morpheus",
					"advanced_synth_morpheus",
					"ai_construction_morpheus"
				)
			),
			RND_MISSION_CORP_XION = list(
				"name" = "Xion Industrial",
				"nodes" = list(
					"exosuit_fabrication_xion",
					"mech_machinery_xion",
					"advanced_mech_modules_xion",
					"basic_engineering_augments_xion",
					"advanced_engineering_augments_xion"
				)
			),
			RND_MISSION_CORP_BISHOP = list(
				"name" = "Bishop Cybernetics",
				"nodes" = list(
					"utility_implants_bishop",
					"cyber_sonar_bishop",
					"prosthetic_repairs_bishop"
				)
			),
			RND_MISSION_CORP_VEYMED = list(
				"name" = "Veymed Medical Corporation",
				"nodes" = list(
					"medical_augmentations_veymed",
					"medical_hardsuit_systems_veymed",
					"medical_exosuit_systems_veymed"
				)
			),
			RND_MISSION_CORP_SHELLGUARD = list(
				"name" = "Shellguard",
				"nodes" = list(
					"exosuit_weapon_control_shellguard",
					"heavy_energy_weapons_shellguard",
					"heavy_ballistic_weapons_shellguard",
					"defence_systems_shellguard",
					"security_augments_shellguard",
					"augment_weaponry_shellguard",
					"hi_koloss_design_shellguard"
				)
			),
			RND_MISSION_CORP_HEPHAESTUS = list(
				"name" = "Hephaestus Industries",
				"nodes" = list(
					"combat_mech_design_heph",
					"mech_heavy_weapons_heph",
					"military_augments_heph"
				)
			),
			RND_MISSION_CORP_DAIS = list(
				"name" = "DAIS",
				"nodes" = list(
					"personal_ai_dais",
					"ai_maintenance_dais",
					"basic_modular_computers_dais",
					"power_effective_electronics_dais",
					"advanced_electronics_dais",
					"hiend_electronics_dais"
				)
			)
		)
	),
	"combat" = list(
		"name" = "Combat",
		"trees" = list(
			RND_MISSION_CORP_NANOTRASEN = list(
				"name" = "NanoTrasen",
				"nodes" = list(
					"security_equipment_nt",
					"nonlethal_weapons_nt",
					"nt_combat_weapons",
					"experimental_weapons_nt"
				)
			),
			RND_MISSION_CORP_ALMALIKI = list(
				"name" = "Al-Maliki & Mosley",
				"nodes" = list(
					"frontier_revolvers_am",
					"frontier_ordnance_am",
					"specialized_am_weapons"
				)
			),
			RND_MISSION_CORP_HEPHAESTUS = list(
				"name" = "Hephaestus Industries",
				"nodes" = list(
					"basic_military_heph",
					"advanced_military_heph",
					"heavy_weapons_heph",
					"strategic_systems_heph"
				)
			),
			RND_MISSION_CORP_WARD_TAKAHASHI = list(
				"name" = "Ward-Takahashi GMB",
				"nodes" = list(
					"mass_produced_wt",
					"ordnance_wt"
				)
			),
			RND_MISSION_CORP_HELTEK = list(
				"name" = "HelTek Arms",
				"nodes" = list(
					"heltek_sidearms",
					"heltek_assault",
					"heltek_heavy"
				)
			),
			RND_MISSION_CORP_FTU = list(
				"name" = "Free Trade Union",
				"nodes" = list(
					"ftu_sidearms",
					"ftu_longarms",
					"ftu_military"
				)
			)
		)
	)
)

/// Get all category data
/proc/get_rnd_tech_categories()
	return rnd_tech_categories ? rnd_tech_categories.Copy() : list()

/// Get category data by ID
/proc/get_rnd_category(category_id)
	return rnd_tech_categories[category_id]

/// Get all corporation trees within a category
/proc/get_rnd_category_trees(category_id)
	var/list/category = get_rnd_category(category_id)
	if(!category)
		return list()
	var/list/trees = category["trees"]
	return trees ? trees.Copy() : list()

/// Get specific corporation tree within a category
/proc/get_rnd_category_tree(category_id, corp_id)
	var/list/trees = get_rnd_category_trees(category_id)
	return trees ? trees[corp_id] : null

/// Get all tech nodes for a corporation within a category
/proc/get_rnd_category_tree_nodes(category_id, corp_id)
	var/list/tree = get_rnd_category_tree(category_id, corp_id)
	if(!tree)
		return list()
	var/list/nodes = tree["nodes"]
	return nodes ? nodes.Copy() : list()

/// Get random category ID
/proc/get_rnd_random_category()
	var/list/categories = get_rnd_tech_categories()
	return categories ? pick(categories) : null

/// Get all corporations offering tech in a category
/proc/get_rnd_category_corporations(category_id)
	var/list/trees = get_rnd_category_trees(category_id)
	return trees ? trees.Copy() : list()

/// Get all node IDs for a given corporation across all categories
/proc/get_all_corp_nodes(corp_id)
	var/list/result = list()
	for(var/cat_id in rnd_tech_categories)
		var/list/nodes = get_rnd_category_tree_nodes(cat_id, corp_id)
		if(LAZYLEN(nodes))
			result += nodes
	return result

/// DEPRECATED - Legacy function for backward compatibility
/proc/get_rnd_corporation_order()
	var/list/corps = list()
	var/list/categories = get_rnd_tech_categories()
	if(!categories)
		return list()
	for(var/category_id in categories)
		var/list/trees = get_rnd_category_trees(category_id)
		if(trees)
			for(var/corp_id in trees)
				if(!(corp_id in corps))
					corps[corp_id] = TRUE
	var/list/result = list()
	for(var/corp_id in corps)
		result += corp_id
	return result

/// DEPRECATED - Legacy function for backward compatibility
/proc/get_rnd_corp_tree(corp_id)
	// Find first category containing this corporation
	var/list/categories = get_rnd_tech_categories()
	if(!categories)
		return null
	for(var/cat_id in categories)
		var/list/trees = get_rnd_category_trees(cat_id)
		if(corp_id in trees)
			var/list/tree = trees[corp_id]
			var/list/result = tree.Copy()
			result["category"] = cat_id
			return result
	return null

/// DEPRECATED - Legacy function for backward compatibility
/proc/get_rnd_corp_tree_nodes(corp_id)
	var/list/categories = get_rnd_tech_categories()
	if(!categories)
		return list()
	for(var/cat_id in categories)
		var/list/nodes = get_rnd_category_tree_nodes(cat_id, corp_id)
		if(nodes && LAZYLEN(nodes))
			return nodes
	return list()

/proc/get_rnd_corp_node_price(datum/technology/tech_node, datum/research/research_datum = null)
	if(!tech_node)
		return 0

	// Use reputation-adjusted price if research datum is provided
	if(research_datum)
		return max(0, round(get_rnd_tech_cost_with_reputation(tech_node, research_datum)))

	return max(0, round(tech_node.cost))

/proc/get_rnd_corp_node_requirements_met(datum/research/files, datum/technology/tech_node, list/corp_node_set = null)
	if(!files || !tech_node)
		return FALSE
	if(files.IsResearched(tech_node))
		return FALSE
	for(var/t in tech_node.required_tech_levels)
		var/datum/tech/tree = locate(t) in files.researched_tech
		var/level = tech_node.required_tech_levels[t]
		if(!tree || tree.level < level)
			return FALSE

	// Check reputation requirement instead of required_technologies
	if(tech_node.required_corp_id)
		var/rep = files.GetCorporationReputation(tech_node.required_corp_id)
		if(rep < tech_node.min_reputation)
			return FALSE

	return TRUE
