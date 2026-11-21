/datum/computer_file/program/trade
	filename = "trade"
	filedesc = "Frontier Trade Network"
	nanomodule_path = null
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "Trade with frontier relays, export cargo, and manage requisitions."
	size = 21
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	category = PROG_SUPPLY
	var/program_type = "master"
	var/tgui_module_path = /datum/tgui_module/trade

/datum/computer_file/program/trade/can_run(mob/living/user, loud, access_to_check)
	return SStrade.enabled && ..()

/datum/computer_file/program/trade/clone()
	var/datum/computer_file/program/trade/temp = ..()
	temp.program_type = program_type
	temp.tgui_module_path = tgui_module_path
	return temp

/datum/computer_file/program/trade/on_startup(mob/living/user, datum/extension/interactive/ntos/new_host)
	. = ..()
	if(.)
		trade_ui = new tgui_module_path(new_host, src)

/datum/computer_file/program/trade/on_shutdown(forced = 0)
	if(trade_ui)
		SStgui.close_uis(trade_ui)
		QDEL_NULL(trade_ui)
	return ..()

/datum/computer_file/program/trade/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	if(program_state != PROGRAM_STATE_ACTIVE)
		if(trade_ui)
			SStgui.close_uis(trade_ui)
		return computer?.ui_interact(user, ui_key, null, force_open)
	if(!trade_ui && computer)
		trade_ui = new tgui_module_path(computer, src)
	if(trade_ui)
		trade_ui.tgui_interact(user)
		return FALSE
	return TRUE

/datum/computer_file/program/trade_orders
	parent_type = /datum/computer_file/program/trade
	filename = "trade_orders"
	program_type = "ordering"
	usage_flags = PROGRAM_ALL
	filedesc = "Frontier Trade Requisitions"
	tgui_module_path = /datum/tgui_module/trade/orders
	extended_desc = "Purchase freight with an inserted ID or request department funding."
	size = 5

/datum/computer_file/program/pda/trade
	parent_type = /datum/computer_file/program/trade
	filename = "trade_catalog"
	filedesc = "Frontier Catalog"
	tgui_module_path = /datum/tgui_module/trade/pda
	extended_desc = "Browse discovered frontier vendors, stock, prices and bounties."
	size = 4
	usage_flags = PROGRAM_PDA | PROGRAM_TABLET

/datum/computer_file/program/trade/slave
	filename = "trade_local"
	filedesc = "Local Trade Terminal"
	program_type = "slave"
	tgui_module_path = /datum/tgui_module/trade/slave
	extended_desc = "Trade through beacons in this room. Personal bounty rewards pay a 20% cargo commission."
	size = 8

/datum/tgui_module/trade
	name = "Frontier Trade Network"
	var/datum/computer_file/program/program
	var/program_type = "master"
	var/sender_id
	var/receiver_id
	var/list/cart = list()
	var/list/saved_carts = list()
	var/list/saved_names = list()
	var/next_saved_id = 0
	var/message = ""
	var/message_type = "info"
	var/read_only = FALSE
	var/datum/money_account/linked_account
	var/obj/item/card/id/linked_card
	var/active_tab = "catalog"
	var/logs_page = 1
	var/logs_page_size = TRADE_LOG_PAGE_SIZE

/datum/tgui_module/trade/orders
	name = "Frontier Trade Requisitions"

/datum/tgui_module/trade/pda
	name = "Frontier Catalog"
	read_only = TRUE

/datum/tgui_module/trade/slave
	name = "Local Trade Terminal"

/datum/tgui_module/trade/New(datum/new_host, datum/computer_file/program/new_program)
	..()
	program = new_program
	if(!program)
		return
	if(!program.frontier_trade_state)
		program.frontier_trade_state = list(
			"cart" = list(),
			"saved" = list(),
			"names" = list(),
			"next_id" = 0,
		)
	if(istype(program, /datum/computer_file/program/trade))
		var/datum/computer_file/program/trade/trade_program = program
		program_type = trade_program.program_type
	sender_id = program.frontier_trade_state["sender"]
	receiver_id = program.frontier_trade_state["receiver"]
	cart = program.frontier_trade_state["cart"]
	saved_carts = program.frontier_trade_state["saved"]
	saved_names = program.frontier_trade_state["names"]
	next_saved_id = program.frontier_trade_state["next_id"]

/datum/tgui_module/trade/Destroy()
	SStgui.close_uis(src)
	cart = null
	saved_carts = null
	saved_names = null
	program = null
	linked_account = null
	linked_card = null
	return ..()

/datum/tgui_module/trade/tgui_host(mob/user)
	return program?.nano_host() || host || src

/datum/tgui_module/trade/tgui_state(mob/user)
	return GLOB.tgui_default_state

/datum/tgui_module/trade/tgui_status(mob/user, datum/tgui_state/state)
	if(!SStrade.enabled || !program || !program.computer || !program.computer.on || !program.computer.host_status() || program.program_state != PROGRAM_STATE_ACTIVE)
		return STATUS_CLOSE
	if(isobserver(user))
		return ..()
	var/datum/extension/interactive/ntos/os = program.computer
	var/status = os.CanUseTopic(user, GLOB.default_state)
	if(state != GLOB.tgui_default_state)
		status = min(status, ..())
	return status

/datum/tgui_module/trade/tgui_close(mob/user)
	program?.computer?.window_closed(program, user)

/datum/tgui_module/trade/proc/set_message(text, kind = "info")
	message = text
	message_type = kind

/datum/tgui_module/trade/proc/is_manager(mob/user)
	return !read_only && program_type == "master" && user && (access_cargo in user.GetAccess())

/datum/tgui_module/trade/proc/is_hacked()
	return !read_only && !istype(program, /datum/computer_file/program/trade_orders) && program?.computer?.emagged()

/datum/tgui_module/trade/proc/has_printer()
	var/datum/extension/interactive/ntos/os = program?.computer
	return !!(os && os.get_component(PART_PRINTER))

/datum/tgui_module/trade/proc/get_inserted_card()
	var/obj/item/stock_parts/computer/card_slot/slot = program?.computer?.get_component(PART_CARD)
	return slot?.stored_card

/datum/tgui_module/trade/proc/get_card_account()
	var/obj/item/card/id/card = get_inserted_card()
	var/datum/money_account/account = card ? get_account(card.associated_account_number) : null
	if(!account || account.suspended)
		return null
	return account

/datum/tgui_module/trade/proc/get_user_key(mob/user)
	return user?.ckey || (user ? "\ref[user]" : "")

/datum/tgui_module/trade/proc/can_view_order(datum/trade_order/order, mob/user)
	var/obj/item/card/id/card = get_inserted_card()
	return is_manager(user) || order.requester_key == get_user_key(user) || (order.account && card?.associated_account_number == order.account.account_number)

/datum/tgui_module/trade/proc/authenticate(raw_pin = null)
	var/obj/item/card/id/card = get_inserted_card()
	var/datum/money_account/account = get_card_account()
	if(!account)
		return null
	var/pin = 0
	if(account.security_level)
		if(isnull(raw_pin) || raw_pin == "")
			return null
		pin = text2num("[raw_pin]")
		if(isnull(pin))
			return null
	return attempt_account_access(card.associated_account_number, pin, 2)

/datum/tgui_module/trade/proc/get_linked_account()
	if(!linked_account || QDELETED(linked_account) || QDELETED(linked_card) || linked_account.suspended || get_inserted_card() != linked_card || get_account(linked_card?.associated_account_number) != linked_account)
		unlink_account()
	return linked_account

/datum/tgui_module/trade/proc/unlink_account()
	linked_account = null
	linked_card = null

/datum/tgui_module/trade/proc/link_account(raw_pin = null)
	var/datum/money_account/account = authenticate(raw_pin)
	if(!account || QDELETED(src))
		return FALSE
	linked_account = account
	linked_card = get_inserted_card()
	return TRUE

/datum/tgui_module/trade/proc/print_text(text, mob/user)
	var/datum/extension/interactive/ntos/os = program?.computer
	if(!os)
		set_message("Printer interface unavailable.", "bad")
		return FALSE
	if(!os.get_component(PART_PRINTER))
		set_message("No printer installed in this terminal.", "bad")
		return FALSE
	os.print_paper(text)
	set_message("Printed document.", "good")
	return TRUE
