#define SETTINGS_SCREEN "settings"
#define GOODS_SCREEN "goods"
#define OFFER_SCREEN "offers"
#define CART_SCREEN "cart"
#define ORDER_SCREEN "orders"
#define SAVED_SCREEN "saved"
#define LOG_SCREEN "logs"
#define LOG_SHIPPING "Shipping"
#define LOG_EXPORT "Export"
#define LOG_OFFER "Offer"
#define LOG_ORDER "Order"
#define PRG_MAIN TRUE
#define PRG_TREE FALSE
#define TRADESCREEN list(GOODS_SCREEN, OFFER_SCREEN, CART_SCREEN, ORDERS_SCREEN, SAVED_SCREEN)
#define LOG_SCREEN_LIST list(LOG_SHIPPING, LOG_EXPORT, LOG_OFFER, LOG_ORDER)

/datum/computer_file/program/supply
	filename = "supply"
	filedesc = "Supply Management"
	//nanomodule_path = /datum/nano_module/program/supply
	ui_header = null // Set when enabled by an admin user.
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "A management tool that allows for ordering of various supplies through the facility's cargo system. Some features may require additional access."
	size = 21
	available_on_ntnet = FALSE
	requires_ntnet = TRUE
	category = PROG_SUPPLY
	usage_flags = PROGRAM_CONSOLE

	var/program_type = "master"	// master, slave, ordering

	// Our associated trade faction
	var/faction = FACTION_INDEPENDENT
	// Point at world.time when we can set/reset the faction again
	var/faction_cooldown
	// How often we can change faction on the console
	var/faction_cooldown_time = 2 MINUTES

	var/prg_screen = PRG_TREE
	var/trade_screen = GOODS_SCREEN
	var/log_screen

	var/obj/machinery/trade_beacon/sending/sending
	var/obj/machinery/trade_beacon/receiving/receiving
	var/datum/money_account/account

	var/list/shopping_list = list() // list(trade_station = list(category = list(path, path, ...)))
	var/list/saved_shopping_lists = list()
	var/saved_cart_id = 0
	var/saved_cart_page = 1
	var/saved_cart_page_max

	var/datum/trading_station/station
	var/chosen_category

	var/cart_station_index
	var/cart_category_index

	var/current_order
	var/current_order_page = 1
	var/order_page_max
	// For preventing order spam
	var/orders_locked = FALSE

	var/current_log_page = 1
	var/log_page_max

/datum/computer_file/program/supply/OnStoreFile(obj/item/stock_parts/computer/hard_drive/HD)
	. = ..()
	if(!istype(HD))
		return

	var/atom/stored_loc = HD.loc
	if(istype(stored_loc) && (stored_loc.z in GLOB.using_map.station_levels))
		faction = GLOB.using_map.trade_faction

/datum/computer_file/program/supply/proc/SetChosenCategory(value)
	if(isnum(value))
		value = station.inventory[value]
	chosen_category = value

/datum/computer_file/program/supply/proc/OpenShopList()
	var/list/category_list = list()
	var/list/inventory_list = list()

	// Add the station to shopping list if it isn't here already
	LAZYDISTINCTADD(shopping_list, station)

	// If nothing has been added under this station, create an empty list
	if(!islist(shopping_list[station]))
		shopping_list[station] = list()

	// Make the category list point to the current station's category list
	category_list = shopping_list[station]
	// Add the category to the shopping list if it doesn't already exist
	LAZYDISTINCTADD(category_list, chosen_category)

	// If nothing has been added under this category, create an empty list
	if(!islist(category_list[chosen_category]))
		category_list[chosen_category] = list()

	// Make the inventory list point to the current category's inventory list
	inventory_list = category_list[chosen_category]

	return inventory_list // Return a reference to the current category's list of items

/datum/computer_file/program/supply/proc/SanitizeShopList()
	var/list/category_list = list()

	for(var/station in shopping_list)
		category_list = shopping_list[station]
		for(var/category in category_list)
			if(!LAZYLEN(category_list[category]))
				category_list -= category
		if(!LAZYLEN(category_list))
			shopping_list -= station
			cart_station_index = null

	if(!LAZYLEN(shopping_list))
		cart_category_index = null
		cart_station_index = null

/datum/computer_file/program/supply/proc/AddToShopList(path, amount, limit)
	if(!path)
		return
	var/list/inventory_list = OpenShopList()		// Get reference to inventory list
	LAZYDISTINCTADD(inventory_list, path)
	LAZYAPLUS(inventory_list, path, amount)

	if(inventory_list[path] > limit)
		LAZYSET(inventory_list, path, limit)

/datum/computer_file/program/supply/proc/RemoveFromShopList(path, amount)
	var/list/inventory_list = OpenShopList()		// Get reference to inventory list
	if(inventory_list.Find(path))					// If path exists, subtract from amount
		inventory_list[path] -= amount					// Not using LAZYAMINUS() because we only want to sanitize the whole list if the path is removed
		if(inventory_list[path] < 1)				// If amount is less than 1, remove from list
			inventory_list -= path
			SanitizeShopList()					// Don't need to sanitize every time, just when we're removing a path from the list

/datum/computer_file/program/supply/proc/ResetShopList()
	shopping_list = list()
	cart_category_index = null
	cart_station_index = null

/datum/computer_file/program/supply/proc/SaveShopList(name, list/shop_list = null)
	// Need to open and copy every list within the list since copying the list just makes a list of references
	var/list/list_to_copy

	if(!shop_list)
		list_to_copy = shopping_list
	else if(islist(shop_list))
		list_to_copy = shop_list

	var/list/list_to_save = list_to_copy.Copy()

	for(var/station in list_to_copy)
		var/list/categories = list_to_copy[station]
		var/list/categories_copy = categories.Copy()
		for(var/category in categories)
			var/list/goods = categories[category]
			LAZYSET(categories_copy, category, goods.Copy())
		LAZYSET(list_to_save, station, categories_copy)

	var/list_name = name ? name : "Saved Cart #[++saved_cart_id]"

	LAZYDISTINCTADD(saved_shopping_lists, list_name)
	LAZYSET(saved_shopping_lists, list_name, list_to_save)

/datum/computer_file/program/supply/proc/LoadShopList(name)
	if(!saved_shopping_lists.Find(name))
		return

	// Need to open and copy every list within the list since copying the list just makes a list of references
	var/list/list_to_copy = saved_shopping_lists[name]
	var/list/list_to_load = list_to_copy.Copy()

	for(var/station in list_to_copy)
		var/list/categories = list_to_copy[station]
		var/list/categories_copy = categories.Copy()
		for(var/category in categories)
			var/list/goods = categories[category]
			LAZYSET(categories_copy, category, goods.Copy())
		LAZYSET(list_to_load, station, categories_copy)

	return list_to_load.Copy()

/datum/computer_file/program/supply/proc/DeleteShopList(name)
	if(!saved_shopping_lists.Find(name))
		return

	saved_shopping_lists -= name

/datum/computer_file/program/supply/proc/UnlockOrdering()
	orders_locked = FALSE

/datum/computer_file/program/supply/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(get_dist(usr, holder.loc) > 1)
		return FALSE

	if(href_list["PRG_update"])
		return TRUE

	if(href_list["PRG_prg_screen"])
		prg_screen = !prg_screen
		return TRUE

	if(href_list["PRG_trade_screen"])
		trade_screen = href_list["PRG_trade_screen"]
		return TRUE

	if(href_list["PRG_log_screen"])
		if(!(href_list["PRG_log_screen"] in LOG_SCREEN_LIST))
			return FALSE

		log_screen = href_list["PRG_log_screen"]
		current_log_page = 1
		return TRUE

	if(href_list["PRG_goods_category"])
		if(!chosen_category || !(chosen_category in station.inventory))
			SetChosenCategory()
		SetChosenCategory(href_list["PRG_goods_category"])
		return TRUE

	if(href_list["PRG_faction"])
		if(faction_cooldown > world.time)
			to_chat(usr, SPAN_WARNING("The option is currently unavailable! Try again later!"))
			return

		var/obj/item/stock_parts/computer/card_slot/card_slot = computer.get_component(PART_CARD)
		if(!istype(card_slot))
			to_chat(usr, SPAN_WARNING("Card slot is not installed."))
			return

		var/obj/item/card/id/id = card_slot.stored_card
		if(!istype(id))
			to_chat(usr, SPAN_WARNING("Please insert ID card."))
			return

		var/list/valid_factions = list()
		for(var/fname in SSsupply.factions)
			var/datum/trade_faction/TF = SSsupply.factions[fname]
			if(!TF.access_required)
				continue
			if(!(TF.access_required in id.access))
				continue
			valid_factions += TF.name

		if(!LAZYLEN(valid_factions))
			to_chat(usr, SPAN_WARNING("Unable to find any relevant access levels."))
			return

		var/faction_chosen = input("Select a faction to link", "Faction linking") as null|anything in (list("-- Cancel --") + valid_factions)
		var/datum/trade_faction/TF = SSsupply.GetFaction(faction_chosen)
		if(!istype(TF))
			return

		faction = faction_chosen
		faction_cooldown = world.time + faction_cooldown_time
		return TRUE

	if(href_list["PRG_faction_unlink"])
		if(faction_cooldown > world.time)
			to_chat(usr, SPAN_WARNING("The option is currently unavailable! Try again later!"))
			return

		faction = FACTION_INDEPENDENT
		return TRUE

	if(href_list["PRG_account"])
		var/obj/item/stock_parts/computer/card_slot/card_slot = computer.get_component(PART_CARD)
		var/obj/item/card/id/ID = card_slot.stored_card
		if(!istype(ID))
			ID = usr.GetIdCard()
		// Account security level is 0 - auto-login from the ID
		var/autofill = null
		if(istype(ID) && ID.associated_account_number)
			var/datum/money_account/A = get_account(ID.associated_account_number)
			if(istype(A) && A.security_level == 0)
				autofill = ID.associated_account_number
		var/acc_num = input("Enter account number", "Account linking", autofill) as num|null
		if(!acc_num)
			return

		// 0 sec level - auto login
		var/datum/money_account/A = attempt_account_access(acc_num)
		if(istype(A))
			account = A
			return TRUE

		var/acc_pin = input("Enter PIN", "Account linking") as num|null
		if(!acc_pin)
			return

		var/card_check = ID.associated_account_number == acc_num
		A = attempt_account_access(acc_num, acc_pin, card_check ? 2 : 1, TRUE)
		if(!A)
			to_chat(usr, SPAN_WARNING("Unable to link account: access denied."))
			return

		account = A
		return TRUE

	if(href_list["PRG_account_unlink"])
		account = null
		current_order = null
		return TRUE

	if(href_list["PRG_station"])
		var/datum/trading_station/S = SSsupply.GetVisibleStationByUid(href_list["PRG_station"])
		if(!S)
			return
		SetChosenCategory()
		station = S
		return TRUE

	// Cart buttons
	if(href_list["PRG_cart_reset"])
		ResetShopList()
		return TRUE

	if(href_list["PRG_cart_add"] || href_list["PRG_cart_add_input"])
		if(!account)
			to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
			return
		if(account.suspended)
			to_chat(usr, SPAN_WARNING("ERROR: Linked account is suspended."))
			return
		if(LAZYLEN(station.whitelist_factions) && !(faction in station.whitelist_factions))
			to_chat(usr, SPAN_WARNING("ERROR: Trading is forbidden for your associated faction."))
			return
		if(LAZYLEN(station.blacklist_factions) && (faction in station.blacklist_factions))
			to_chat(usr, SPAN_WARNING("ERROR: Trading is forbidden for your associated faction."))
			return
		var/ind
		var/count2buy = 1
		if(href_list["PRG_cart_add_input"])
			count2buy = input(usr, "Input how many you want to add", "Trade", 2) as num
			ind = text2num(href_list["PRG_cart_add_input"])
		else
			ind = text2num(href_list["PRG_cart_add"])
		var/list/category = station.inventory[chosen_category]
		if(!islist(category))
			return
		var/path = LAZYACCESS(category, ind)
		if(!path)
			return
		var/good_amount = station.GetGoodAmount(chosen_category, ind)
		if(!good_amount)
			return

		// Double check for input
		if(!account)
			to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
			return
		if(account.suspended)
			to_chat(usr, SPAN_WARNING("ERROR: Linked account is suspended."))
			return
		if(LAZYLEN(station.whitelist_factions) && !(faction in station.whitelist_factions))
			to_chat(usr, SPAN_WARNING("ERROR: Trading is forbidden for your associated faction."))
			return
		if(LAZYLEN(station.blacklist_factions) && (faction in station.blacklist_factions))
			to_chat(usr, SPAN_WARNING("ERROR: Trading is forbidden for your associated faction."))
			return

		AddToShopList(path, count2buy, good_amount)
		return TRUE

	if(href_list["PRG_cart_remove"])
		if(!account)
			to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
			return
		var/list/category = station.inventory[chosen_category]
		if(!islist(category))
			return
		var/path = LAZYACCESS(category, text2num(href_list["PRG_cart_remove"]))
		if(!path)
			return

		RemoveFromShopList(path, 1)
		return TRUE

	if(href_list["PRG_cart_category"])
		cart_category_index = text2num(href_list["PRG_cart_category"])
		return TRUE

	if(href_list["PRG_cart_station"])
		cart_station_index = text2num(href_list["PRG_cart_station"])
		cart_category_index = null
		return TRUE

	if(href_list["PRG_cart_save"])
		var/name = sanitizeName(input("Would you like to name the saved cart? (Not required)", "Save Cart"), MAX_NAME_LEN)
		SaveShopList(name)
		return TRUE

	if(href_list["PRG_cart_load"])
		var/name = input("Choose a cart to load", "Load Cart", null) as null|anything in saved_shopping_lists
		if(!name)
			to_chat(usr, SPAN_WARNING("ERROR: Invalid cart."))
			return
		shopping_list = LoadShopList(name)
		trade_screen = CART_SCREEN
		return TRUE

	if(href_list["PRG_cart_load_direct"])
		var/name = saved_shopping_lists[text2num(href_list["PRG_cart_load_direct"])]
		if(!name)
			to_chat(usr, SPAN_WARNING("ERROR: Invalid cart."))
			return
		shopping_list = LoadShopList(name)
		trade_screen = CART_SCREEN
		return TRUE

	if(href_list["PRG_cart_delete"])
		var/name = saved_shopping_lists[text2num(href_list["PRG_cart_delete"])]
		DeleteShopList(name)
		return TRUE

	// Order requests
	if(href_list["PRG_reason"])
		var/reason = sanitizeName(input("Enter reason(s) for order", "Request Reason", ""), MAX_NAME_LEN)
		var/list/order = SSsupply.order_queue[current_order]
		order["reason"] = reason
		return TRUE

	if(href_list["PRG_build_order"])
		if(orders_locked)
			to_chat(usr, SPAN_WARNING("ERROR: You cannot place an order at this time. Please wait 10 seconds."))
			return
		if(account.suspended)
			to_chat(usr, SPAN_WARNING("ERROR: Linked account is suspended."))
			return
		var/reason = sanitizeName(input("Enter reason(s) for order", "Request Reason", ""), MAX_NAME_LEN)
		current_order = SSsupply.BuildOrder(account, reason, shopping_list)
		shopping_list = list()
		trade_screen = ORDER_SCREEN
		if(account != department_accounts["Supply"])
			orders_locked = TRUE
			addtimer(new Callback(src, PROC_REF(UnlockOrdering)), 10 SECONDS, TIMER_STOPPABLE)
		return TRUE

	if(href_list["PRG_view_order"])
		current_order = href_list["PRG_view_order"]
		return TRUE

	if(href_list["PRG_remove_order"])
		SSsupply.order_queue.Remove(href_list["PRG_remove_order"])
		if(current_order == href_list["PRG_remove_order"])
			current_order = null
		return TRUE

	if(href_list["PRG_save_order"])
		var/order_id = href_list["PRG_save_order"]
		if(!order_id || !SSsupply.order_queue.Find(order_id))
			to_chat(usr, SPAN_WARNING("ERROR: Order does not exist."))
			return
		var/name = sanitizeName(input("Would you like to name the saved cart? (Not required)", "Save Cart"), MAX_NAME_LEN)
		var/list/order_data = SSsupply.order_queue[order_id]
		SaveShopList(name, order_data["contents"])
		return TRUE

	// Logs
	if(href_list["PRG_print"] || href_list["PRG_print_internal"])
		if(!computer.get_component(PART_PRINTER))
			to_chat(usr, SPAN_WARNING("Unable to print invoice: no printer component installed."))
			return TRUE

		var/log_id = href_list["PRG_print"] || href_list["PRG_print_internal"]
		var/list/log_data = SSsupply.GetLogDataById(log_id)
		if(!log_data.len)
			to_chat(usr, SPAN_WARNING("Unable to print invoice: no log with id \"[log_id]\" found."))
			return

		var/id_data = splittext(log_id, "-")
		var/log_type = id_data[2]

		switch(log_type)
			if("S")
				log_type = "Shipping"
			if("E")
				log_type = "Export"
			if("SO")
				log_type = "Special Offer"
			if("O")
				log_type = "Order"
			else
				return

		var/title
		title = "[lowertext(log_type)] invoice - #[log_id]"
		title += href_list["PRG_print_internal"] ? " (internal)" : null

		var/text
		text += "<h3>[log_type] Invoice - #[log_id]</h3>"
		text += "<hr><font size = \"2\">"
		text += href_list["PRG_print_internal"] ? "FOR INTERNAL USE ONLY<br><br>" : null
		text += log_type != "Shipping" && log_type ? "Recipient: [log_data["ordering_acct"]]<br>" : "Recipient: \[field\]<br>"
		text += log_type == "Shipping" ? "Package Name: \[field\]<br>" : null
		text += "Contents:<br>"
		text += "<ul>"
		text += log_data["contents"]
		text += "</ul>"
		text += href_list["PRG_print_internal"] ? "Order Cost: [log_data["total_paid"]]<br>" : null
		text += log_type == "Shipping" ? "Total Credits Paid: \[field\]<br>" : "Total Credits Paid: [log_data["total_paid"]]<br>"
		text += "</font>"
		text += log_type == "Shipping" ? "<hr><h5>Stamp below to confirm receipt of goods:</h5>" : null

		computer.print_paper(text, title)
		return TRUE

	// Page navigation
	if(href_list["PRG_page_first"])
		switch(href_list["PRG_page_first"])
			if(ORDER_SCREEN)
				current_order_page = 1
			if(SAVED_SCREEN)
				saved_cart_page = 1
			if(LOG_SCREEN)
				current_log_page = 1
		return TRUE

	if(href_list["PRG_page_prev_10"])
		switch(href_list["PRG_page_prev_10"])
			if(ORDER_SCREEN)
				current_order_page = max(1, current_order_page - 10)
			if(SAVED_SCREEN)
				saved_cart_page = max(1, saved_cart_page - 10)
			if(LOG_SCREEN)
				current_log_page = max(1, current_log_page - 10)
		return TRUE

	if(href_list["PRG_page_prev"])
		switch(href_list["PRG_page_prev"])
			if(ORDER_SCREEN)
				current_order_page = max(1, --current_order_page)
			if(SAVED_SCREEN)
				saved_cart_page = max(1, --saved_cart_page)
			if(LOG_SCREEN)
				current_log_page = max(1, --current_log_page)
		return TRUE

	if(href_list["PRG_page_select"])
		var/input
		switch(href_list["PRG_page_select"])
			if(ORDER_SCREEN)
				input = input("Enter page number (1-[order_page_max])", "Page Selection") as num|null
				if(!input)
					return
				current_order_page = clamp(input, 1, order_page_max)
			if(SAVED_SCREEN)
				input = input("Enter page number (1-[saved_cart_page_max])", "Page Selection") as num|null
				if(!input)
					return
				saved_cart_page = clamp(input, 1, saved_cart_page_max)
			if(LOG_SCREEN)
				current_log_page = clamp(input, 1, log_page_max)
		return TRUE

	if(href_list["PRG_page_next"])
		switch(href_list["PRG_page_next"])
			if(ORDER_SCREEN)
				current_order_page = min(order_page_max, ++current_order_page)
			if(SAVED_SCREEN)
				saved_cart_page = min(saved_cart_page_max, ++saved_cart_page)
			if(LOG_SCREEN)
				current_log_page = min(log_page_max, ++current_log_page)
		return TRUE

	if(href_list["PRG_page_next_10"])
		switch(href_list["PRG_page_next_10"])
			if(ORDER_SCREEN)
				current_order_page = min(order_page_max, current_order_page + 10)
			if(SAVED_SCREEN)
				saved_cart_page = min(saved_cart_page_max, saved_cart_page + 10)
			if(LOG_SCREEN)
				current_log_page = min(log_page_max, current_log_page + 10)
		return TRUE

	if(href_list["PRG_page_last"])
		switch(href_list["PRG_page_last"])
			if(ORDER_SCREEN)
				current_order_page = order_page_max
			if(SAVED_SCREEN)
				saved_cart_page = saved_cart_page_max
			if(LOG_SCREEN)
				current_log_page = log_page_max
		return TRUE

	// Functions used by the regular trading programs
	if(program_type != "ordering")
		if(href_list["PRG_receiving"])
			var/list/beacons_by_id = list()
			for(var/obj/machinery/trade_beacon/receiving/beacon in SSsupply.beacons_receiving)
				if(get_area(beacon) == get_area(computer) || program_type == "master")
					var/beacon_id = beacon.GetId()
					beacons_by_id.Insert(beacon_id, beacon_id)
					beacons_by_id[beacon_id] = beacon
			if(beacons_by_id.len == 1)
				receiving = beacons_by_id[beacons_by_id[1]]
			else
				var/id = input("Select nearby receiving beacon", "Receiving Beacon", null) as null|anything in beacons_by_id
				receiving = beacons_by_id[id]
			return TRUE

		if(href_list["PRG_sending"])
			var/list/beacons_by_id = list()
			for(var/obj/machinery/trade_beacon/sending/beacon in SSsupply.beacons_sending)
				if(get_area(beacon) == get_area(computer) || program_type == "master")
					var/beacon_id = beacon.GetId()
					beacons_by_id.Insert(beacon_id, beacon_id)
					beacons_by_id[beacon_id] = beacon
			if(beacons_by_id.len == 1)
				sending = beacons_by_id[beacons_by_id[1]]
			else
				var/id = input("Select nearby sending beacon", "Sending Beacon", null) as null|anything in beacons_by_id
				sending = beacons_by_id[id]
			return TRUE

		if(receiving)
			if(href_list["PRG_receive"])
				if(!account)
					to_chat(usr, SPAN_WARNING("ERROR: No account linked."))
					return
				if(account.suspended)
					to_chat(usr, SPAN_WARNING("ERROR: Linked account is suspended."))
					return
				if(get_area(receiving) != get_area(computer) && program_type != "master")
					to_chat(usr, SPAN_WARNING("ERROR: Receiving beacon is too far from \the [computer]."))
					return
				if(!SSsupply.Buy(receiving, account, shopping_list, FALSE, null, faction))
					to_chat(usr, SPAN_WARNING("ERROR: Purchase failed."))
					return FALSE
				ResetShopList()
				return TRUE

		if(sending)
			if(href_list["PRG_export"])
				if(get_area(sending) != get_area(computer) && program_type != "master")
					to_chat(usr, SPAN_WARNING("ERROR: Sending beacon is too far from \the [computer]."))
					return
				if(account.suspended)
					to_chat(usr, SPAN_WARNING("ERROR: Linked account is suspended."))
					return
				SSsupply.Export(sending, account, faction)
				return TRUE

		if(href_list["PRG_approve_order"])
			if(!account)
				return
			var/order = href_list["PRG_approve_order"]
			var/list/order_data = SSsupply.order_queue[order]
			var/order_cost = order_data["cost"]
			var/requestor_cost = order_data["cost"] + order_data["fee"]
			var/datum/money_account/requesting_account = order_data["requesting_acct"]

			if(account.money < order_cost)
				to_chat(usr, SPAN_WARNING("ERROR: Not enough funds in account ([account.owner_name] #[account.account_number])."))
				return
			if(requesting_account.money < requestor_cost)
				to_chat(usr, SPAN_WARNING("ERROR: Not enough funds in requesting account ([requesting_account.owner_name] #[requesting_account.account_number])."))
				return

			SSsupply.PurchaseOrder(receiving, order, faction)
			SSsupply.order_queue.Remove(order)
			if(current_order == order)
				current_order = null
			return TRUE

// This should be a nano-ui module in near future; This is mostly for testing purposes and setting the groundworks
/datum/computer_file/program/supply/Topic(href, href_list)
	. = ..()
	if(.)
		ui_interact(usr)

/datum/computer_file/program/supply/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	. = ..()
	if(!.)
		return

	var/dat

	dat += trade_screen == SETTINGS_SCREEN ? "<b><u>Settings</u></b>" :"<A href='?src=\ref[src];PRG_trade_screen=[SETTINGS_SCREEN]'>Settings</A>"
	dat += " | "
	dat += trade_screen == GOODS_SCREEN ? "<b><u>Traders</u></b>" :"<A href='?src=\ref[src];PRG_trade_screen=[GOODS_SCREEN]'>Traders</A>"
	dat += " | "
	dat += trade_screen == OFFER_SCREEN ? "<b><u>Export</u></b>" :"<A href='?src=\ref[src];PRG_trade_screen=[OFFER_SCREEN]'>Export</A>"
	dat += " | "
	dat += trade_screen == CART_SCREEN ? "<b><u>Cart</u></b>" :"<A href='?src=\ref[src];PRG_trade_screen=[CART_SCREEN]'>Cart</A>"
	dat += " | "
	dat += trade_screen == LOG_SCREEN ? "<b><u>Logs</u></b>" :"<A href='?src=\ref[src];PRG_trade_screen=[LOG_SCREEN]'>Logs</A>"
	dat += " | "
	dat += "<A href='?src=\ref[src];PC_exit=1'>Exit</A>"

	dat += "<hr>"

	if(trade_screen == SETTINGS_SCREEN)
		if(faction)
			dat += "Associated Faction: [faction]<br>"
			if(faction != FACTION_INDEPENDENT)
				dat += "<A href='?src=\ref[src];PRG_faction_unlink=1'>Reset Faction</A><br>"
			dat += "<br>"
		if(!faction || faction == FACTION_INDEPENDENT)
			dat += "<A href='?src=\ref[src];PRG_faction=1'>Link Faction</A><br><br>"

		if(account)
			dat += "Current Account: [account.owner_name][account.suspended ? " <span style='color: [COLOR_RED]'>\[SUSPENDED\]</span>" : ""]<br>"
			dat += "Balance: [account.get_balance()]<br>"
			dat += "<a href='?src=\ref[src];PRG_account_unlink=1'>Unlink</A><br><br>"
		else
			dat += "<A href='?src=\ref[src];PRG_account=1'>Link Account</A><br><br>"

		if(receiving)
			var/area/A = get_area(receiving)
			dat += "Receiving Beacon: [A.name]<br>"
		dat += "<A href='?src=\ref[src];PRG_receiving=1'>Set Receiving Beacon</A><br><br>"

		if(sending)
			var/area/A = get_area(sending)
			dat += "Sending Beacon: [A.name]<br>"
		dat += "<A href='?src=\ref[src];PRG_sending=1'>Set Sending Beacon</A>"

	if(trade_screen == GOODS_SCREEN)
		for(var/i = 1 to length(SSsupply.visible_trading_stations))
			var/datum/trading_station/TS = SSsupply.visible_trading_stations[i]
			var/datum/trade_faction/TF = SSsupply.GetFaction(TS.faction)
			var/faction_relations = TF.relationship[faction]
			var/faction_color = TradeRelationsColor(faction_relations)
			if(TS == station)
				dat += "<b><u>[TS.name]</b></u>"
			else
				dat += "<A href='?src=\ref[src];PRG_station=[TS.uid]'><span style='color: [faction_color]'>[TS.name]</span></A>"

			if(i != length(SSsupply.visible_trading_stations))
				dat += " | "

		dat += "<hr>"

		if(station)
			var/datum/trade_faction/TF = SSsupply.GetFaction(station.faction)
			var/faction_relations = TF.relationship[faction]
			var/faction_color = TradeRelationsColor(faction_relations)
			dat += "<b>[station.name] <span style='color: [faction_color]'>([station.faction])</span></b><br>"
			dat += "[station.desc]<br>"
			dat += "Favor: [station.favor]/[station.unlock_favor]<br>"

			dat += "<hr>"

			if(faction in TF.embargo)
				dat += "<b>Economic Embargo has been issued by [station.faction] officials.<br>"
				dat += "Access to [station.name] is denied until further notice.</b>"
			else if(LAZYLEN(station.whitelist_factions) && !(faction in station.whitelist_factions))
				dat += "<b>Access to [station.name] is denied to outside parties.</b>"
			else if(LAZYLEN(station.blacklist_factions) && (faction in station.blacklist_factions))
				dat += "<b>Access to [station.name] is denied to your associated faction.</b>"
			else
				if(!chosen_category || !(chosen_category in station.inventory))
					SetChosenCategory()
				for(var/i = 1 to length(station.inventory))
					var/cat = station.inventory[i]
					if(cat == chosen_category)
						dat += "<b><u>[cat]</b></u>"
					else
						dat += "<A href='?src=\ref[src];PRG_goods_category=[cat]'>[cat]</A>"

					if(i != length(station.inventory))
						dat += " | "

				dat += "<hr>"

				var/list/assort = station.inventory[chosen_category]
				if(islist(assort))
					for(var/path in assort)
						if(!ispath(path, /atom/movable))
							continue
						var/index = assort.Find(path)
						var/amount = station.GetGoodAmount(chosen_category, index)

						var/atom/movable/AM = path
						var/pathname = initial(AM.name)

						var/list/good_packet = assort[path]
						if(islist(good_packet))
							pathname = good_packet["name"] ? good_packet["name"] : pathname

						var/basic_price = SSsupply.GetBasicImportCost(path, station)
						var/price = SSsupply.GetImportCost(path, station, faction)
						var/faction_markup_percent = round(price / basic_price, 0.01) * 100 - 100

						dat += "[pathname]: [price] [GLOB.using_map.local_currency_name_short][price == basic_price ? "" : (price > basic_price ? " (+[faction_markup_percent]%)" : " (-[faction_markup_percent]%)")], x[amount] in stock. <A href='?src=\ref[src];PRG_cart_add=[index]'>Add 1</A> <A href='?src=\ref[src];PRG_cart_add_input=[index]'>Add...</A><br>"

	if(trade_screen == OFFER_SCREEN)
		if(!sending)
			dat += "<b>Sending beacon is missing!</b>"
		else
			dat += "<A href='?src=\ref[src];PRG_update=1'>Update</A> "
			dat += "<A href='?src=\ref[src];PRG_export=1'>Export</A>"
			dat += "<hr>"
			if(sending.export_cooldown > world.time)
				dat += "<b>Export cooldown: [round((sending.export_cooldown - world.time) / 10)] seconds</b>"
				dat += "<hr>"
			var/total_cost = 0
			for(var/atom/movable/AM in sending.GetObjects())
				if(ishuman(AM))
					continue
				var/list/contents_incl_self = AM.GetAllContents(3, TRUE)
				if(is_path_in_list(/mob/living/carbon/human, contents_incl_self))
					continue
				var/cost = 0
				var/normal_cost = 0
				for(var/atom/movable/item in reverselist(contents_incl_self))
					cost += SSsupply.GetExportValue(item)
					normal_cost += get_value(item)
				if(!cost)
					continue
				dat += "- [AM.name] ([cost] [GLOB.using_map.local_currency_name_short])"
				if(cost < normal_cost)
					var/percent_diff = round(cost / normal_cost, 0.01) * 100
					dat += " <span style='color: [COLOR_RED]'>([percent_diff]%)</span>"
				else if(cost > normal_cost)
					var/percent_diff = round(cost / normal_cost, 0.01) * 100
					dat += " <span style='color: [COLOR_GREEN]'>([percent_diff]%)</span>"
				dat += "<br>"
				total_cost += cost
			if(total_cost)
				dat += "<b>Total export cost: [total_cost] [GLOB.using_map.local_currency_name_short]</b>"
			else
				dat += "<b>There is no items for export within sending beacon's range!</b>"

	if(trade_screen == CART_SCREEN)
		dat += "<A href='?src=\ref[src];PRG_receive=1'>Purchase</A> | "
		dat += "<A href='?src=\ref[src];PRG_cart_reset=1'>Clear cart</A><br>"

		dat += "<hr>"

		for(var/datum/trading_station/TS in shopping_list)
			dat += "[TS.name]:<br>"
			for(var/cat in shopping_list[TS])
				dat += "- [cat]:<br>"
				for(var/path in shopping_list[TS][cat])
					var/atom/movable/AM = path
					var/good_name = initial(AM.name)
					var/list/good_packet = TS.inventory[cat][path]
					if(islist(good_packet))
						good_name = good_packet["name"] ? good_packet["name"] : good_name
					dat += "- - [good_name] x[shopping_list[TS][cat][path]]<br>"
				dat += "<br>"
			dat += "<br>"

	if(trade_screen == LOG_SCREEN)
		dat += log_screen == LOG_SHIPPING ? "<b><u>Shipping</u></b>" :"<A href='?src=\ref[src];PRG_log_screen=[LOG_SHIPPING]'>Shipping</A>"
		dat += " | "
		dat += log_screen == LOG_EXPORT ? "<b><u>Export</u></b>" :"<A href='?src=\ref[src];PRG_log_screen=[LOG_EXPORT]'>Export</A>"

		dat += "<hr>"

		switch(log_screen)
			if(LOG_SHIPPING)
				var/list/L = SSsupply.shipping_log.Copy()
				for(var/list/log in reverseRange(L))
					dat += "Time: [log["time"]]<br>"
					dat += "Account: [log["ordering_acct"]]<br>"
					dat += "Link: [log["assoc_faction"]]<br>"
					dat += "Total invoice: [log["total_paid"]] [GLOB.using_map.local_currency_name_short]<br>"
					dat += "Articles bought: [log["contents"]]<br>"
					dat += "<A href='?src=\ref[src];PRG_print=[log["id"]]'>Print</A>"
					dat += "<hr>"
			if(LOG_EXPORT)
				var/list/L = SSsupply.export_log.Copy()
				for(var/list/log in reverseRange(L))
					dat += "Time: [log["time"]]<br>"
					dat += "Account: [log["ordering_acct"]]<br>"
					dat += "Link: [log["assoc_faction"]]<br>"
					dat += "Total invoice: [log["total_paid"]] [GLOB.using_map.local_currency_name_short]<br>"
					dat += "Articles sold: [log["contents"]]<br>"
					dat += "<A href='?src=\ref[src];PRG_print=[log["id"]]'>Print</A>"
					dat += "<hr>"

	var/datum/browser/popup = new(user, "supply_prg", "Trade Network", 600, 680)
	popup.set_content(dat)
	popup.open()
	onclose(user, "supply_prg")

#undef SETTINGS_SCREEN
#undef GOODS_SCREEN
#undef OFFER_SCREEN
#undef CART_SCREEN
#undef ORDER_SCREEN
#undef SAVED_SCREEN
#undef PRG_MAIN
#undef PRG_TREE
#undef LOG_SCREEN
#undef LOG_SHIPPING
#undef LOG_EXPORT
#undef LOG_OFFER
#undef LOG_ORDER
#undef TRADESCREEN
#undef LOG_SCREEN_LIST
