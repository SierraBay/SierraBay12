/obj/item/clothing/suit/storage/chest_rig
	abstract_type = /obj/item/clothing/suit/storage/chest_rig
	body_parts_covered = UPPER_TORSO
	icon_state = "chest-rig"
	blood_overlay_type = "armorblood"
	valid_accessory_slots = list(
		ACCESSORY_SLOT_ARMOR_MISC,
		ACCESSORY_SLOT_INSIGNIA
	)


/obj/item/clothing/suit/storage/chest_rig/security
	name = "chest-rig"
	desc = "A grey chest-rig with black pouches. For when you wish you had more hands."
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/clothing/mask/gas,
		/obj/item/device/radio,
		/obj/item/taperoll,
		/obj/item/clothing/head/hardhat,
		/obj/item/handcuffs,
		/obj/item/melee/baton,
		/obj/item/grenade,
		/obj/item/gun
	)


/obj/item/clothing/suit/storage/chest_rig/engineering
	name = "hazard chest-rig"
	desc = "A grey chest-rig with black pouches and orange markings worn by engineers. It has an 'Engineer' tag on its chest."
	icon_state = "engi-chest-rig"
	allowed = list (
		/obj/item/device/flashlight,
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/clothing/mask/gas,
		/obj/item/device/radio,
		/obj/item/taperoll,
		/obj/item/clothing/head/hardhat,
		/obj/item/device/scanner/gas,
		/obj/item/device/multitool,
		/obj/item/device/t_scanner,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/gun
	)


/obj/item/clothing/suit/storage/chest_rig/medical
	name = "\improper MT chest-rig"
	desc = "A white chest-rig with black pouches worn by medical first responders. It has a 'Medic' tag on its chest."
	icon_state = "med-chest-rig"
	allowed = list(
		/obj/item/device/flashlight,
		/obj/item/tank/oxygen_emergency,
		/obj/item/tank/oxygen_emergency_extended,
		/obj/item/tank/nitrogen_emergency,
		/obj/item/clothing/mask/gas,
		/obj/item/device/radio,
		/obj/item/taperoll,
		/obj/item/clothing/head/hardhat,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/device/scanner/health,
		/obj/item/reagent_containers/ivbag,
		/obj/item/gun
	)
