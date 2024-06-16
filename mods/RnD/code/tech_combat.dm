/datum/technology/combat
	name = "Security Equipment"
	desc = "Security Equipment"
	id = "sec_eq"
	tech_type = RESEARCH_COMBAT

	x = 0.1
	y = 0.5
	icon = "stunbaton"

	required_technologies = list()
	required_tech_levels = list()
	cost = 0

	unlocks_designs = list()

/datum/technology/combat/pris_man
	name = "Prisoner Managment"
	desc = "Prisoner Managment"
	id = "pris_man"

	x = 0.1
	y = 0.6
	icon = "seccomputer"

	required_technologies = list("sec_eq")
	required_tech_levels = list()
	cost = 250

	unlocks_designs = list("prisonmanage")

/datum/technology/combat/add_eq
	name = "Additional Security Equipment"
	desc = "Additional Security Equipment"
	id = "add_eq"

	x = 0.2
	y = 0.5
	icon = "add_sec_eq"

	required_technologies = list("sec_eq")
	required_tech_levels = list()
	cost = 500

	unlocks_designs = list("security_hud", "confuseray")

/datum/technology/combat/nleth_eq
	name = "Non-lethal Eqiupment"
	desc = "Additional Security Equipment"
	id = "nleth_eq"

	x = 0.3
	y = 0.5
	icon = "adflash"

	required_technologies = list("add_eq")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("advancedflash", "stunrevolver")

/datum/technology/combat/riotgun
	name = "Riot Gun"
	desc = "Riot Gun"
	id = "riotgun"

	x = 0.4
	y = 0.5
	icon = "riotgun"

	required_technologies = list("nleth_eq")
	required_tech_levels = list()
	cost = 1250

	unlocks_designs = list("grenadelauncher", "flechette" , "tactical_goggles")

/datum/technology/combat/pguns
	name = "Scientific Precision Guns"
	desc = "Scientific Precision Guns"
	id = "decloner"

	x = 0.4
	y = 0.4
	icon = "decloner"

	required_technologies = list("riotgun")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("ppistol", "decloner")

/datum/technology/combat/smg
	name = "SMGs"
	desc = "SMGs"
	id = "smg"

	x = 0.5
	y = 0.5
	icon = "divet"

	required_technologies = list("riotgun")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("wt550", "smg")

/datum/technology/combat/speedloader
	name = "Speed Loader (.44 Magnum)"
	desc = "Speed Loader (.44 Magnum)"
	id = "speedloader"

	x = 0.5
	y = 0.6
	icon = "speedloader"

	required_technologies = list("divet")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("bullpup")

/datum/technology/combat/shock
	name = "Shock Weapons"
	desc = "Shock Weapons"
	id = "shock"

	x = 0.6
	y = 0.5
	icon = "shock"

	required_technologies = list("smg")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("stun_rifle")

/datum/technology/combat/laser
	name = "Laser Weapons"
	desc = "Laser Weapons"
	id = "laser"

	x = 0.6
	y = 0.6
	icon = "laser"

	required_technologies = list("shock")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("lasercannon")

/datum/technology/combat/ripper
	name = "RC-DS Remote Control Disc Ripper"
	desc = "RC-DS Remote Control Disc Ripper"
	id = "ripper"

	x = 0.6
	y = 0.4
	icon = "ripper"

	required_technologies = list("pulse")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("ripper", "ripper_blades")

/datum/technology/combat/dblades
	name = "Diamond Blades"
	desc = "Diamond Blades"
	id = "dblades"

	x = 0.7
	y = 0.4
	icon = "dblades"

	required_technologies = list("ripper")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("diamond_blades")

/datum/technology/combat/javeline
	name = "T15 Javelin Gun"
	desc = "T15 Javelin Gun"
	id = "javeline"

	x = 0.7
	y = 0.6
	icon = "javeline"

	required_technologies = list("pulse")
	required_tech_levels = list()
	cost = 2000

	unlocks_designs = list("javgun")

/datum/technology/combat/seeker
	name = "Seeker Rifle"
	desc = "Seeker Rifle"
	id = "seeker"

	x = 0.8
	y = 0.5
	icon = "seeker"

	required_technologies = list("pulse")
	required_tech_levels = list()
	cost = 3500

	unlocks_designs = list("seeker", "seeker_ammo")
