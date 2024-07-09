/datum/technology/tcom
	name = "Telecommuncation Parts"
	desc = "Telecommuncation Parts"
	id = "telecomm_parts"
	tech_type = RESEARCH_BLUESPACE

	x = 0.5
	y = 0.5
	icon = "telecom_part"

	required_technologies = list()
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("s-ansible", "s-filter", "s-amplifier", "s-treatment", "s-analyzer", "s-crystal", "s-transmitter")

/datum/technology/tcom/monitoring
	name = "Monitoring Consoles"
	desc = "Monitoring Consoles"
	id = "tcom_monitoring"

	x = 0.5
	y = 0.6
	icon = "monitoring"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("comm_monitor", "comm_server", "message_monitor", "shield_generator", "shield_diffuser")

/datum/technology/tcom/rcon
	name = "RCON"
	desc = "RCON"
	id = "rcon"

	x = 0.5
	y = 0.7
	icon = "monitoring"

	required_technologies = list("tcom_monitoring")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("rcon_console")

/datum/technology/tcom/mainframes
	name = "Mainframes"
	desc = "Mainframes"
	id = "mainframes"

	x = 0.4
	y = 0.6
	icon = "relay"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("tcom-server", "tcom-bus", "tcom-hub", "bluespacerelay")

/datum/technology/tcom/solnet_relay
	name = "SolNet Quantum Relay"
	desc = "SolNet Quantum Relay"
	id = "solnet_relay"

	x = 0.3
	y = 0.6
	icon = "solnet_relay"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 1750

	unlocks_designs = list("ntnet_relay", "accounts","holo","cryo_console","cryo_console_borg")

/datum/technology/tcom/subspace
	name = "Subspace Broadcaster/Reciever"
	desc = "Subspace Broadcaster/Reciever"
	id = "subspace"

	x = 0.6
	y = 0.6
	icon = "subspace"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("tcom-broadcaster", "tcom-receiver")

/datum/technology/tcom/processor
	name = "Processor Unit"
	desc = "Processor Unit"
	id = "processor"

	x = 0.7
	y = 0.6
	icon = "processor"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("tcom-processor","guestpass")


/datum/technology/tcom/track_dev
	name = "Tracking Devices"
	desc = "Tracking Devices"
	id = "track_dev"

	x = 0.5
	y = 0.4
	icon = "gps"

	required_technologies = list("telecomm_parts")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("gps", "beacon_locator", "telesci-gps")

/datum/technology/tcom/arti_blue
	name = "Artificial Bluesplace"
	desc = "Artificial Bluesplace"
	id = "crystal"

	x = 0.5
	y = 0.3
	icon = "bscrystal"

	required_technologies = list("track_dev")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("gps", "beacon_locator")


/datum/technology/tcom/tele_sci
	name = "Tele Science"
	desc = "Tele Science"
	id = "tele_sci"

	x = 0.4
	y = 0.2
	icon = "telepad"

	required_technologies = list("crystal")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("telepad", "telesci_console")


/datum/technology/tcom/bs_silk
	name = "Blue Space Snare"
	desc = "Blue Space Snare"
	id = "bs_silk"

	x = 0.3
	y = 0.2
	icon = "rd"

	required_technologies = list("crystal")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("bs_silk", "bs_snare_hub","bs_snare_control")


/datum/technology/tcom/tele_pad
	name = "Teleporter"
	desc = "Teleporter"
	id = "teleport"

	x = 0.6
	y = 0.2
	icon = "teleport"

	required_technologies = list("crystal")
	required_tech_levels = list()
	cost = 3000

	unlocks_designs = list("teleconsole", "tele_beacon")


/datum/technology/tcom/bsbag
	name = "Bluespace Storage"
	desc = "Bluespace Storage"
	id = "bsbag"

	x = 0.5
	y = 0.2
	icon = "bluespace"

	required_technologies = list("crystal")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("bag_holding", "blutrash")
