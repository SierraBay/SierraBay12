
/* CARDS
 * ========
 */

/obj/item/card/id/awaycavalry/ops
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = "#af6605c2"
	detail_color = "#000000"
	access = list(access_away_cavalry, access_away_cavalry_ops)

/obj/item/card/id/awaycavalry/ops/captain
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	access = list(access_away_cavalry, access_away_cavalry_ops, access_away_cavalry_fleet_armory, access_away_cavalry_captain)
	extra_details = list("goldstripe")

/obj/item/card/id/awaycavalry/fleet
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	color = COLOR_GRAY40
	detail_color = "#447ab1"
	access = list(access_away_cavalry)

/obj/item/card/id/awaycavalry/fleet/pilot
	access = list(access_away_cavalry, access_away_cavalry_pilot, access_away_cavalry_fleet_armory)

/obj/item/card/id/awaycavalry/fleet/commander
	desc = "An identification card issued to SolGov crewmembers aboard the Sol Patrol Craft."
	icon_state = "base"
	access = list(access_away_cavalry, access_away_cavalry_ops, access_away_cavalry_captain, access_away_cavalry_pilot, access_away_cavalry_fleet_armory, access_away_cavalry_commander) //TODO: беды с доступами
	extra_details = list("goldstripe")

/* RADIOHEADS
 * ========
 */

/obj/item/device/radio/headset/rescue
	name = "rescue team radio headset"
	desc = "The headset of the rescue team member."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/rescue

/obj/item/device/radio/headset/rescue/leader
	name = "rescue team leader radio headset"
	desc = "The headset of the rescue team member."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/rescue/leader

/obj/item/device/encryptionkey/rescue //for events
	name = "\improper rescue radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list("Response Team" = 1)

/obj/item/device/encryptionkey/rescue/leader
	name = "\improper rescue leader radio encryption key"
	channels = list("Response Team" = 1, "Command" = 1, )

/* CLOTHING
 * ========
 */

/obj/item/clothing/under/scga/utility/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/officer/pilot_away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/officer/command_away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/command/fleet,
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/engineering/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/engineering/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/medical/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/under/solgov/utility/fleet/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/command/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/fifth
	)

/obj/item/clothing/suit/storage/solgov/service/fleet/officer/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/chameleon,
		/obj/item/clothing/accessory/solgov/specialty/officer
	)

/obj/item/clothing/suit/storage/solgov/service/fleet/command/away_solpatrol
	accessories = list(
		/obj/item/clothing/accessory/chameleon,
		/obj/item/clothing/accessory/solgov/specialty/officer
	)

/obj/item/storage/belt/holster/security/tactical/away_solpatrol/New()
	..()
	new /obj/item/gun/projectile/pistol/m22f(src)
	new /obj/item/ammo_magazine/pistol/double(src)
	new /obj/item/ammo_magazine/pistol/double(src)

/obj/item/storage/belt/holster/general/away_solpatrol/New()
	..()
	new /obj/item/modular_computer/tablet/preset/custom_loadout/advanced(src)
	new /obj/item/gun/projectile/revolver/medium(src)

/obj/item/clothing/accessory/armband/bluegold/away_solpatrol
	name = "SCG armband"
	desc = "An armband, worn by the crew to display which country they represent. This one is blue and gold."
	icon_state = "solblue"

/obj/item/clothing/accessory/solgov/army/tempest
	name = "Tempest Squad patch"
	desc = "A tactical shoulder patch carrying insignia of Tempest Squad, the Special Operations Force of SCG Army."
	icon = 'mods/_maps/sentinel/icons/obj/obj_accessories_solpatrol.dmi'
	accessory_icons = list(
		slot_w_uniform_str = 'mods/_maps/sentinel/icons/mob/onmob_accessories_solpatrol.dmi',
		slot_wear_suit_str = 'mods/_maps/sentinel/icons/mob/onmob_accessories_solpatrol.dmi'
	)
	icon_state = "army_tempest"
	on_rolled_down = ACCESSORY_ROLLED_NONE
	slot = ACCESSORY_SLOT_INSIGNIA


	// VoidSuit

/obj/item/rig/ert/fleet/leader/fifthfleet
	name = "\improper SCGF-SO Leader command hardsuit control module"
	desc = "A hardsuit utilized by Fifth Fleet combat teams. This one has blue highlights with SOL CENTRAL GOVERNMENT FLEET printed in gold lettering on the chest and displaying a SCG crest on the back."
	suit_type = "\improper SCGF-SO Leader command combat hardsuit"
	icon_state = "ert_commander_rig"

	req_access = list(access_away_cavalry_captain)

	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_pressure_protection = FIRESUIT_MAX_PRESSURE
	emp_protection = 6

	initial_modules = list(
		/obj/item/rig_module/mounted/energy/egun,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/combat/ert,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/selfrepair/adv,
		/obj/item/rig_module/simple_ai/advanced,
		/obj/item/rig_module/device/flash/advanced,
		/obj/item/rig_module/datajack
		)

/obj/item/rig/ert/fleet/combat/fifthfleet
	name = "\improper SCGF-SO Trooper combat hardsuit control module"
	desc = "A hardsuit utilized by Fifth Fleet combat teams. This one has red highlights with SOL CENTRAL GOVERNMENT FLEET written in silver lettering on the chest and a SCG crest displaying on the back."
	suit_type = "\improper SCGF-SO Trooper combat hardsuit"
	icon_state = "ert_security_rig"

	req_access = list(access_away_cavalry_ops)

	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_pressure_protection = FIRESUIT_MAX_PRESSURE
	emp_protection = 6

	initial_modules = list(
		/obj/item/rig_module/vision/multi/cheap,
		/obj/item/rig_module/grenade_launcher/light,
		/obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/combat/ert,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/selfrepair,
		/obj/item/rig_module/simple_ai,
		/obj/item/rig_module/mounted/energy/taser,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/datajack
		)

// AmmoBox

/obj/item/storage/box/ammo/solmag
	name = "box of SolMag"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/smg_sol = 7)

/obj/item/storage/box/ammo/milrifleheavy
	name = "box of Z8"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_magazine/mil_rifle/heavy = 7)
