/datum/gear/uniform/utility
	display_name = "utility uniform"
	path = /obj/item/clothing/under/solgov/utility

/datum/gear/uniform/roboticist_skirt
	allowed_roles = list(/datum/job/roboticist)

/datum/gear/uniform/sterile
	allowed_roles = STERILE_ROLES

/datum/gear/uniform/hazard
	allowed_roles = TECHNICAL_ROLES

/* SIERRA TODO: watch for contractors uniforms, may be in mods
/datum/gear/uniform/corpsi
	display_name = "contractor uniform selection"
	path = /obj/item/clothing/under/solgov/utility
	allowed_branches = list(/datum/mil_branch/contractor)
*/

/datum/gear/uniform/si_guard
	display_name = "NanoTrasen guard uniform"
	path = /obj/item/clothing/under/rank/guard/nanotrasen
	allowed_roles = list(/datum/job/officer)

/datum/gear/uniform/si_exec
	display_name = "NanoTrasen senior researcher alt uniform"
	path = /obj/item/clothing/under/rank/scientist/executive/nanotrasen
	allowed_roles = list(/datum/job/senior_scientist)

/datum/gear/uniform/si_overalls
	display_name = "corporate coveralls"
	path = /obj/item/clothing/under/rank/ntwork
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)

/datum/gear/uniform/si_overalls/New()
	..()
	var/overalls = list()
	overalls["NT beige and red coveralls"]			= /obj/item/clothing/under/rank/ntwork/nanotrasen
	overalls["Hephaestus grey and cyan coveralls"]	= /obj/item/clothing/under/rank/ntwork/heph
	gear_tweaks += new/datum/gear_tweak/path(overalls)

/datum/gear/uniform/si_flight
	display_name = "corporate pilot suit"
	path = /obj/item/clothing/under/rank/ntpilot
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)

/datum/gear/uniform/si_flight/New()
	..()
	var/flight = list()
	flight["NT red flight suit"]			= /obj/item/clothing/under/rank/ntpilot/nanotrasen
	flight["Hephaestus cyan flight suit"]	= /obj/item/clothing/under/rank/ntpilot/heph
	gear_tweaks += new/datum/gear_tweak/path(flight)

/datum/gear/uniform/harness
	display_name = "gear harness (Full Body Prosthetic, Diona, Giant Armoured Serpentid)"
	path = /obj/item/clothing/under/harness

/datum/gear/uniform/si_exec_jacket
	display_name = "NanoTrasen liason suit"
	path = /obj/item/clothing/under/suit_jacket/corp/nanotrasen
	allowed_roles = list(/datum/job/iaa, /datum/job/iso)

/datum/gear/uniform/formal_shirt_and_pants
	display_name = "formal shirts with pants"
	path = /obj/item/clothing/under/suit_jacket

/datum/gear/uniform/formal_shirt_and_pants/New()
	..()
	var/list/shirts = list()
	shirts += /obj/item/clothing/under/suit_jacket/charcoal
	shirts += /obj/item/clothing/under/suit_jacket/navy
	shirts += /obj/item/clothing/under/suit_jacket/burgundy
	shirts += /obj/item/clothing/under/suit_jacket/checkered
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(shirts)

/datum/gear/uniform/retro_security
	display_name = "retro security officer's uniform"
	allowed_roles = SECURITY_ROLES
	path = /obj/item/clothing/under/retro/security

/datum/gear/uniform/retro_medical
	display_name = "retro medical officer's uniform"
	allowed_roles = STERILE_ROLES
	path = /obj/item/clothing/under/retro/medical

/datum/gear/uniform/retro_engineering
	display_name = "retro engineering uniform"
	allowed_roles = TECHNICAL_ROLES
	path = /obj/item/clothing/under/retro/engineering

/datum/gear/uniform/retro_science
	display_name = "retro science officer's uniform"
	allowed_roles = RESEARCH_ROLES
	path = /obj/item/clothing/under/retro/science

/datum/gear/suit/unathi/officer_uniform
	allowed_roles = SECURITY_ROLES


//papaleroy and honk
/datum/gear/uniform/cargo_trousers
	display_name = "cargo trousers"
	path = /obj/item/clothing/under/new_uniform/cargo_trousers

/datum/gear/uniform/cargo_pants
	display_name = "cargo pants"
	path = /obj/item/clothing/under/new_uniform/cargos

/datum/gear/uniform/neotac
	display_name = "neotac pants"
	path = /obj/item/clothing/under/new_uniform/neotac

/datum/gear/uniform/breeches
	display_name = "denim breeches"
	path = /obj/item/clothing/under/new_uniform/breeches

/datum/gear/uniform/gorka_pants
	display_name = "gorka pants"
	path = /obj/item/clothing/under/new_uniform/gorka_pants

/datum/gear/uniform/gorka_pants/New()
	..()
	var/uniforms = list()
	uniforms["olive gorka pants"]			= /obj/item/clothing/under/new_uniform/gorka_pants
	uniforms["tan gorka pants"]			= /obj/item/clothing/under/new_uniform/gorka_pants/tan
	uniforms["blue gorka pants"]			= /obj/item/clothing/under/new_uniform/gorka_pants/blue
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/netrunner
	path = /obj/item/clothing/under/new_uniform/netrunner
	display_name = "specialized netrunner suit"

/datum/gear/uniform/plain_suit
	display_name = "white plain suit"
	path = /obj/item/clothing/under/new_uniform/plain_suit

/datum/gear/uniform/plain_suit/New()
	var/uniforms = list()
	uniforms["white plain suit"]			= /obj/item/clothing/under/new_uniform/plain_suit
	uniforms["dark plain suit"]			= /obj/item/clothing/under/new_uniform/plain_suit/dark
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/kitsch_dress
	display_name = "kitsch dress"
	path = /obj/item/clothing/under/new_uniform/kitsch_dress

/datum/gear/uniform/kitsch_dress/New()
	var/uniforms = list()
	uniforms["Blue-yellow kitsch dress"]			= /obj/item/clothing/under/new_uniform/kitsch_dress
	uniforms["Gray-violet kitsch dress"]			= /obj/item/clothing/under/new_uniform/kitsch_dress/second
	uniforms["White-dark kitsch dress"]			= /obj/item/clothing/under/new_uniform/kitsch_dress/third
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/cherry_suit
	display_name = "cherry suit"
	path = /obj/item/clothing/under/new_uniform/cherry_suit

/datum/gear/uniform/bdu
	display_name = "BDU suite"
	path = /obj/item/clothing/under/new_uniform/bdu

/datum/gear/uniform/ems
	display_name = "emergency medical responder's jumpsuit"
	path = /obj/item/clothing/under/new_uniform/ems


/datum/gear/uniform/ems/New()
	var/uniforms = list()
	uniforms["dark ems suit"]			= /obj/item/clothing/under/new_uniform/ems
	uniforms["white ems suit"]			= /obj/item/clothing/under/new_uniform/ems/white
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/papaleroy_rubiwhite
	display_name = "rubiwhite"
	path = /obj/item/clothing/under/new_uniform/papaleroy_rubiwhite


/datum/gear/uniform/skirt_c
	display_name = "short skirt, colour select"
	path = /obj/item/clothing/under/skirt_c
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/longskirt
	display_name = "long skirt, colour select"
	path = /obj/item/clothing/under/skirt/longskirt
	flags = GEAR_HAS_COLOR_SELECTION


//remission
/datum/gear/uniform/woman_business_uniform
	display_name = "woman business suit"
	path = /obj/item/clothing/under/new_uniform/woman_business_uniform

/datum/gear/uniform/woman_business_uniform/New()
	..()
	var/uniforms = list()
	uniforms["blue vest suit"] = /obj/item/clothing/under/new_uniform/woman_business_uniform
	uniforms["red suit"] = /obj/item/clothing/under/new_uniform/woman_business_uniform/red
	uniforms["azure suit"] = /obj/item/clothing/under/new_uniform/woman_business_uniform/azure
	uniforms["blue skirt suit"] = /obj/item/clothing/under/new_uniform/woman_business_uniform/dress
	uniforms["plaid dress"] = /obj/item/clothing/under/new_uniform/woman_business_uniform/plaid
	uniforms["black dress"] = /obj/item/clothing/under/new_uniform/woman_business_uniform/black
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/heartneck_dress
	display_name = "black heart neckline dress"
	path = /obj/item/clothing/under/new_uniform/heartneck_dress


/datum/gear/uniform/camo_brown
	display_name = "dark olive camo jumpsuit"
	path = /obj/item/clothing/under/new_uniform/camo_brown

/datum/gear/uniform/plaid_colored_dress
	display_name = "colorable plaid dress"
	path = /obj/item/clothing/under/new_uniform/plaid_colored_dress
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/plaid_colored_dress/New()
	..()
	var/uniforms = list()
	uniforms["plaid"] = /obj/item/clothing/under/new_uniform/plaid_colored_dress
	uniforms["straight"] = /obj/item/clothing/under/new_uniform/plaid_colored_dress/war2
	uniforms["short sleeve"] = /obj/item/clothing/under/new_uniform/plaid_colored_dress/war3
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/office_skirt
	display_name = "colorable skirts"
	path = /obj/item/clothing/under/new_uniform/office_skirt
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/office_skirt/New()
	..()
	var/uniforms = list()
	uniforms["mini"] = /obj/item/clothing/under/new_uniform/office_skirt
	uniforms["bell"] = /obj/item/clothing/under/new_uniform/office_skirt/wavy
	uniforms["slit"] = /obj/item/clothing/under/new_uniform/office_skirt/slit
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/camopants
	display_name = "multicam pants"
	path = /obj/item/clothing/under/new_uniform/camopants

/datum/gear/uniform/camopants/New()
	..()
	var/uniforms = list()
	uniforms["camo"] = /obj/item/clothing/under/new_uniform/camopants
	uniforms["baggy sand"] = /obj/item/clothing/under/new_uniform/camopants/baggy
	uniforms["grey"] = /obj/item/clothing/under/new_uniform/camopants/grey
	uniforms["baggy grey"] = /obj/item/clothing/under/new_uniform/camopants/greybaggy
	gear_tweaks += new/datum/gear_tweak/path(uniforms)


/datum/gear/uniform/shortsmini
	display_name = "very short shorts"
	path = /obj/item/clothing/under/new_uniform/shortsmini

/datum/gear/uniform/shortsmini/New()
	..()
	var/uniforms = list()
	uniforms["black"] = /obj/item/clothing/under/new_uniform/shortsmini
	uniforms["camo"] = /obj/item/clothing/under/new_uniform/shortsmini/camo
	uniforms["denim"] = /obj/item/clothing/under/new_uniform/shortsmini/denim
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/scutracksuit
	display_name = "scuba tracksuit"
	path = /obj/item/clothing/under/new_uniform/scutracksuit

/datum/gear/uniform/scutracksuit/New()
	..()
	var/uniforms = list()
	uniforms["blue-red"] = /obj/item/clothing/under/new_uniform/scutracksuit
	uniforms["red-white"] = /obj/item/clothing/under/new_uniform/scutracksuit/red
	uniforms["black-white"] = /obj/item/clothing/under/new_uniform/scutracksuit/black
	gear_tweaks += new/datum/gear_tweak/path(uniforms)

/datum/gear/uniform/runningpants
	display_name = "running pants"
	path = /obj/item/clothing/under/new_uniform/runningpants

/datum/gear/uniform/runningpants/New()
	..()
	var/uniforms = list()
	uniforms["blue-red"] = /obj/item/clothing/under/new_uniform/runningpants
	uniforms["red-white"] = /obj/item/clothing/under/new_uniform/runningpants/red
	uniforms["black-white"] = /obj/item/clothing/under/new_uniform/runningpants/black
	gear_tweaks += new/datum/gear_tweak/path(uniforms)
