/obj/machinery/suit_storage_unit/phobos
	name = "Officer Voidsuit Storage Unit"
	suit= /obj/item/clothing/suit/space/void/command/prepared
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	req_access = list(access_away_phobos_commander)
	islocked = 1
	ssu_color = COLOR_COMMAND_BLUE

/singleton/closet_appearance/secure_closet/phobos/co
	extra_decals = list(
		"stripe_vertical_left_full" = COLOR_CLOSET_GOLD,
		"stripe_vertical_mid_full" = COLOR_OFF_WHITE,
		"stripe_vertical_right_full" = COLOR_CLOSET_GOLD,
		"command" = COLOR_OFF_WHITE
	)

/singleton/closet_appearance/secure_closet/phobos/bo
	extra_decals = list(
		"stripe_vertical_left_full" = COLOR_CLOSET_GOLD,
		"stripe_vertical_right_full" = COLOR_CLOSET_GOLD
	)


/singleton/closet_appearance/secure_closet/phobos/security
	extra_decals = list(
		"stripe_vertical_mid_full" = COLOR_NT_RED,
		"security" = COLOR_NT_RED
	)

/singleton/closet_appearance/secure_closet/phobos/security/warden
	extra_decals = list(
		"stripe_vertical_left_full" = COLOR_NT_RED,
		"stripe_vertical_right_full" = COLOR_NT_RED,
		"security" = COLOR_NT_RED
	)

/singleton/closet_appearance/secure_closet/phobos/engineering
	extra_decals = list(
		"stripe_vertical_mid_full" = COLOR_WARM_YELLOW,
		"exped" = COLOR_WARM_YELLOW
	)

/obj/structure/closet/secure_closet/guncabinet/phobos
	name = "heavy armory cabinet"
	req_access = list(access_away_phobos_armory)

/obj/structure/closet/secure_closet/CO_phobos
	name = "commanding officer's locker"
	req_access = list(access_away_phobos_commander)
	closet_appearance = /singleton/closet_appearance/secure_closet/phobos/co

/obj/structure/closet/secure_closet/bridgeofficer_phobos
	name = "bridge officer's locker"
	req_access = list(access_away_phobos_bridge)
	closet_appearance = /singleton/closet_appearance/secure_closet/phobos/bo

/obj/structure/closet/secure_closet/security_phobos
	name = "master at arms' locker"
	req_access = list(access_away_phobos_security)
	closet_appearance = /singleton/closet_appearance/secure_closet/phobos/security

/obj/structure/closet/secure_closet/brigchief_phobos
	name = "brig chief's locker"
	req_access = list(access_away_phobos_armory)
	closet_appearance = /singleton/closet_appearance/secure_closet/phobos/security/warden

/obj/structure/closet/secure_closet/engineering_phobos
	name = "engineer's locker"
	req_access = list(access_away_phobos)
	closet_appearance = /singleton/closet_appearance/secure_closet/phobos/engineering


		// Missile console //

/datum/computer_file/program/munitions/sol
	filename = "munitionscontrol"
	filedesc = "PC Munitions Control Program"
	nanomodule_path = /datum/nano_module/program/munitions/sol
	program_icon_state = "munitions"
	program_key_state = "security_key"
	program_menu_icon = "bullet"
	extended_desc = "SCGN Program for controlling munitions loading and arming systems."
	requires_ntnet = FALSE
	size = 8
	category = PROG_COMMAND
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	available_on_ntnet = FALSE
	available_on_syndinet = FALSE
	required_access = access_away_phobos

/datum/nano_module/program/munitions/sol
	name = "PC Munitions Control Program"
	access_req = list(access_away_phobos)

// Computer preset

/obj/machinery/computer/modular/preset/munitions/sol
	default_software = list(
		/datum/computer_file/program/munitions/sol
	)

// Uniforms

/obj/machinery/vending/away_phobos_uniform
	name = "Fleet uniform dispenser"
	desc = "A specialized vending machine with nice and fresh navy-blue clothing inside. For military personnel only."
	icon = 'mods/_maps/sentinel/icons/obj/fleet_vendomat.dmi'
	icon_state = "uniform_fleet"
	icon_deny = "uniform_fleet-deny"
	icon_vend = "uniform_fleet-vend"
	req_access = list(access_away_phobos)
	products = list(/obj/item/clothing/head/beret/solgov/fleet/branch/third = 15,
					/obj/item/clothing/head/soft/solgov/fleet = 15,
					/obj/item/clothing/head/ushanka/solgov/fleet = 15,
					/obj/item/clothing/under/solgov/utility/fleet = 15,
					/obj/item/clothing/under/solgov/utility/fleet/combat = 15,
					/obj/item/clothing/under/solgov/service/fleet = 15,
					/obj/item/clothing/under/solgov/pt/fleet = 15,
					/obj/item/clothing/suit/storage/hooded/wintercoat/solgov/fleet = 15,
					/obj/item/clothing/shoes/dutyboots = 15,
					/obj/item/clothing/shoes/dress = 15,
					/obj/item/clothing/shoes/black = 15,
					/obj/item/clothing/gloves/thick = 15,
					/obj/item/storage/belt/holster/security = 15,
					/obj/item/storage/backpack/satchel/leather/navy = 15,
					/obj/item/clothing/accessory/storage/black_drop = 15,
					/obj/item/clothing/accessory/solgov/fleet_patch/third = 15,
					)
