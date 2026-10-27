/datum/trade_order_line
	var/item_type
	var/stack_size = 0
	var/name
	var/category
	var/station_id
	var/station_name
	var/quantity
	var/unit_price

/datum/trade_order_line/proc/capture(datum/trade_good/good, count)
	item_type = good.item_type
	stack_size = good.stack_size
	name = good.name
	category = good.category
	station_id = good.station.uid
	station_name = good.station.name
	quantity = count
	unit_price = good.get_price()

/datum/trade_order_line/proc/needs_floor()
	return !ispath(item_type, /obj/item)

/datum/trade_order_line/proc/spawn_item(atom/location)
	return spawn_trade_item(item_type, stack_size, location)

/datum/trade_order_line/proc/to_row()
	return list("name" = name, "category" = category, "station" = station_name, "quantity" = quantity, "stack_size" = stack_size, "unit_price" = unit_price, "subtotal" = unit_price * quantity)

/proc/spawn_trade_item(item_type, stack_size, atom/location)
	ASSERT(ispath(item_type, /atom/movable))
	var/atom/movable/spawned = new item_type(location)
	if(stack_size > 0 && istype(spawned, /obj/item/stack))
		var/obj/item/stack/stack = spawned
		stack.amount = stack_size
		stack.max_amount = max(stack.max_amount, stack_size)
		stack.update_icon()
	return spawned

/proc/copy_trade_rows(list/rows, encode = FALSE)
	var/list/copied = list()
	for(var/list/row as anything in rows)
		var/list/entry = row.Copy()
		entry["category"] ||= ""
		entry["station"] ||= ""
		entry["stack_size"] ||= 0
		if(encode)
			entry["name"] = html_encode(entry["name"])
			entry["category"] = html_encode(entry["category"])
			entry["station"] = html_encode(entry["station"])
		copied += list(entry)
	return copied

/proc/render_trade_rows(list/rows)
	var/list/text = list("<table border='1'><tr><th>Vendor</th><th>Goods</th><th>Quantity</th><th>Unit price</th><th>Subtotal</th></tr>")
	for(var/list/row as anything in rows)
		var/quantity = "[row["quantity"]]"
		if(row["stack_size"])
			quantity += " stacks ([row["stack_size"] * row["quantity"]] units)"
		text += "<tr><td>[html_encode(row["station"])]</td><td>[html_encode(row["name"])]</td><td>[quantity]</td><td>[row["unit_price"]]</td><td>[row["subtotal"]]</td></tr>"
	text += "</table>"
	return jointext(text, "")

/datum/trade_order/proc/get_rows()
	var/list/rows = list()
	for(var/id in snapshots)
		var/datum/trade_order_line/line = snapshots[id]
		rows += list(line.to_row())
	return rows

/datum/trade_order/proc/get_receipt(internal = FALSE)
	var/title = internal ? "Internal trade receipt" : "Trade receipt"
	return "<h3>[title] [html_encode(id)]</h3>Buyer: [html_encode(buyer)]<br>Reason: [html_encode(reason)]<br>Status: [state][render_trade_rows(get_rows())]<br>Goods: [total]; handling: [fee]; total: [total + fee] [GLOB.using_map.local_currency_name]"

/datum/controller/subsystem/trade/proc/get_log_receipt(list/entry, internal = FALSE)
	var/title = internal ? "Internal trade invoice" : "Trade invoice"
	return "<h3>[title] #[entry["id"]]</h3>[entry["time"]]<br>[entry["kind"]]: [entry["title"]]<br>Account: [entry["account"]][render_trade_rows(entry["contents"])]<br>Cargo commission/handling: [entry["fee"]]<br>Total: [entry["amount"]] [GLOB.using_map.local_currency_name]"
