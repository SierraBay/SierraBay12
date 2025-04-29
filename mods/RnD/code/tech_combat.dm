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

	unlocks_designs = list("security_hud")

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

	unlocks_designs = list("security_hud")

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

/datum/technology/combat/spguns
	name = "Scientific Precision Guns"
	desc = "Scientific Precision Guns"
	id = "spguns"

	x = 0.5
	y = 0.4
	icon = "decloner"

	required_technologies = list("shock")
	required_tech_levels = list()
	cost = 1000

	unlocks_designs = list("ppistol", "decloner","disperserfront","dispersermiddle","bsaback", "disperser_console")


/datum/technology/combat/shock
	name = "Shock Weapons"
	desc = "Shock Weapons"
	id = "shock"

	x = 0.5
	y = 0.5
	icon = "shock"

	required_technologies = list("riotgun")
	required_tech_levels = list()
	cost = 2500

	unlocks_designs = list("stun_rifle", "stunshell")

/datum/technology/combat/laser
	name = "Laser Weapons"
	desc = "Laser Weapons"
	id = "laser"

	x = 0.5
	y = 0.6
	icon = "laser"

	required_technologies = list("shock")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("lasercannon")

/datum/technology/combat/wt550
	name = "WT550"
	desc = "WT550"
	id = "wt550"

	x = 0.6
	y = 0.5
	icon = "wt550"

	required_technologies = list("shock")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("wt550", "ammo_small","pointdefense","pointdefense_control")

/datum/technology/combat/smg
	name = "SMG"
	desc = "SMG"
	id = "smg"

	x = 0.6
	y = 0.6
	icon = "smg"

	required_technologies = list("wt550")
	required_tech_levels = list()
	cost = 750

	unlocks_designs = list("smg", "ammo_flechette")



/datum/technology/combat/bullpup
	name = "Bullpup"
	desc = "Bullpup"
	id = "bullpup"

	x = 0.6
	y = 0.4
	icon = "bullpup"

	required_technologies = list("wt550")
	required_tech_levels = list()
	cost = 1500

	unlocks_designs = list("bullpup")


/datum/technology/combat/emiammo
	name = "EMP Ammo"
	desc = "EMP Ammo"
	id = "emiammo"

	x = 0.7
	y = 0.5
	icon = "emiammo"

	required_technologies = list("wt550")
	required_tech_levels = list()
	cost = 3500

	unlocks_designs = list("ammo_emp_slug", "ammo_emp_pistol", "ammo_emp_small")
