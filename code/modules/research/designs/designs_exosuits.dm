/datum/design/circuit/exosuit
	category = list("Exosuit")

/datum/design/circuit/exosuit/AssembleDesignDesc()
	desc = "Allows for the construction of \a [name] module."

/datum/design/circuit/exosuit/engineering
	name = "engineering system control"
	id = "mech_software_engineering"
	req_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	build_path = /obj/item/circuitboard/exosystem/engineering
	sort_string = "NAAAA"

/datum/design/circuit/exosuit/utility
	name = "utility system control"
	id = "mech_software_utility"
	req_tech = list(TECH_DATA = 1)
	build_path = /obj/item/circuitboard/exosystem/utility
	sort_string = "NAAAB"

/datum/design/circuit/exosuit/medical
	name = "medical system control"
	id = "mech_software_medical"
	req_tech = list(TECH_DATA = 1,TECH_BIO = 1)
	build_path = /obj/item/circuitboard/exosystem/medical
	sort_string = "NAABA"

/datum/design/circuit/exosuit/weapons
	name = "basic weapon control"
	id = "mech_software_weapons"
	req_tech = list(TECH_DATA = 1, TECH_COMBAT = 3)
	build_path = /obj/item/circuitboard/exosystem/weapons
	sort_string = "NAACA"
