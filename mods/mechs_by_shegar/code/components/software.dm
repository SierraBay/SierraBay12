/obj/item/circuitboard/exosystem
	name = "exosuit software template"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	var/list/contains_software = list()

/obj/item/circuitboard/exosystem/engineering
	name = "exosuit software (engineering systems)"
	contains_software = list(MECH_SOFTWARE_ENGINEERING)
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)

/obj/item/circuitboard/exosystem/utility
	name = "exosuit software (utility systems)"
	contains_software = list(MECH_SOFTWARE_UTILITY)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1)

/obj/item/circuitboard/exosystem/medical
	name = "exosuit software (medical systems)"
	contains_software = list(MECH_SOFTWARE_MEDICAL)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1,TECH_BIO = 1)

/obj/item/circuitboard/exosystem/weapons
	name = "exosuit software (basic weapon systems)"
	contains_software = list(MECH_SOFTWARE_WEAPONS)
	icon_state = "mainboard"
	origin_tech = list(TECH_DATA = 1, TECH_COMBAT = 3)
