#define MAX_SUPPLY_LOG_ENTRIES 50

/datum/controller/subsystem/supply/proc/CreateLogEntry(type, ordering_account, contents, total_paid, create_invoice = FALSE, invoice_location = null, faction_name = null, station_name = null)
	var/log_id
	var/list/log_entry = list(
		"id" = null,
		"ordering_acct" = ordering_account,
		"contents" = contents,
		"total_paid" = total_paid,
		"time" = time2text(world.time, "hh:mm"),
		"faction" = faction_name,
		"station" = station_name
	)

	switch(type)
		if("Shipping")
			log_id = "[++shipping_invoice_number]-S"
			log_entry["id"] = log_id
			shipping_log += list(log_entry)
			if(length(shipping_log) > MAX_SUPPLY_LOG_ENTRIES)
				shipping_log.Cut(1, 2)
		if("Export")
			log_id = "[++export_invoice_number]-E"
			log_entry["id"] = log_id
			export_log += list(log_entry)
			if(length(export_log) > MAX_SUPPLY_LOG_ENTRIES)
				export_log.Cut(1, 2)
		if("Order")
			log_id = "[++order_number]-O"
			log_entry["id"] = log_id
			order_log += list(log_entry)
			if(length(order_log) > MAX_SUPPLY_LOG_ENTRIES)
				order_log.Cut(1, 2)
		if("Contract")
			log_id = "[++contract_number]-C"
			log_entry["id"] = log_id
			contract_log += list(log_entry)
			if(length(contract_log) > MAX_SUPPLY_LOG_ENTRIES)
				contract_log.Cut(1, 2)
		else
			return

	if(create_invoice && invoice_location && log_id)
		PrintInvoice(type, log_id, ordering_account, contents, total_paid, FALSE, invoice_location, faction_name, station_name)
		if(type == "Shipping")
			PrintInvoice(type, log_id, ordering_account, contents, total_paid, TRUE, invoice_location, faction_name, station_name)

/datum/controller/subsystem/supply/proc/PrintInvoice(type, log_id, ordering_account, contents, total_paid, is_internal = FALSE, location, faction_name = null, station_name = null)
	if(!location)
		return
	var/title = "[lowertext(type)] invoice - #[log_id]"
	if(is_internal)
		title += " (internal)"
	var/text = ""
	text += "<h3>[type] Invoice - #[log_id]</h3><hr><font size='2'>"
	if(is_internal)
		text += "FOR INTERNAL USE ONLY<br><br>"
	text += "Recipient: [ordering_account]<br>"
	if(faction_name)
		text += "Faction: [faction_name]<br>"
	if(station_name)
		text += "Trading Partner: [station_name]<br>"
	text += "Contents:<ul>[contents]</ul>"
	text += "Total Credits Paid: [total_paid]<br>"
	text += "</font>"
	new /obj/item/paper(location, text, title)

/datum/controller/subsystem/supply/proc/GetLogDataById(log_id)
	var/list/target_log
	var/list/id_data = splittext(log_id, "-")
	if(length(id_data) < 2)
		return null
	switch(uppertext(id_data[2]))
		if("S")
			target_log = shipping_log
		if("E")
			target_log = export_log
		if("O")
			target_log = order_log
		if("C")
			target_log = contract_log
		else
			return null

	for(var/list/entry in target_log)
		if(entry["id"] == log_id)
			return entry
	return null


#undef MAX_SUPPLY_LOG_ENTRIES
