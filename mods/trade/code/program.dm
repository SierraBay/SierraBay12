/datum/computer_file/program/trade
	filename = "trade"
	filedesc = "Frontier Trade Network"
	nanomodule_path = /datum/nano_module/program/trade
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "Trade with frontier relays, export cargo, and manage requisitions."
	size = 21
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	category = PROG_SUPPLY
	var/program_type = "master"

/datum/computer_file/program/trade/can_run(mob/living/user, loud, access_to_check)
	return SStrade.enabled && ..()

/datum/computer_file/program/trade_orders
	parent_type = /datum/computer_file/program/trade
	filename = "trade_orders"
	program_type = "ordering"
	usage_flags = PROGRAM_ALL
	filedesc = "Frontier Trade Requisitions"
	nanomodule_path = /datum/nano_module/program/trade_orders
	extended_desc = "Purchase freight with an inserted ID or request department funding."
	size = 5

/datum/nano_module/program/trade_orders
	parent_type = /datum/nano_module/program/trade
	name = "Frontier Trade Requisitions"

/datum/nano_module/program/trade
	name = "Frontier Trade Network"
	available_to_ai = TRUE
	var/program_type = "master"
	var/chosen_category = ""
	var/log_filter = "All"
	var/cart_station = ""
	var/cart_category = ""
	var/selected_order_id
	var/selected_log_id
	var/sender_id
	var/receiver_id
	var/screen = "goods"
	var/selected_station = "engineering"
	var/list/cart = list()
	var/list/saved_carts = list()
	var/list/saved_names = list()
	var/next_saved_id = 0
	var/message = ""
	var/prg_screen = TRUE
	var/list/pages = list()
	var/read_only = FALSE
	var/datum/money_account/linked_account
	var/obj/item/card/id/linked_card

/datum/nano_module/program/trade/New(host, topic_manager, datum/computer_file/program/program)
	..()
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

/datum/nano_module/program/trade/Destroy()
	cart = null
	saved_carts = null
	saved_names = null
	program = null
	linked_account = null
	linked_card = null
	pages = null
	return ..()

/datum/nano_module/program/trade/proc/is_manager(mob/user)
	return !read_only && program_type == "master" && user && (access_cargo in user.GetAccess())

/datum/nano_module/program/trade/proc/is_hacked()
	return !read_only && !istype(program, /datum/computer_file/program/trade_orders) && program?.computer?.emagged()

/datum/nano_module/program/trade/proc/get_inserted_card()
	var/obj/item/stock_parts/computer/card_slot/slot = program?.computer?.get_component(PART_CARD)
	return slot?.stored_card

/datum/nano_module/program/trade/proc/get_user_key(mob/user)
	return user?.ckey || (user ? "\ref[user]" : "")

/datum/nano_module/program/trade/proc/can_view_order(datum/trade_order/order, mob/user)
	var/obj/item/card/id/card = get_inserted_card()
	return is_manager(user) || order.requester_key == get_user_key(user) || (order.account && card?.associated_account_number == order.account.account_number)

/datum/nano_module/program/trade/proc/authenticate(mob/user)
	var/obj/item/card/id/card = get_inserted_card()
	var/datum/money_account/account = card ? get_account(card.associated_account_number) : null
	if(!account || account.suspended)
		return
	var/pin = 0
	if(account.security_level)
		pin = input(user, "Enter account PIN", "Trade payment") as null|num
	if(QDELETED(src) || get_inserted_card() != card || !can_still_topic())
		return
	return attempt_account_access(card.associated_account_number, pin, 2)

/datum/nano_module/program/trade/proc/get_linked_account()
	if(!linked_account || QDELETED(linked_account) || QDELETED(linked_card) || linked_account.suspended || get_inserted_card() != linked_card || get_account(linked_card?.associated_account_number) != linked_account)
		unlink_account()
	return linked_account

/datum/nano_module/program/trade/proc/unlink_account()
	linked_account = null
	linked_card = null

/datum/nano_module/program/trade/proc/link_account(mob/user)
	var/datum/money_account/account = authenticate(user)
	if(!account || QDELETED(src))
		return
	linked_account = account
	linked_card = get_inserted_card()

/datum/computer_file/program/pda/trade
	parent_type = /datum/computer_file/program/trade
	filename = "trade_catalog"
	filedesc = "Frontier Catalog"
	nanomodule_path = /datum/nano_module/program/trade/pda
	extended_desc = "Browse discovered frontier vendors, stock, prices and bounties."
	size = 4
	usage_flags = PROGRAM_PDA | PROGRAM_TABLET

/datum/nano_module/program/trade/pda
	name = "Frontier Catalog"
	read_only = TRUE

/datum/computer_file/program/trade/slave
	filename = "trade_local"
	filedesc = "Local Trade Terminal"
	program_type = "slave"
	nanomodule_path = /datum/nano_module/program/trade/slave
	extended_desc = "Trade through beacons in this room. Personal bounty rewards pay a 20% cargo commission."
	size = 8

/datum/nano_module/program/trade/slave
	name = "Local Trade Terminal"
