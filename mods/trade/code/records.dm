/datum/trade_order_line
	var/item_type
	var/supply_pack_type
	var/req_access
	var/stack_size = 0
	var/name
	var/category
	var/station_id
	var/station_name
	var/quantity
	var/unit_price

/datum/trade_order_line/proc/capture(datum/trade_good/good, count)
	item_type = good.item_type
	supply_pack_type = good.supply_pack_type
	if(islist(good.req_access))
		var/list/acc = good.req_access
		req_access = acc.Copy()
	else
		req_access = good.req_access
	stack_size = good.stack_size
	name = good.name
	category = good.category
	station_id = good.station.uid
	station_name = good.station.name
	quantity = count
	unit_price = good.get_price()

/datum/trade_order_line/proc/needs_floor()
	return !!supply_pack_type || !ispath(item_type, /obj/item)

/datum/trade_order_line/proc/spawn_item(atom/location, buyer_name = null)
	return spawn_trade_good(supply_pack_type, item_type, stack_size, location, req_access, buyer_name)

/datum/trade_order_line/proc/to_row()
	return list("name" = name, "category" = category, "station" = station_name, "quantity" = quantity, "stack_size" = stack_size, "unit_price" = unit_price, "subtotal" = unit_price * quantity)

/proc/spawn_trade_good(supply_pack_type, item_type, stack_size, atom/location, req_access = null, buyer_name = null)
	if(supply_pack_type)
		var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(supply_pack_type)
		ASSERT(istype(pack))
		var/ctype = pack.containertype || /obj/structure/closet/crate
		var/atom/movable/container = new ctype(location)
		container.trade_export_tags |= TRADE_TAG_NONEXPORTABLE
		var/base_name = pack.containername || initial(container.name)
		if(buyer_name)
			container.SetName("[base_name] ([buyer_name])")
		else if(pack.containername)
			container.SetName(pack.containername)
		var/effective_access = !isnull(req_access) ? req_access : pack.access
		if(effective_access && istype(container, /obj))
			var/obj/obj_container = container
			if(islist(effective_access))
				var/list/acc_list = effective_access
				obj_container.req_access = acc_list.Copy()
			else
				obj_container.req_access = list(effective_access)
		pack.spawn_contents(container)
		return container
	return spawn_trade_item(item_type, stack_size, location)

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
	return "<h3>[title] #[entry["id"]]</h3>[entry["time"]]<br>[entry["kind"]]: [html_encode(entry["title"])]<br>Account: [html_encode(entry["account"])][render_trade_rows(entry["contents"])]<br>Cargo commission/handling: [entry["fee"]]<br>Total: [entry["amount"]] [GLOB.using_map.local_currency_name]"
