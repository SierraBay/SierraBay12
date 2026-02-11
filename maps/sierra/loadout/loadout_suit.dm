/datum/gear/suit/medcoat
	allowed_roles = MEDICAL_ROLES

/datum/gear/suit/sierra_medcoat
	allowed_roles = MEDICAL_ROLES

/datum/gear/suit/poncho
	display_name = "poncho selection"
	path = /obj/item/clothing/suit/poncho

/datum/gear/suit/poncho/New()
	flags = null
	..()
	var/ponchos = list()
	ponchos += /obj/item/clothing/suit/poncho
	ponchos += /obj/item/clothing/suit/poncho/red
	ponchos += /obj/item/clothing/suit/poncho/blue
	ponchos += /obj/item/clothing/suit/poncho/purple
	ponchos += /obj/item/clothing/suit/poncho/green
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(ponchos)

/datum/gear/suit/security_poncho
	allowed_roles = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer,   )

/datum/gear/suit/medical_poncho
	allowed_roles = list(/datum/job/cmo, /datum/job/senior_doctor, /datum/job/doctor, /datum/job/doctor_trainee, /datum/job/explorer_medic, /datum/job/psychiatrist, /datum/job/chemist, /datum/job/roboticist,   )

/datum/gear/suit/engineering_poncho
	allowed_roles = list(/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/roboticist, /datum/job/engineer_trainee, /datum/job/explorer_engineer,   /datum/job/infsys)

/datum/gear/suit/science_poncho
	allowed_roles = list(/datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/roboticist,   )

/datum/gear/suit/cargo_poncho
	allowed_roles = list(/datum/job/qm, /datum/job/cargo_tech, /datum/job/cargo_assistant,   )

/datum/gear/suit/wintercoat/engineering
	display_name = "expeditionary winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/solgov
	allowed_roles = EXPLORATION_ROLES

/datum/gear/suit/wintercoat/engineering
	display_name = "engineering winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/engineering
	allowed_roles = ENGINEERING_ROLES

/datum/gear/suit/wintercoat/cargo
	display_name = "cargo winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/cargo
	allowed_roles = SUPPLY_ROLES

/datum/gear/suit/wintercoat/medical
	display_name = "medical winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/medical
	allowed_roles = MEDICAL_ROLES

/datum/gear/suit/wintercoat/security
	display_name = "security winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/security
	allowed_roles = SECURITY_ROLES

/datum/gear/suit/wintercoat/research
	display_name = "science winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/science
	allowed_roles = list(/datum/job/rd, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/senior_scientist, /datum/job/roboticist,     )

/datum/gear/suit/wintercoat_dais
	display_name = "winter coat, DAIS"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat/dais
	allowed_roles = list(/datum/job/engineer, /datum/job/scientist, /datum/job/scientist_assistant, /datum/job/roboticist, /datum/job/infsys)
	allowed_branches = list(/datum/mil_branch/contractor)

/datum/gear/suit/labcoat
	allowed_roles = STERILE_ROLES

/datum/gear/suit/labcoat_corp_si
	display_name = "Corporate labcoat"
	path = /obj/item/clothing/suit/storage/toggle/labcoat/science
	allowed_roles = RESEARCH_ROLES
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)

/datum/gear/suit/labcoat_corp_si/New()
	..()
	var/labcoatsi = list()
	labcoatsi += /obj/item/clothing/suit/storage/toggle/labcoat/science/nanotrasen
	labcoatsi += /obj/item/clothing/suit/storage/toggle/labcoat/science/heph
	labcoatsi += /obj/item/clothing/suit/storage/toggle/labcoat/science/xynergy
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(labcoatsi)

/datum/gear/suit/labcoat_dais
	display_name = "labcoat, DAIS"
	path = /obj/item/clothing/suit/storage/toggle/labcoat/science/dais
	allowed_roles = list(/datum/job/engineer, /datum/job/scientist, /datum/job/roboticist, /datum/job/infsys)
	allowed_branches = list(/datum/mil_branch/contractor)

/datum/gear/suit/militaryjacket
	display_name = "military jacket"
	path = /obj/item/clothing/suit/storage/tgbomber/militaryjacket

/datum/gear/suit/snakeskin
	display_name = "snakeskin coat"
	path = /obj/item/clothing/suit/snakeskin

/datum/gear/suit/unathi/security_jacket
	allowed_roles = SECURITY_ROLES

/datum/gear/suit/sfp
	display_name = "SFP agent jackets"
	path = /obj/item/clothing/suit/storage
	allowed_roles = list(
		/datum/job/detective
	)

/datum/gear/suit/sfp/New()
	..()
	var/list/options = list()
	options["SFP leather jacket"] = /obj/item/clothing/suit/storage/toggle/agent_jacket
	options["formal SFP jacket"] = /obj/item/clothing/suit/storage/toggle/agent_jacket/formal
	options["SFP patrol cloak"] = /obj/item/clothing/suit/storage/agent_rain
	gear_tweaks += new/datum/gear_tweak/path(options)

//papa leroy and honk
/datum/gear/suit/shortcoat
	display_name = "shortcoat"
	path = /obj/item/clothing/suit/new_suits/shortcoat

/datum/gear/suit/freefit_shirt
	display_name = "freefit shirt"
	path = /obj/item/clothing/suit

/datum/gear/suit/freefit_shirt/New()
	. = ..()
	var/list/options = list()
	options["blue freefit shirt"] = /obj/item/clothing/suit/new_suits/freefit_shirt
	options["black freefit shirt with red stripes"] = /obj/item/clothing/suit/new_suits/freefit_shirt/second
	options[ "black freefit shirt with yellow stripes"] = /obj/item/clothing/suit/new_suits/freefit_shirt/third
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/cropped_shirt
	display_name = "cropped shirt"
	path = /obj/item/clothing/suit

/datum/gear/suit/cropped_shirt/New()
	. = ..()
	var/list/options = list()
	options["black and red cropped sweater"] = /obj/item/clothing/suit/new_suits/crop_sweater
	options["black and yellow cropped sweater"] = /obj/item/clothing/suit/new_suits/crop_sweater/second
	options["white cropped sweater"] = /obj/item/clothing/suit/new_suits/crop_sweater/third
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/denim_jacket
	display_name = "denim jacket"
	path = /obj/item/clothing/suit/new_suits/denim_jacket

/datum/gear/suit/rugby
	display_name = "Rugby"
	path = /obj/item/clothing/suit

/datum/gear/suit/rugby/New()
	. = ..()
	var/list/options = list()
	options["red rugby"] = /obj/item/clothing/suit/new_suits/rugby
	options["black rugby"] = /obj/item/clothing/suit/new_suits/rugby/black
	options["blue rugby"] = /obj/item/clothing/suit/new_suits/rugby/blue
	options["brown rugby"] = /obj/item/clothing/suit/new_suits/rugby/brown
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/enjijacket
	display_name = "engineer jacket"
	path = /obj/item/clothing/suit/new_suits/engjacket

/datum/gear/suit/cargo_jacket
	display_name = "cargo jacket"
	path = /obj/item/clothing/suit/new_suits/cargojacket

/datum/gear/suit/cool_jacket
	display_name = "cool jacket"
	path = /obj/item/clothing/suit/new_suits/amizov

/datum/gear/suit/grimjacket
	display_name = "grim jacket"
	path = /obj/item/clothing/suit/new_suits/grimjacket

/datum/gear/suit/bomber_navy
	display_name = "bomber navy"
	path = /obj/item/clothing/suit/storage/toggle/bomber_navy


/datum/gear/suit/gorka
	display_name = "gorka suit"
	path = /obj/item/clothing/suit/storage/hooded/hoodie/gorka

/datum/gear/suit/gorka/New()
	. = ..()
	var/list/options = list()
	options["olive gorka"] = /obj/item/clothing/suit/storage/hooded/hoodie/gorka
	options["tan gorka"] = /obj/item/clothing/suit/storage/hooded/hoodie/gorka/tan
	options["blue gorka"] = /obj/item/clothing/suit/storage/hooded/hoodie/gorka/blue
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/neo_blaser
	display_name = "neokitsch blaser"
	path = /obj/item/clothing/suit/color/storage/neo_blaser
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/neo_blaser/New()
	. = ..()
	var/list/options = list()
	options["man"] = /obj/item/clothing/suit/color/storage/neo_blaser
	options["female"] = /obj/item/clothing/suit/color/storage/neo_blaser/female
	gear_tweaks += new/datum/gear_tweak/path(options)

//У одежды ниже ломается выбор цвета, описания и прочий кал. Почему? Если бы я знал
//TODO: починить джакеты ниже
/datum/gear/suit/neo_jacket
	display_name = "neo jacket"
	path = /obj/item/clothing/suit/color/storage/neo_jacket
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/neo_jacket/New()
	var/list/options = list()
	options["man"] = /obj/item/clothing/suit/color/storage/neo_jacket
	options["female"] = /obj/item/clothing/suit/color/storage/neo_jacket/female
	gear_tweaks += new/datum/gear_tweak/path(options)



//Nasrano Remission

/datum/gear/suit/eng_bomber
	display_name = "engineer bomber"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber
	allowed_roles = ENGINEERING_ROLES

/datum/gear/suit/eng_bomber/New()
	. = ..()
	var/list/options = list()
	options["engineer"] = /obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber
	options["atmos"] = /obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/atmos
	options["engineer grey"] = /obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/work
	options["engineer white"] = /obj/item/clothing/suit/storage/toggle/new_suit/eng_bomber/white
	gear_tweaks += new/datum/gear_tweak/path(options)


/datum/gear/suit/leather_fur_jacket
	display_name = "leather fur suits"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket

/datum/gear/suit/leather_fur_jacket/New()
	. = ..()
	var/list/options = list()
	options["brown jacket"] = /obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket
	options["grey jacket"] = /obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/grey
	options["brown coat"] = /obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/coat
	options["grey coat"] = /obj/item/clothing/suit/storage/toggle/new_suit/leather_fur_jacket/greycoat
	gear_tweaks += new/datum/gear_tweak/path(options)


/datum/gear/suit/work_bomber
	display_name = "work jackets"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/work_bomber

/datum/gear/suit/work_bomber/New()
	. = ..()
	var/list/options = list()
	options["orange jacket"] = /obj/item/clothing/suit/storage/toggle/new_suit/work_bomber
	options["yellow jacket"] = /obj/item/clothing/suit/storage/toggle/new_suit/work_bomber/yellow
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/sport_jacket
	display_name = "sport jackets"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/sport_jacket

/datum/gear/suit/sport_jacket/New()
	. = ..()
	var/list/options = list()
	options["blue-white"] = /obj/item/clothing/suit/storage/toggle/new_suit/sport_jacket
	options["black-white"] = /obj/item/clothing/suit/storage/toggle/new_suit/sport_jacket/blackwhite
	gear_tweaks += new/datum/gear_tweak/path(options)


/datum/gear/suit/biker_jacket
	display_name = "biker jacket"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket

/datum/gear/suit/biker_jacket/New()
	. = ..()
	var/list/options = list()
	options["black"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket
	options["distressed"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/dis
	options["skull"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/skull
	options["heart"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/heart
	options["dragon"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/dragon
	options["devil"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/devil
	options["posh"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/posh
	options["fire"] = /obj/item/clothing/suit/storage/toggle/new_suit/biker_jacket/fire
	gear_tweaks += new/datum/gear_tweak/path(options)


/datum/gear/suit/levis_bomber
	display_name = "denim bomber jacket"
	path = /obj/item/clothing/suit/storage/levis_bomber


/datum/gear/suit/multicam_jacket
	display_name = "multicam jacket"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket

/datum/gear/suit/multicam_jacket/New()
	. = ..()
	var/list/options = list()
	options["camo"] = /obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket
	options["sand"] = /obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket/sand
	options["grey"] = /obj/item/clothing/suit/storage/toggle/new_suit/multicam_jacket/grey
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/tracksuits
	display_name = "tracksuits"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/tracksuits

/datum/gear/suit/tracksuits/New()
	. = ..()
	var/list/options = list()
	options["black"] = /obj/item/clothing/suit/storage/toggle/new_suit/tracksuits
	options["red"] = /obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/red
	options["blue"] = /obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/blue
	options["green"] = /obj/item/clothing/suit/storage/toggle/new_suit/tracksuits/green
	gear_tweaks += new/datum/gear_tweak/path(options)

/datum/gear/suit/sporthoodie
	display_name = "sport hoodie"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie

/datum/gear/suit/sporthoodie/New()
	. = ..()
	var/list/options = list()
	options["crimson"] = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie
	options["red"] = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/red
	options["blue"] = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/blue
	options["red-white"] = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/rw
	options["black"] = /obj/item/clothing/suit/storage/toggle/new_suit/sporthoodie/black
	gear_tweaks += new/datum/gear_tweak/path(options)


/datum/gear/suit/colorhoodie
	display_name = "hooded jacket colour select"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/colorhoodie
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/trench
	display_name = "trenchcoat"
	path = /obj/item/clothing/suit/storage/toggle/new_suit/trench

// Other robes
/datum/gear/suit/moonlightrobe
	display_name = "moonlight robe"
	allowed_roles = SERVICE_ROLES
	path = /obj/item/clothing/suit/storage/hooded/moonrobe

/datum/gear/suit/sc_labcoat
	display_name = "robotic bathrobe"
	path = /obj/item/clothing/suit/sc_labcoat
	allowed_roles = list(/datum/job/rd, /datum/job/senior_scientist, /datum/job/roboticist,   )
