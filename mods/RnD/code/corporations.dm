// Corporation ID defines and utility procs

#ifndef RND_MISSION_CORP_NANOTRASEN
#define RND_MISSION_CORP_NANOTRASEN "nanotrasen"
#define RND_MISSION_CORP_VEYMED "veymed"
#define RND_MISSION_CORP_MORPHEUS "morpheus"
#define RND_MISSION_CORP_HEPHAESTUS "hephaestus"
#define RND_MISSION_CORP_DAIS "dais"
#define RND_MISSION_CORP_GRAYSON "grayson"
#define RND_MISSION_CORP_KAPPA "kappa"
#define RND_MISSION_CORP_AETHER "aether"
#define RND_MISSION_CORP_WARD_TAKAHASHI "ward_takahashi"
#define RND_MISSION_CORP_EINSTEIN "einstein"
#define RND_MISSION_CORP_XION "xion"
#define RND_MISSION_CORP_SLATE "slate"
#define RND_MISSION_CORP_FOCAL "focal"
#define RND_MISSION_CORP_ZENG_HU "zeng_hu"
#define RND_MISSION_CORP_BISHOP "bishop"
#define RND_MISSION_CORP_SHELLGUARD "shellguard"
#define RND_MISSION_CORP_ALMALIKI "almaliki"
#define RND_MISSION_CORP_HELTEK "heltek"
#define RND_MISSION_CORP_FTU "ftu"
#endif

/proc/get_rnd_mission_corporation_name(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_KAPPA)
			return "Kappa Communications"
		if(RND_MISSION_CORP_VEYMED)
			return "Vey-Med"
		if(RND_MISSION_CORP_HEPHAESTUS)
			return "Hephaestus Industries"
		if(RND_MISSION_CORP_NANOTRASEN)
			return "NanoTrasen"
		if(RND_MISSION_CORP_DAIS)
			return "DAIS"
		if(RND_MISSION_CORP_GRAYSON)
			return "Grayson Manufactories Ltd."
		if(RND_MISSION_CORP_AETHER)
			return "Aether Atmospherics"
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "Ward-Takahashi GMB"
		if(RND_MISSION_CORP_EINSTEIN)
			return "Einstein Engines"
		if(RND_MISSION_CORP_XION)
			return "Xion Industrial"
		if(RND_MISSION_CORP_SLATE)
			return "Slate Sisters Engineering"
		if(RND_MISSION_CORP_FOCAL)
			return "Focal Point Dynamics"
		if(RND_MISSION_CORP_BISHOP)
			return "Bishop Cybernetics"
		if(RND_MISSION_CORP_SHELLGUARD)
			return "Shellguard"
		if(RND_MISSION_CORP_MORPHEUS)
			return "Morpheus Cybernetics"
		if(RND_MISSION_CORP_ZENG_HU)
			return "Zeng Hu Pharmaceuticals"
		if(RND_MISSION_CORP_ALMALIKI)
			return "Al-Maliki & Mosley"
		if(RND_MISSION_CORP_HELTEK)
			return "HelTek Arms"
		if(RND_MISSION_CORP_FTU)
			return "Free Trade Union"
	return "Independent"

/proc/get_rnd_mission_corporations()
	return list(
		RND_MISSION_CORP_NANOTRASEN,
		RND_MISSION_CORP_WARD_TAKAHASHI,
		RND_MISSION_CORP_GRAYSON,
		RND_MISSION_CORP_AETHER,
		RND_MISSION_CORP_EINSTEIN,
		RND_MISSION_CORP_XION,
		RND_MISSION_CORP_SLATE,
		RND_MISSION_CORP_FOCAL,
		RND_MISSION_CORP_DAIS,
		RND_MISSION_CORP_KAPPA,
		RND_MISSION_CORP_VEYMED,
		RND_MISSION_CORP_HEPHAESTUS,
		RND_MISSION_CORP_BISHOP,
		RND_MISSION_CORP_SHELLGUARD,
		RND_MISSION_CORP_MORPHEUS,
		RND_MISSION_CORP_ZENG_HU,
		RND_MISSION_CORP_ALMALIKI,
		RND_MISSION_CORP_HELTEK,
		RND_MISSION_CORP_FTU
	)



/proc/get_rnd_corp_logo(corp_id)
	switch(corp_id)
		if(RND_MISSION_CORP_NANOTRASEN)
			return "ntlogo.png"
		if(RND_MISSION_CORP_WARD_TAKAHASHI)
			return "wardlogo.png"
		if(RND_MISSION_CORP_AETHER)
			return "aetherlogo.png"
		if(RND_MISSION_CORP_GRAYSON)
			return "graylogo.png"
		if(RND_MISSION_CORP_SLATE)
			return "slatelogo.png"
		if(RND_MISSION_CORP_EINSTEIN)
			return "eelogo.png"
		if(RND_MISSION_CORP_XION)
			return "xionlogo.png"
		if(RND_MISSION_CORP_KAPPA)
			return "kappalogo.png"
		if(RND_MISSION_CORP_DAIS)
			return "daisnlogo.png"
		if(RND_MISSION_CORP_MORPHEUS)
			return "mklogo.png"
		if(RND_MISSION_CORP_SHELLGUARD)
			return "sglogo.png"
		if(RND_MISSION_CORP_VEYMED)
			return "vmlogo.png"
		if(RND_MISSION_CORP_ZENG_HU)
			return "zenhulogo.png"
		if(RND_MISSION_CORP_FOCAL)
			return "focallogo.png"
		if(RND_MISSION_CORP_BISHOP)
			return "bishoplogo.png"
		if(RND_MISSION_CORP_ALMALIKI)
			return "amlogo.png"
		if(RND_MISSION_CORP_HEPHAESTUS)
			return "hilogo.png"
		if(RND_MISSION_CORP_HELTEK)
			return "heltek_logo.png"
		if(RND_MISSION_CORP_FTU)
			return "ftulogo.png"
	return null


// Get all designs that belong to a specific corporation
/proc/get_corporation_designs(corp_id)
	var/list/designs = list()
	if(!SSresearch || !SSresearch.all_tech_nodes)
		return designs

	for(var/datum/technology/tech_node in SSresearch.all_tech_nodes)
		if(!tech_node.required_corp_id || tech_node.required_corp_id != corp_id)
			continue
		if(!tech_node.unlocks_designs || !length(tech_node.unlocks_designs))
			continue
		for(var/design_id in tech_node.unlocks_designs)
			designs[design_id] = TRUE

	return designs

// Find which corporation owns a given design
/proc/get_design_corporation(design_id)
	if(!SSresearch || !SSresearch.all_tech_nodes)
		return null

	for(var/datum/technology/tech_node in SSresearch.all_tech_nodes)
		if(!tech_node.required_corp_id)
			continue
		if(!tech_node.unlocks_designs || !length(tech_node.unlocks_designs))
			continue
		if(design_id in tech_node.unlocks_designs)
			return tech_node.required_corp_id

	return null

// Get a random design from a corporation's tech tree
/proc/get_random_corporation_design(corp_id)
	var/list/corp_designs = get_corporation_designs(corp_id)
	if(!length(corp_designs))
		return null

	var/picked_design = pick(corp_designs)
	return picked_design
