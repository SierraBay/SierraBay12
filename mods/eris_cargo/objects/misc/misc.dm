// Circuit boards for trade beacons
/obj/item/stock_parts/circuitboard/trade_beacon
	origin_tech = list(TECH_BLUESPACE = 2)
	board_type = "machine"
	req_components = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/subspace/crystal = 2,
	)

/obj/item/stock_parts/circuitboard/trade_beacon/receiving
	name = "circuit board (receiving trade beacon)"
	build_path = /obj/machinery/trade_beacon/receiving

/obj/item/stock_parts/circuitboard/trade_beacon/sending
	name = "circuit board (sending trade beacon)"
	build_path = /obj/machinery/trade_beacon/sending

// secure closets for trade crates
/obj/structure/closet/secure_closet/personal/trade
	name = "order crate"
	desc = "A secure crate."
	closet_appearance = /singleton/closet_appearance/crate
	open_sound = 'sound/machines/click.ogg'
	close_sound = 'sound/machines/click.ogg'

/obj/structure/closet/secure_closet/personal/trade/WillContain()
	return


// Material stacks
/obj/item/stack/material/deuterium/ten
	amount = 10


/// A note containing the supply account information for the Quartermaster and Command to access the supply account.
/obj/item/paper/supply_account
	name = "supply account note"

/obj/item/paper/supply_account/Initialize()
	. = ..()
	var/datum/money_account/MA = department_accounts["Supply"]
	info = "<b><center>CONFIDENTIAL: ONLY FOR COMMAND PERSONNEL AND QM.</b></center>\
			<BR><BR>\
			Account number: [MA.account_number]<br>\
			Account pin: [MA.remote_access_pin]"


/obj/machinery/computer/modular/preset/cardslot/command
	default_software = list(
		/datum/computer_file/program/comm,
		/datum/computer_file/program/camera_monitor,
		/datum/computer_file/program/email_client,
		/datum/computer_file/program/records,
		/datum/computer_file/program/docking,
		/datum/computer_file/program/wordprocessor
	)

/obj/machinery/computer/modular/preset/cardslot/supply
	default_software = list(
		/datum/computer_file/program/email_client,
		/datum/computer_file/program/records,
		/datum/computer_file/program/supply,
		/datum/computer_file/program/docking,
		/datum/computer_file/program/wordprocessor
	)

/obj/machinery/computer/modular/preset/civilian
	default_software = list(
		/datum/computer_file/program/camera_monitor,
		/datum/computer_file/program/records,
		/datum/computer_file/program/email_client,
		/datum/computer_file/program/wordprocessor
	)
