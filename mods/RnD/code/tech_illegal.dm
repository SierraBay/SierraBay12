/datum/technology/esoteric
	name = "Binary Encrpytion Key"
	desc = "Binary Encrpytion Key"
	id = "radiokey"
	tech_type = RESEARCH_ESOTERIC

	x = 0.5
	y = 0.5
	icon = "radiokey"

	required_technologies = list()
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("binaryencrypt")

/datum/technology/esoteric/bomb
	name = "large chem grenade"
	desc = "large chem grenade"
	id = "large_grenade"
	tech_type = RESEARCH_ESOTERIC

	x = 0.5
	y = 0.6
	icon = "kit"

	required_technologies = list("radiokey")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("large_Grenade")

/datum/technology/esoteric/chameleon_kit
	name = "Chameleon Kit"
	desc = "Chameleon Kit"
	id = "chameleon_kit"

	x = 0.5
	y = 0.7
	icon = "kit"

	required_technologies = list("large_grenade")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("chameleon")

/datum/technology/esoteric/portable_shield_diffuser
	name = "Portable Shield Diffuser"
	desc = "Portable Shield Diffuser"
	id = "portable_shield_diffuser"

	x = 0.6
	y = 0.6
	icon = "kit"

	required_technologies = list("chameleon_kit")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("portable_shield_diffuser")


/datum/technology/esoteric/freedom_implant
	name = "Silent and Dangerous"
	desc = "Silent and Dangerous"
	id = "freedom_implant"


	x = 0.4
	y = 0.5
	icon = "implantcase"

	required_technologies = list("radiokey")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("implant_free", "implant_adrenaline", "augment_wristblade")

/datum/technology/esoteric/borg_syndicate_module
	name = "Borg Illegal Module"
	desc = "Borg Illegal Module"
	id = "borg_syndicate_module"


	x = 0.6
	y = 0.5
	icon = "aicircuit"

	required_technologies = list("radiokey")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("borg_syndicate_module")

/datum/technology/esoteric/tyrant
	name = "T.Y.R.A.N.T."
	desc = "T.Y.R.A.N.T."
	id = "tyrant"

	x = 0.6
	y = 0.4
	icon = "aicircuit"

	required_technologies = list("borg_syndicate_module")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("tyrant")

/datum/technology/esoteric/explosive_implant
	name = "Loud and Dangerous"
	desc = "Loud and Dangerous"
	id = "explosive_implant"

	x = 0.4
	y = 0.6
	icon = "implantcase"

	required_technologies = list("freedom_implant")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("implant_explosive", "augment_popout_shotgun")

/datum/technology/esoteric/enet
	name = "Energy Net"
	desc = "Energy Net"
	id = "enet"

	x = 0.5
	y = 0.4
	icon = "hardsuitmodule"

	required_technologies = list("radiokey")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("rig_enet")


/datum/technology/esoteric/stealth
	name = "Active Camouflage"
	desc = "Active Camouflage"
	id = "stealth"

	x = 0.4
	y = 0.4
	icon = "hardsuitmodule"

	required_technologies = list("enet")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("rig_stealth")
