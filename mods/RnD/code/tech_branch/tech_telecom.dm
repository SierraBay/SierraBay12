// Telecommunications & Bluespace technology branch — corporate nodes only

// ========== DAIS ==========

/datum/technology/telecommunications
	name = "NTNet Relay & Communications (DAIS)"
	desc = "NTNet quantum relay and communications systems."
	id = "ntnet_relay_communications_dais"
	tech_type = RESEARCH_BLUESPACE

	x = 0.1
	y = 0.5
	icon = "solnet_relay"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 0
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list(
		"ntnet_relay",
		"tcom-processor",
		"tcom-server",
		"tcom-bus",
		"tcom-hub"
	)

/datum/technology/telecommunications/communication_monitoring_dais
	name = "Communication Monitoring (DAIS)"
	desc = "Communication monitoring and server systems."
	id = "communication_monitoring_dais"

	x = 0.2
	y = 0.5
	icon = "monitoring"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 5
	cost = 1500

	unlocks_designs = list(
		"comm_monitor",
		"comm_server",
		"message_monitor",
		"cryo_console",
		"cryo_console_borg"
	)

/datum/technology/telecommunications/communication_crew_controls_dais
	name = "Communication & Crew Controls (DAIS)"
	desc = "Communication and crew control systems."
	id = "communication_crew_controls_dais"

	x = 0.3
	y = 0.5
	icon = "processor"

	required_corp_id = RND_MISSION_CORP_DAIS
	min_reputation = 10
	cost = 2000

	unlocks_designs = list(
		"accounts",
		"traffic_server"
	)

// ========== Kappa ==========

/datum/technology/telecommunications/subspace_broadcasting_kappa
	name = "Subspace Broadcasting (Kappa)"
	desc = "Subspace broadcasting and receiving systems."
	id = "subspace_broadcasting_kappa"

	x = 0.1
	y = 0.5
	icon = "subspace"

	required_corp_id = RND_MISSION_CORP_KAPPA
	min_reputation = 0
	cost = 1200

	unlocks_designs = list(
		"tcom-broadcaster",
		"tcom-receiver"
	)

/datum/technology/telecommunications/subspace_mainframes_kappa
	name = "Subspace Mainframes (Kappa)"
	desc = "Subspace mainframe systems."
	id = "subspace_mainframes_kappa"

	x = 0.2
	y = 0.5
	icon = "relay"

	required_corp_id = RND_MISSION_CORP_KAPPA
	min_reputation = 5
	cost = 1600

	unlocks_designs = list(
		"tcom-bus"
	)

/datum/technology/telecommunications/bluespace_relay_kappa
	name = "Bluespace Relay (Kappa)"
	desc = "Bluespace relay systems."
	id = "bluespace_relay_kappa"

	x = 0.3
	y = 0.5
	icon = "bluespace"

	required_corp_id = RND_MISSION_CORP_KAPPA
	min_reputation = 10
	cost = 2000

	unlocks_designs = list(
		"bluespacerelay"
	)

/datum/technology/telecommunications/tracking_devices_kappa
	name = "Tracking Devices (Kappa)"
	desc = "Tracking and localization systems."
	id = "tracking_devices_kappa"

	x = 0.4
	y = 0.5
	icon = "gps"

	required_corp_id = RND_MISSION_CORP_KAPPA
	min_reputation = 0
	cost = 1200

	unlocks_designs = list(
		"gps",
		"telesci-gps",
		"beacon_locator"
	)

/datum/technology/telecommunications/telecom_parts_kappa
	name = "Telecommunication Parts (Kappa)"
	desc = "Subspace communication components and amplification."
	id = "telecom_parts_kappa"

	x = 0.5
	y = 0.5
	icon = "telecom_part"

	required_corp_id = RND_MISSION_CORP_KAPPA
	min_reputation = 5
	cost = 1500

	unlocks_designs = list(
		"s-amplifier",
		"s-filter",
		"s-ansible",
		"s-crystal",
		"s-treatment",
		"s-analyzer",
		"s-transmitter"
	)

// ========== NanoTrasen (Bluespace) ==========

/datum/technology/telecommunications/bluespace_tech_nt
	name = "Bluespace Technology (NanoTrasen)"
	desc = "Artificial bluespace crystal synthesis and storage."
	id = "bluespace_tech_nt"

	x = 0.1
	y = 0.5
	icon = "bscrystal"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 0
	cost = 1500

	unlocks_designs = list(
		"artificial_bluespace_crystal",
		"bag_holding",
		"blutrash"
	)

/datum/technology/telecommunications/teleporter_tech_nt
	name = "Teleporter Technology (NanoTrasen)"
	desc = "Teleportation pad and control systems."
	id = "teleporter_tech_nt"

	x = 0.2
	y = 0.5
	icon = "teleport"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 5
	cost = 3000

	unlocks_designs = list(
		"telepad",
		"telesci_console",
		"teleconsole",
		"tele_beacon",
		"teleprojector",
		"teleporter_pad"
	)

/datum/technology/telecommunications/bluespace_snare_nt
	name = "Bluespace Snare (NanoTrasen)"
	desc = "Bluespace interdiction and snare systems."
	id = "bluespace_snare_nt"

	x = 0.3
	y = 0.5
	icon = "rd"

	required_corp_id = RND_MISSION_CORP_NANOTRASEN
	min_reputation = 10
	cost = 2500

	unlocks_designs = list(
		"bs_silk",
		"bs_snare_hub",
		"bs_snare_control"
	)
