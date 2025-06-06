/obj/machinery/telecomms/hub/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/receiver/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/bus/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/processor/map_preset/phobos
	preset_name = "phobos"

/obj/machinery/telecomms/server/map_preset/phobos
	preset_name = "phobos"
	preset_color = "#0026ff"

/obj/machinery/telecomms/broadcaster/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/intercom/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/encryptionkey/map_preset/phobos
	preset_name = "phobos"

/obj/item/device/radio/headset/map_preset/phobos
	preset_name = "phobos"
	encryption_key = /obj/item/device/encryptionkey/map_preset/phobos

/* CARDS
 * ========
 */

/obj/item/card/id/phobos
	desc = "A card issued to Third Fleet staff."
	color = "#d3e3e1"
	color = "#ccecff"
	access = list(access_away_phobos)

/obj/item/card/id/phobos/commander
	desc = "A card issued to Third Fleet vessel CO's."
	detail_color = COLOR_COMMAND_BLUE
	extra_details = list("onegoldstripe")
	access = list(access_away_phobos, access_away_phobos_armory, access_away_phobos_security, access_away_phobos_bridge, access_away_phobos_commander)

/obj/item/card/id/phobos/security
	desc = "A card issued to Third Fleet security staff."
	color = COLOR_OFF_WHITE
	detail_color = "#e00000"
	access = list(access_away_phobos, access_away_phobos_security)

/obj/item/card/id/phobos/security/sergeant
	desc = "A card issued to Third Fleet senior security staff."
	color = COLOR_OFF_WHITE
	detail_color = "#e00000"
	extra_details = list("onegoldstripe")
	access = list(access_away_phobos, access_away_phobos_security, access_away_phobos_armory)

/obj/item/card/id/phobos/medical
	desc = "A card issued to Third Fleet medical staff."
	detail_color = COLOR_PALE_BLUE_GRAY
	access = list(access_away_phobos)

/obj/item/card/id/phobos/pilot
	desc = "A card issued to Third Fleet bridge staff."
	detail_color = COLOR_COMMAND_BLUE
	access = list(access_away_phobos, access_away_phobos_security, access_away_phobos_bridge)

/obj/item/card/id/phobos/engineer
	desc = "A card issued to engineering staff."
	job_access_type = /datum/job/engineer
	detail_color = COLOR_SUN
	access = list(access_away_phobos)
