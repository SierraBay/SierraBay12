/obj/item/stock_parts/computer/hard_drive/portable/
	var/disk_name

/obj/item/stock_parts/computer/hard_drive/portable/design/
	name = "design disk"
	desc = "Data disk used to store autolathe designs."
	icon = 'mods/RnD/icons/discs.dmi'
	icon_state = "yellow"
	max_capacity = 512	// Up to 255 designs, automatically reduced to the nearest power of 2
	origin_tech = list(TECH_DATA = 3) // Most design disks end up being 64 to 128 GQ
	matter = list(MATERIAL_STEEL = 100, MATERIAL_PLASTIC = 200, MATERIAL_GOLD = 50)
	var/list/designs = list()

/obj/item/stock_parts/computer/hard_drive/portable/LateInitialize(mapload)
	install_default_programs()

/obj/item/stock_parts/computer/hard_drive/portable/design/install_default_programs()
	// Add design files to the disk
	if(name)
		var/datum/computer_file/data/text/D = new
		D.filename = "DISK_NAME"
		D.stored_data = name
		create_file(D)

	for(var/D in designs)
		var/datum/design/dsgn = D
		var/build = dsgn.build_path

		if(!dsgn)
			continue
		var/datum/design/autolathe/design = SSresearch.get_autolathe_design_by_build_path(build)
		if(!design)
			continue
		var/datum/computer_file/binary/design/design_file = design.file

		create_file(design_file)


	// Shave off the extra space so a disk with two designs doesn't show up as 1024 GQ
	while(max_capacity > 16 && max_capacity / 2 > used_capacity)
		max_capacity /= 2

	// Prevent people from breaking DRM by copying files across protected disks.
	// Stops people from screwing around with unprotected disks too.
	return TRUE

// Disks formated as /designpath = pointcost , if no point cost is specified it defaults to 1.



/obj/item/stock_parts/computer/hard_drive/portable/design/arm
	name = "Arms and Ammo Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/arms_ammo,
		/datum/design/autolathe/arms_ammo/shotgun_holder,
		/datum/design/autolathe/arms_ammo/shotgun_blanks,
		/datum/design/autolathe/arms_ammo/flaregun,
		/datum/design/autolathe/arms_ammo/hidden,
		/datum/design/autolathe/arms_ammo/hidden/shotgun,
		/datum/design/autolathe/arms_ammo/shotgun_flash,
		/datum/design/autolathe/arms_ammo/hidden/magazine_smg_rubber,
		/datum/design/autolathe/arms_ammo/hidden/flamethrower,
		/datum/design/autolathe/arms_ammo/hidden/speedloader,
		/datum/design/autolathe/arms_ammo/hidden/speedloader_small,
		/datum/design/autolathe/arms_ammo/hidden/speedloader_magnum,
		/datum/design/autolathe/arms_ammo/hidden/magazine_pistol,
		/datum/design/autolathe/arms_ammo/hidden/magazine_pistol_rubber,
		/datum/design/autolathe/arms_ammo/hidden/magazine_pistol_double,
		/datum/design/autolathe/arms_ammo/hidden/magazine_pistol_double_rubber,
		/datum/design/autolathe/arms_ammo/hidden/magazine_small,
		/datum/design/autolathe/arms_ammo/hidden/magazine_magnum,
		/datum/design/autolathe/arms_ammo/hidden/magazine_smg,
		/datum/design/autolathe/arms_ammo/hidden/magazine_uzi,
		/datum/design/autolathe/arms_ammo/hidden/magazine_smg_topmounted,
		/datum/design/autolathe/arms_ammo/hidden/magazine_arifle,
		/datum/design/autolathe/arms_ammo/hidden/magazine_bullpupheavy,
		/datum/design/autolathe/arms_ammo/hidden/magazine_bullpuplight,
		/datum/design/autolathe/arms_ammo/hidden/shotgun,
		/datum/design/autolathe/arms_ammo/hidden/shotgun_pellet,
		/datum/design/autolathe/arms_ammo/hidden/tacknife,
		/datum/design/autolathe/arms_ammo/hidden/stunshell,
		/datum/design/autolathe/arms_ammo/hidden/flechette,
		/datum/design/autolathe/arms_ammo/hidden/skrellian_rifle_flechette,
		/datum/design/autolathe/arms_ammo/hidden/skrellian_rifle_slug,
		/datum/design/autolathe/arms_ammo/hidden/stripperclip,
		/datum/design/autolathe/arms_ammo/hidden/pistolstripperclip,
		/datum/design/autolathe/arms_ammo/hidden/broomstickstripperclip,
		/datum/design/autolathe/arms_ammo/hidden/rifleinternalclip,
		/datum/design/autolathe/arms_ammo/hidden/beandrum,
		/datum/design/autolathe/arms_ammo/hidden/nt10mag,
		/datum/design/autolathe/arms_ammo/hidden/shotgun_flechette,
		)


/obj/item/stock_parts/computer/hard_drive/portable/design/components
	name = "General Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/general,
		/datum/design/autolathe/general/flashlight,
		/datum/design/autolathe/general/floor_light,
		/datum/design/autolathe/general/extinguisher,
		/datum/design/autolathe/general/extinguisher/mini,
		/datum/design/autolathe/general/jar,
		/datum/design/autolathe/general/radio_headset,
		/datum/design/autolathe/general/radio_bounced,
		/datum/design/autolathe/general/suit_cooler,
		/datum/design/autolathe/general/weldermask,
		/datum/design/autolathe/general/knife,
		/datum/design/autolathe/general/taperecorder,
		/datum/design/autolathe/general/tape,
		/datum/design/autolathe/general/tube/large/warm,
		/datum/design/autolathe/general/tube/large/cool,
		/datum/design/autolathe/general/tube/large/white,
		/datum/design/autolathe/general/tube/warm,
		/datum/design/autolathe/general/tube/cool,
		/datum/design/autolathe/general/tube/white,
		/datum/design/autolathe/general/bulb/warm,
		/datum/design/autolathe/general/bulb/cool,
		/datum/design/autolathe/general/bulb/white,
		/datum/design/autolathe/general/ashtray_glass,
		/datum/design/autolathe/general/weldinggoggles,
		/datum/design/autolathe/general/blackpen,
		/datum/design/autolathe/general/bluepen,
		/datum/design/autolathe/general/redpen,
		/datum/design/autolathe/general/greenpen,
		/datum/design/autolathe/general/clipboard_steel,
		/datum/design/autolathe/general/clipboard_alum,
		/datum/design/autolathe/general/clipboard_glass,
		/datum/design/autolathe/general/clipboard_alum,
		/datum/design/autolathe/general/destTagger,
		/datum/design/autolathe/general/labeler,
		/datum/design/autolathe/general/handcuffs,
		/datum/design/autolathe/general/plunger,
		/datum/design/autolathe/general/toolbox,
		/datum/design/autolathe/general/binoculars,
		/datum/design/autolathe/general/tape_roll,
		)

/obj/item/stock_parts/computer/hard_drive/portable/design/components
	name = "Components Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/device_component,
		/datum/design/autolathe/device_component/keyboard,
		/datum/design/autolathe/device_component/tesla_component,
		/datum/design/autolathe/device_component/radio_transmitter,
		/datum/design/autolathe/device_component/radio_transmitter_event,
		/datum/design/autolathe/device_component/radio_receiver,
		/datum/design/autolathe/device_component/battery_backup_crap,
		/datum/design/autolathe/device_component/battery_backup_stock,
		/datum/design/autolathe/device_component/battery_backup_turbo,
		/datum/design/autolathe/device_component/battery_backup_responsive,
		/datum/design/autolathe/device_component/terminal,
		/datum/design/autolathe/device_component/igniter,
		/datum/design/autolathe/device_component/signaler,
		/datum/design/autolathe/device_component/sensor_infra,
		/datum/design/autolathe/device_component/timer,
		/datum/design/autolathe/device_component/sensor_prox,
		/datum/design/autolathe/device_component/cable_coil,
		/datum/design/autolathe/device_component/electropack,
		/datum/design/autolathe/device_component/beartrap,
		/datum/design/autolathe/device_component/cell_device,
		/datum/design/autolathe/device_component/ecigcartridge,
		/datum/design/autolathe/device_component/conveyor_construct,
		/datum/design/autolathe/device_component/conveyor_switch_construct,
		/datum/design/autolathe/device_component/conveyor_switch_oneway_construct,
		)

/obj/item/stock_parts/computer/hard_drive/portable/design/cuttery
	name = "Cuttery Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/cutlery,
		/datum/design/autolathe/cutlery/spoon_aluminium,
		/datum/design/autolathe/cutlery/spork_aluminium,
		/datum/design/autolathe/cutlery/knife_aluminium,
		/datum/design/autolathe/cutlery/foon_aluminium,
		/datum/design/autolathe/cutlery/fork_plastic,
		/datum/design/autolathe/cutlery/spoon_plastic,
		/datum/design/autolathe/cutlery/spork_plastic,
		/datum/design/autolathe/cutlery/knife_plastic,
		/datum/design/autolathe/cutlery/foon_plastic,
		)

/obj/item/stock_parts/computer/hard_drive/portable/design/engineering
	name = "Engineering Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/engineering,
		/datum/design/autolathe/engineering/airalarm,
		/datum/design/autolathe/engineering/firealarm,
		/datum/design/autolathe/engineering/intercom,
		/datum/design/autolathe/engineering/powermodule,
		/datum/design/autolathe/engineering/rcd_ammo,
		/datum/design/autolathe/engineering/rcd_ammo_large,
		/datum/design/autolathe/engineering/camera_assembly,
		/datum/design/autolathe/engineering/transfer_valve,
		)

/obj/item/stock_parts/computer/hard_drive/portable/design/drinking
	name = "Drinking Glass Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/drinkingglass,
		/datum/design/autolathe/drinkingglass/rocks,
		/datum/design/autolathe/drinkingglass/shake,
		/datum/design/autolathe/drinkingglass/cocktail,
		/datum/design/autolathe/drinkingglass/shot,
		/datum/design/autolathe/drinkingglass/pint,
		/datum/design/autolathe/drinkingglass/mug,
		/datum/design/autolathe/drinkingglass/wine,
		/datum/design/autolathe/drinkingglass/carafe,
		/datum/design/autolathe/drinkingglass/flute,
		/datum/design/autolathe/drinkingglass/coffeecup,
		/datum/design/autolathe/drinkingglass/cognac,
		/datum/design/autolathe/drinkingglass/goblet,
		/datum/design/autolathe/drinkingglass/coffeecup/glass,
		)

/obj/item/stock_parts/computer/hard_drive/portable/design/medical
	name = "Medical Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/medical,
		/datum/design/autolathe/medical/circularsaw,
		/datum/design/autolathe/medical/surgicaldrill,
		/datum/design/autolathe/medical/retractor,
		/datum/design/autolathe/medical/dropper,
		/datum/design/autolathe/medical/cautery,
		/datum/design/autolathe/medical/hemostat,
		/datum/design/autolathe/medical/beaker,
		/datum/design/autolathe/medical/beaker_large,
		/datum/design/autolathe/medical/beaker_insul,
		/datum/design/autolathe/medical/beaker_insul_large,
		/datum/design/autolathe/medical/vial,
		/datum/design/autolathe/medical/syringe,
		/datum/design/autolathe/medical/pill_bottle,
		/datum/design/autolathe/medical/hypospray/autoinjector,
		/datum/design/autolathe/medical/scalpel,
		)


/obj/item/stock_parts/computer/hard_drive/portable/design/tool
	name = "Tools Designs"
	icon_state = "red"
	designs = list(
		/datum/design/autolathe/tool,
		/datum/design/autolathe/tool/prybar,
		/datum/design/autolathe/tool/rescuetool,
		/datum/design/autolathe/tool/int_wirer,
		/datum/design/autolathe/tool/int_debugger,
		/datum/design/autolathe/tool/int_analyzer,
		/datum/design/autolathe/tool/multitool,
		/datum/design/autolathe/tool/t_scanner,
		/datum/design/autolathe/tool/weldertool,
		/datum/design/autolathe/tool/screwdriver,
		/datum/design/autolathe/tool/wirecutters,
		/datum/design/autolathe/tool/wrench,
		/datum/design/autolathe/tool/hatchet,
		/datum/design/autolathe/tool/minihoe,
		/datum/design/autolathe/tool/welder_industrial,
		/datum/design/autolathe/tool/designator,
		)
