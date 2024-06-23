/datum/gear/head/surgical
	allowed_roles = STERILE_ROLES

/datum/gear/head/hardhat
	allowed_roles = TECHNICAL_ROLES

/datum/gear/head/welding
	allowed_roles = TECHNICAL_ROLES
/*
/datum/gear/head/scp_cap
	allowed_roles = list(/datum/job/detective, /datum/job/officer)
	allowed_branches = list(/datum/mil_branch/contractor)
*/

/datum/gear/head/beret_selection_contractor
	display_name = "contractor beret selection"
	description = "A list of berets used by various organizations and corporights."
	path = /obj/item/clothing/head/beret
	allowed_roles = SECURITY_ROLES
	allowed_branches = list(/datum/mil_branch/contractor)

/datum/gear/head/beret_selection_contractor/New()
	..()
	var/beret_selection_type = list()
	beret_selection_type["SAARE beret"] = /obj/item/clothing/head/beret/sec/corporate/saare
	beret_selection_type["PCRC beret"] = /obj/item/clothing/head/beret/sec/corporate/pcrc
	beret_selection_type["ZPCI beret"] = /obj/item/clothing/head/beret/sec/corporate/zpci
	gear_tweaks += new/datum/gear_tweak/path(beret_selection_type)

/datum/gear/head/beret_selection_security
	display_name = "security berets selection"
	description = "A list of berets used by NanoTrasen security."
	path = /obj/item/clothing/head/beret
	allowed_roles = SECURITY_ROLES

/datum/gear/head/beret_selection_security/New()
	..()
	var/beret_selection_type = list()
	beret_selection_type["white-blue security beret"] = /obj/item/clothing/head/beret/guard/sierra1
	beret_selection_type["white-red security beret"] = /obj/item/clothing/head/beret/sec/corporate/whitered
	beret_selection_type["black security beret"] = /obj/item/clothing/head/beret/sec/corporate/officer/sierra1
	beret_selection_type["red security beret"] = /obj/item/clothing/head/beret/sec/sierra1
	gear_tweaks += new/datum/gear_tweak/path(beret_selection_type)

/datum/gear/head/soft_selection_security
	display_name = "security softcaps selection"
	description = "A list of softcaps used by NanoTrasen security."
	path = /obj/item/clothing/head/soft
	allowed_roles = SECURITY_ROLES

/datum/gear/head/soft_selection_security/New()
	..()
	var/soft_selection_type = list()
	soft_selection_type["white security cap"] = /obj/item/clothing/head/soft/sec/corp/guard/sierra1
	soft_selection_type["red security cap"] = /obj/item/clothing/head/soft/sec/sierra1
	soft_selection_type["black security cap"] = /obj/item/clothing/head/soft/sec/corp/sierra1
	gear_tweaks += new/datum/gear_tweak/path(soft_selection_type)

/datum/gear/suit/unathi/security_cap
	allowed_roles = SECURITY_ROLES
