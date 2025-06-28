/mob/living/silicon/robot
	icon = 'mods/infinity_content/icons/robots.dmi'

/mob/living/silicon/robot/flying
	icon = 'mods/infinity_content/icons/robots_flying.dmi'

/obj/item/robot_module/clerical/butler
	sprites = list(
		"Waitress" = "Service",
		"Kent" = "toiletbot",
		"Bro" = "Brobot",
		"Rich" = "maximillion",
		"Basic" = "Service2",
		"Default" = "robotServ"
	)

/obj/item/robot_module/clerical/general
	sprites = list(
		"Waitress" = "Service",
		"Kent" =     "toiletbot",
		"Bro" =      "Brobot",
		"Rich" =     "maximillion",
		"Basic" =  "Service2",
		"Default" = "robotCler"
	)

/obj/item/robot_module/engineering
	sprites = list(
		"Basic" = "Engineering",
		"Antique" = "engineerrobot",
		"Landmate" = "landmate",
		"Landmate - Treaded" = "engiborg+tread",
		"Motile" = "motile-eng",
		"Default" = "robotEngi"
	)

/obj/item/robot_module/engineering/Initialize()
	equipment += /obj/item/rpd

	. = ..()

/obj/item/robot_module/janitor
	name = "janitorial robot module"
	display_name = "Janitor"
	channels = list(
		"Service" = TRUE
	)
	sprites = list(
		"Basic" = "JanBot2",
		"Mopbot"  = "janitorrobot",
		"Mop Gear Rex" = "mopgearrex",
		"Motile" = "motile",
		"Default" = "robotJani"
	)

/obj/item/robot_module/medical/crisis
	sprites = list(
		"Basic" = "Medbot",
		"Standard" = "surgeon",
		"Advanced Droid" = "droid-medical",
		"Needles" = "medicalrobot",
		"Default" = "robotMedi"
	)

/obj/item/robot_module/miner
	sprites = list(
		"Basic" = "Miner_old",
		"Advanced Droid" = "droid-miner",
		"Treadhead" = "Miner",
		"Default" = "robotMine"
	)

/obj/item/robot_module/security/general
	sprites = list(
		"Basic" = "secborg",
		"Red Knight" = "Security",
		"Black Knight" = "securityrobot",
		"Bloodhound" = "bloodhound",
		"Bloodhound - Treaded" = "secborg+tread",
		"Tridroid" = "orb-security",
		"Motile" = "motile-sec",
	)

/obj/item/robot_module/standard
	sprites = list(
		"Basic" = "robot_old",
		"Android" = "droid",
		"Default" = "robot",
		"Motile" = "motile"
	)

/obj/item/robot_module/flying/cultivator
	sprites = list(
		"Drone" = "drone-hydro",
		"Ver 06" = "wer6-Research"
	)

/obj/item/robot_module/flying/emergency
	sprites = list(
		"Drone" = "drone-medical",
		"Eyebot" = "eyebot-medical",
		"Ver 06" = "wer6-Surgeon"
	)

/obj/item/robot_module/flying/filing
	sprites = list(
		"Drone" = "drone-service",
		"Ver 06" = "wer6-Service"
	)

/obj/item/robot_module/flying/forensics
	sprites = list(
		"Drone" = "drone-sec",
		"Eyebot" = "eyebot-security",
		"Ver 06" = "wer6-Security"
	)

/obj/item/robot_module/flying/repair
	sprites = list(
		"Drone" = "drone-engineer",
		"Eyebot" = "eyebot-engineering",
		"Ver 06" = "wer6-Engineering"
	)

/obj/item/robot_module/flying/repair/Initialize()
	equipment += /obj/item/rpd

	. = ..()
