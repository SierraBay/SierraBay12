/datum/technology/data
	name = "Basic Modular Computers"
	desc = "Basic Modular Computers"
	id = "basic_modular"
	tech_type = RESEARCH_DATA

	x = 0.5
	y = 0.3
	icon = "cpu"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list("hdd_basic", "netcard_basic", "bat_normal", "portadrive_basic", "cpu_normal","pc_motherboard")

/datum/technology/data/frames
	name = "Modular Computers Frames"
	desc = "Modular Computers Frames"
	id = "frames"

	x = 0.5
	y = 0.2
	icon = "tablet_frame"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("pda_frame", "tablet_frame", "laptop_frame", "telescreen_frame")

/datum/technology/data/ms_hdd
	name = "Power effective HDD's"
	desc = "Power effective HDD's"
	id = "ms_hdd"

	x = 0.5
	y = 0.4
	icon = "hdd64"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list("hdd_micro", "hdd_small")

/datum/technology/data/adv_hdd
	name = "Advanced HDD"
	desc = "Advanced HDD"
	id = "adv_hdd"

	x = 0.5
	y = 0.5
	icon = "hdd256"

	required_technologies = list("ms_hdd")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("hdd_advanced", "portadrive_advanced")

/datum/technology/data/sup_hdd
	name = "Super HDD"
	desc = "Super HDD"
	id = "sup_hdd"

	x = 0.5
	y = 0.6
	icon = "hdd512"

	required_technologies = list("adv_hdd")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("hdd_super", "portadrive_super")

/datum/technology/data/cls_hdd
	name = "Cluster HDD"
	desc = "Cluster HDD"
	id = "cls_hdd"

	x = 0.5
	y = 0.7
	icon = "hdd2048"

	required_technologies = list("sup_hdd")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("hdd_cluster")

/datum/technology/data/netcard_w
	name = "Wired Netcard"
	desc = "Wired Netcard"
	id = "netcard_w"

	x = 0.4
	y = 0.4
	icon = "netcard_w"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("netcard_wired")

/datum/technology/data/netcard_adv
	name = "Advanced Netcard"
	desc = "Advanced Netcard"
	id = "netcard_adv"

	x = 0.4
	y = 0.5
	icon = "netcard_adv"

	required_technologies = list("netcard_w")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("netcard_advanced")

/datum/technology/data/cpu_small
	name = "Computer Microprocessor Unit"
	desc = "Computer Microprocessor Unit"
	id = "cpu_small"

	x = 0.7
	y = 0.4
	icon = "cpu_small"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list("cpu_small")

/datum/technology/data/pcpu_small
	name = "Computer Photonic Microprocessor Unit"
	desc = "Computer Photonic Microprocessor Unit"
	id = "pcpu_small"

	x = 0.7
	y = 0.5
	icon = "pcpu_small"

	required_technologies = list("cpu_small")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("pcpu_small")

/datum/technology/data/pcpu_normal
	name = "Computer Photonic Processor Unit"
	desc = "Computer Photonic Processor Unit"
	id = "pcpu_normal"

	x = 0.7
	y = 0.6
	icon = "pcpu"

	required_technologies = list("pcpu_small")
	required_tech_levels = list()
	cost = 1200

	unlocks_designs = list("pcpu_normal")

/datum/technology/data/modular_bat_micro
	name = "Small Battery Module's"
	desc = "Small Battery Module's"
	id = "modular_bat_micro"

	x = 0.6
	y = 0.4
	icon = "modular_bat_micro"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list("bat_nano", "bat_micro")

/datum/technology/data/modular_bat_advanced
	name = "Advanced Battery Module"
	desc = "Advanced Battery Module"
	id = "modular_bat_advanced"

	x = 0.6
	y = 0.5
	icon = "modular_bat_advanced"

	required_technologies = list("modular_bat_micro")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("bat_advanced")

/datum/technology/data/modular_bat_super
	name = "Super Battery Module"
	desc = "Super Battery Module"
	id = "modular_bat_super"

	x = 0.6
	y = 0.6
	icon = "modular_bat_super"

	required_technologies = list("modular_bat_advanced")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("bat_super")

/datum/technology/data/modular_bat_ultra
	name = "Ultra Battery Module"
	desc = "Ultra Battery Module"
	id = "modular_bat_ultra"

	x = 0.6
	y = 0.7
	icon = "modular_bat_ultra"

	required_technologies = list("modular_bat_super")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("bat_ultra")

/datum/technology/data/tesla_link
	name = "Tesla Link"
	desc = "Tesla Link"
	id = "tesla_link"

	x = 0.6
	y = 0.2
	icon = "tesla_link"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("teslalink")

/datum/technology/data/nanoprinter
	name = "Nanoprinter"
	desc = "Nanoprinter"
	id = "nanoprinter"

	x = 0.7
	y = 0.2
	icon = "nanoprinter"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("nanoprinter", "scan_paper")

/datum/technology/data/rfid
	name = "RFID Card Slot"
	desc = "RFID Card Slot"
	id = "rfid"

	x = 0.4
	y = 0.2
	icon = "rfid"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("cardslot","aislot","cardbroadcaster")

/datum/technology/data/adv_scanners
	name = "Advanced Scanning Modules"
	desc = "Advanced Scanning Modules"
	id = "adv_scanners"

	x = 0.8
	y = 0.3
	icon = "nanoprinter"

	required_technologies = list("basic_modular")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("scan_reagent", "scan_medical", "scan_atmos","scan_robotic")


/datum/technology/data/ai_laws
	name = "AI Laws"
	desc = "AI Laws"
	id = "ai_laws"

	x = 0.8
	y = 0.6
	icon = "aicircuit"

	required_technologies = list("pcpu_small")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("safeguard", "onehuman", "protectstation",  "notele", "quarantine", "oxygen", "purge", "reset", "freeform","borgupload")

/datum/technology/data/ai_laws_core
	name = "AI Core Laws"
	desc = "AI Core Laws"
	id = "ai_laws_core"

	x = 0.8
	y = 0.7
	icon = "aicircuit"

	required_technologies = list("ai_laws")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("freeformcore", "asimov", "paladin","aiupload")
