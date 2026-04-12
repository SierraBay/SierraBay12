#define CONTRACT_STATUS_AVAILABLE "available"
#define CONTRACT_STATUS_ACTIVE "active"
#define CONTRACT_STATUS_COMPLETED "completed"
#define CONTRACT_STATUS_FAILED "failed"

/obj/structure/closet/crate/trade_contract
	name = "sealed contract crate"
	desc = "A sealed freight crate assigned to a trade-network delivery contract."
	icon_state = "securecrate"
	color = "#d6b55a"
	var/contract_id
	var/contract_serial
	var/destination_uid
	var/destination_name
	var/reward = 0
	var/penalty = 0
	var/allow_contract_disposal = FALSE

/obj/structure/closet/crate/trade_contract/proc/GetLinkedContract()
	return SSsupply.GetTradeContract(contract_id)

/obj/structure/closet/crate/trade_contract/proc/IsActiveContractCrate()
	var/datum/trade_contract/contract = GetLinkedContract()
	return istype(contract) && contract.status == CONTRACT_STATUS_ACTIVE

/obj/structure/closet/crate/trade_contract/proc/UpdateContractLabel()
	name = "sealed contract crate"
	if(contract_serial)
		name = "[name] #[contract_serial]"
	if(destination_name)
		name = "[name] -> [destination_name]"
	desc = "A sealed freight crate assigned to trade contract #[contract_id]."
	if(destination_name)
		desc += " Destination: [destination_name]."
	if(reward)
		desc += " Delivery reward: [round(reward)] [GLOB.using_map.local_currency_name_short]."
	if(penalty)
		desc += " Tampering penalty: [round(penalty)] [GLOB.using_map.local_currency_name_short]."
	desc += " Unauthorized opening voids the contract."

/obj/structure/closet/crate/trade_contract/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("Contract #[contract_id], serial #[contract_serial]."))
	if(destination_name)
		to_chat(user, SPAN_NOTICE("Destination beacon: [destination_name]."))
	if(reward)
		to_chat(user, SPAN_NOTICE("Delivery reward: [round(reward)] [GLOB.using_map.local_currency_name_short]."))
	if(penalty)
		to_chat(user, SPAN_WARNING("Tampering penalty: [round(penalty)] [GLOB.using_map.local_currency_name_short]."))

/obj/structure/closet/crate/trade_contract/proc/HandleTamper(mob/user, reason = "Tampering detected.")
	var/datum/trade_contract/contract = GetLinkedContract()
	if(!istype(contract) || contract.status != CONTRACT_STATUS_ACTIVE)
		return FALSE
	var/user_name = user ? user.real_name : null
	visible_message(
		SPAN_DANGER("\The [src] emits a sharp warning tone and locks down."),
		SPAN_DANGER("A warning tone sounds from \the [src].")
	)
	contract.Fail(reason, 2, user_name)
	return TRUE

/obj/structure/closet/crate/trade_contract/can_open()
	if(IsActiveContractCrate())
		return FALSE
	return ..()

/obj/structure/closet/crate/trade_contract/toggle(mob/user as mob)
	if(!opened && IsActiveContractCrate())
		HandleTamper(user, "Cargo seal was broken before delivery.")
		return
	return ..()

/obj/structure/closet/crate/trade_contract/use_tool(obj/item/tool, mob/user, list/click_params)
	if(!opened && IsActiveContractCrate())
		HandleTamper(user, "[user ? user.real_name : "Unknown"] tampered with the cargo seal.")
		return TRUE
	return ..()

/obj/structure/closet/crate/trade_contract/use_weapon(obj/item/weapon, mob/user, list/click_params)
	if(!opened && IsActiveContractCrate())
		HandleTamper(user, "[user ? user.real_name : "Unknown"] attempted to force the crate open.")
		return TRUE
	return ..()

/obj/structure/closet/crate/trade_contract/slice_into_parts(obj/W, mob/user)
	if(IsActiveContractCrate())
		HandleTamper(user, "Contract cargo was dismantled before delivery.")
		return
	return ..()

/obj/structure/closet/crate/trade_contract/Destroy()
	if(!allow_contract_disposal)
		var/datum/trade_contract/contract = GetLinkedContract()
		if(istype(contract) && contract.status == CONTRACT_STATUS_ACTIVE)
			contract.Fail("Contract cargo was destroyed or lost in transit.")
	return ..()

/datum/trade_contract
	var/id
	var/source_uid
	var/destination_uid
	var/contract_serial
	var/source_category
	var/source_good_id
	var/destination_category
	var/destination_good_id
	var/market_reason
	var/snapshot_source_unit_cost = 0
	var/snapshot_destination_sell_price = 0
	var/market_score = 0
	var/reward = 0
	var/base_value = 0
	var/penalty = 0
	var/distance = 0
	var/status = CONTRACT_STATUS_AVAILABLE
	var/list/contents = list()
	var/datum/money_account/linked_account
	var/accepted_by
	var/failure_reason
	var/created_at = 0
	var/accepted_at = 0
	var/resolved_at = 0
	var/obj/structure/closet/crate/trade_contract/assigned_crate

/datum/trade_contract/proc/GetSourceStation()
	return SSsupply.GetStationByUid(source_uid)

/datum/trade_contract/proc/GetDestinationStation()
	return SSsupply.GetStationByUid(destination_uid)

/datum/trade_contract/proc/GetTypeId()
	return "delivery"

/datum/trade_contract/proc/GetTypeLabel()
	return "Delivery Contract"

/datum/trade_contract/proc/GetStatusLabel()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Available"
		if(CONTRACT_STATUS_ACTIVE)
			return "In Transit"
		if(CONTRACT_STATUS_COMPLETED)
			return "Completed"
		if(CONTRACT_STATUS_FAILED)
			return "Failed"
	return "Unknown"

/datum/trade_contract/proc/GetStatusTone()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE, CONTRACT_STATUS_COMPLETED)
			return "good"
		if(CONTRACT_STATUS_ACTIVE)
			return "average"
		if(CONTRACT_STATUS_FAILED)
			return "bad"
	return "average"

/datum/trade_contract/proc/GetContentsInfo()
	var/text = ""
	for(var/list/content as anything in contents)
		if(!islist(content))
			continue
		text += "<li>[content["amount"]]x [content["name"]]</li>"
	return text

/datum/trade_contract/proc/GetSummaryText()
	var/list/parts = list()
	for(var/list/content as anything in contents)
		if(!islist(content))
			continue
		parts += "[content["amount"]]x [content["name"]]"
	return jointext(parts, ", ")

/datum/trade_contract/proc/GetDisplayCargoText()
	return GetSummaryText()

/datum/trade_contract/proc/GetInstructionText()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Accept near [source_station ? source_station.name : "the source station"] to crate the listed cargo."
		if(CONTRACT_STATUS_ACTIVE)
			return "Move the sealed contract crate into sending range and deliver it to [destination_station ? destination_station.name : "the destination station"]."
		if(CONTRACT_STATUS_COMPLETED)
			return "Cargo delivered."
		if(CONTRACT_STATUS_FAILED)
			return failure_reason || "The delivery contract failed."
	return GetStatusLabel()

/datum/trade_contract/proc/GetStatusText()
	if(status == CONTRACT_STATUS_FAILED && failure_reason)
		return failure_reason
	return GetStatusLabel()

/datum/trade_contract/proc/GetActionHint()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Requires receiving range to [source_station ? source_station.name : "the source station"]."
		if(CONTRACT_STATUS_ACTIVE)
			return "Requires the assigned contract crate and sending range to [destination_station ? destination_station.name : "the destination station"]."
	return null

/datum/trade_contract/proc/GetResolvedNote()
	if(status == CONTRACT_STATUS_COMPLETED)
		return "[round(reward)] [GLOB.using_map.local_currency_name_short] paid."
	if(status == CONTRACT_STATUS_FAILED)
		if(penalty)
			return "[failure_reason || "Contract failed."] ([round(penalty)] [GLOB.using_map.local_currency_name_short] penalty)"
		return failure_reason || "Contract failed."
	return null

/datum/trade_contract/proc/GetActiveActionLabel()
	return "Deliver"

/datum/trade_contract/proc/ShouldDisplayAvailable()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	return (source_station in SSsupply.visible_trading_stations) && (destination_station in SSsupply.visible_trading_stations)

/datum/trade_contract/proc/CanStayActive()
	return GetSourceStation() && GetDestinationStation()

/datum/trade_contract/proc/HandleActiveTargetLoss()
	Fail("Route data was lost before delivery.")

/datum/trade_contract/proc/GetAssignedCrate()
	if(istype(assigned_crate) && !QDELETED(assigned_crate))
		return assigned_crate
	assigned_crate = null
	return null

/datum/trade_contract/proc/GetCrate(obj/machinery/trade_beacon/sending/sender_beacon = null)
	var/obj/structure/closet/crate/trade_contract/crate = GetAssignedCrate()
	if(!istype(crate))
		return null
	if(QDELETED(sender_beacon))
		return crate
	if(crate in sender_beacon.GetObjects())
		return crate
	return null

/datum/trade_contract/proc/CanAccept(obj/machinery/trade_beacon/receiving/receiver_beacon)
	if(status != CONTRACT_STATUS_AVAILABLE || QDELETED(receiver_beacon))
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station))
		return FALSE
	if(SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station))
		return FALSE

	for(var/list/content as anything in contents)
		if(!islist(content))
			return FALSE
		if(source_station.GetGoodAmount(content["category"], content["good_id"]) < content["amount"])
			return FALSE
	return TRUE

/datum/trade_contract/proc/GetAcceptBlockReason(obj/machinery/trade_beacon/receiving/receiver_beacon)
	if(!istype(receiver_beacon))
		return "Select a receiving beacon first."
	if(status != CONTRACT_STATUS_AVAILABLE)
		return "This contract is no longer available."
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station))
		return "Contract route data is invalid."
	if(!CanAccept(receiver_beacon))
		var/range_block = source_station ? SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station) : null
		if(range_block)
			return "[source_station.name]: [range_block]"
		return "The source station cannot assemble this cargo right now."
	return null

/datum/trade_contract/proc/Accept(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account)
	if(!CanAccept(receiver_beacon) || !istype(account))
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/obj/structure/closet/crate/trade_contract/crate = receiver_beacon.DropItem(/obj/structure/closet/crate/trade_contract)
	if(!crate)
		return FALSE

	for(var/list/content as anything in contents)
		var/item_path = content["item_path"]
		if(!ispath(item_path, /atom/movable))
			crate.allow_contract_disposal = TRUE
			qdel(crate)
			return FALSE
		for(var/i in 1 to content["amount"])
			new item_path(crate)
		source_station.SetGoodAmount(content["category"], content["good_id"], max(0, source_station.GetGoodAmount(content["category"], content["good_id"]) - content["amount"]))

	crate.contract_id = id
	crate.contract_serial = contract_serial
	crate.destination_uid = destination_uid
	crate.destination_name = destination_station ? destination_station.name : "Unknown"
	crate.reward = reward
	crate.penalty = penalty
	crate.UpdateContractLabel()

	assigned_crate = crate
	status = CONTRACT_STATUS_ACTIVE
	linked_account = account
	accepted_by = account.owner_name
	accepted_at = world.time
	return TRUE

/datum/trade_contract/proc/CanDeliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(status != CONTRACT_STATUS_ACTIVE || QDELETED(sender_beacon) || !istype(linked_account))
		return FALSE

	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(destination_station))
		return FALSE
	if(!istype(GetCrate(sender_beacon), /obj/structure/closet/crate/trade_contract))
		return FALSE
	return !SSsupply.GetTradeRangeBlockReason(sender_beacon, destination_station)

/datum/trade_contract/proc/GetDeliverBlockReason(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!istype(sender_beacon))
		return "Select a sending beacon first."
	if(status != CONTRACT_STATUS_ACTIVE)
		return "This contract is not active."
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!destination_station)
		return "The destination station is unavailable."
	var/obj/structure/closet/crate/trade_contract/crate = GetCrate(sender_beacon)
	if(!istype(crate))
		return "Move the contract crate into the sending beacon range."
	var/range_block = SSsupply.GetTradeRangeBlockReason(sender_beacon, destination_station)
	if(range_block)
		return "[destination_station.name]: [range_block]"
	if(sender_beacon.export_cooldown > world.time)
		return "The sending beacon is on cooldown."
	return null

/datum/trade_contract/proc/Fail(reason = "Contract failed.", penalty_multiplier = 0, failed_by = null)
	if(status == CONTRACT_STATUS_COMPLETED || status == CONTRACT_STATUS_FAILED)
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/penalty_amount = round(base_value * penalty_multiplier)
	var/account_name = accepted_by || (linked_account ? linked_account.owner_name : "Unassigned")
	if(istype(linked_account) && penalty_amount > 0 && linked_account.money > 0)
		penalty_amount = min(penalty_amount, linked_account.money)
		linked_account.withdraw(penalty_amount, "Trade Contract Penalty", "Trade Network")

	var/obj/structure/closet/crate/trade_contract/crate = GetAssignedCrate()
	if(istype(crate) && !QDELETED(crate))
		crate.allow_contract_disposal = TRUE
		qdel(crate)
	assigned_crate = null

	status = CONTRACT_STATUS_FAILED
	failure_reason = reason
	resolved_at = world.time
	SSsupply.CreateLogEntry(
		"Contract",
		account_name,
		"<li>Contract #[id]: [GetSummaryText()]</li><li>Route: [source_station ? source_station.name : "Unknown"] -> [destination_station ? destination_station.name : "Unknown"]</li><li>Status: Failed</li><li>Reason: [reason]</li>[failed_by ? "<li>Triggered by: [failed_by]</li>" : ""]",
		-penalty_amount,
		FALSE,
		null
	)
	return TRUE

/datum/trade_contract/proc/Deliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!CanDeliver(sender_beacon))
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/obj/structure/closet/crate/trade_contract/crate = GetCrate(sender_beacon)
	var/list/content = length(contents) ? contents[1] : null
	var/delivery_amount = islist(content) ? content["amount"] : 0
	if(!istype(crate))
		return FALSE
	if(!sender_beacon.StartExport())
		return FALSE

	crate.allow_contract_disposal = TRUE
	qdel(crate)
	assigned_crate = null
	linked_account.deposit(reward, "Trade Contract Delivery", "Trade Network")
	if(istype(destination_station))
		if(destination_category && destination_good_id && isnum(delivery_amount) && delivery_amount > 0)
			SSsupply.ApplyTradeTransaction(destination_station, destination_category, destination_good_id, delivery_amount, "sell")
		destination_station.AddToWealth(reward, TRUE)
	if(istype(source_station))
		source_station.AddToWealth(round(reward * 0.25), TRUE)

	status = CONTRACT_STATUS_COMPLETED
	resolved_at = world.time
	SSsupply.CreateLogEntry(
		"Contract",
		linked_account.owner_name,
		"<li>Contract #[id]: [GetSummaryText()]</li><li>Route: [source_station ? source_station.name : "Unknown"] -> [destination_station ? destination_station.name : "Unknown"]</li><li>Status: Completed</li>",
		reward,
		TRUE,
		get_turf(sender_beacon)
	)
	return TRUE

/datum/trade_contract/caravan_rendezvous
	var/briefing_text = "Transmit market intelligence package"

/datum/trade_contract/caravan_rendezvous/proc/GetCaravanStation()
	return GetDestinationStation()

/datum/trade_contract/caravan_rendezvous/GetTypeId()
	return "rendezvous"

/datum/trade_contract/caravan_rendezvous/GetTypeLabel()
	return "Market Intel Contract"

/datum/trade_contract/caravan_rendezvous/GetSummaryText()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	if(istype(caravan_station))
		return "Market intelligence handoff to [caravan_station.name]"
	return "Market intelligence handoff"

/datum/trade_contract/caravan_rendezvous/GetDisplayCargoText()
	return briefing_text

/datum/trade_contract/caravan_rendezvous/GetInstructionText()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Accept near [source_station ? source_station.name : "the briefing station"] to download the market-intelligence packet."
		if(CONTRACT_STATUS_ACTIVE)
			return "Move within trade range of [caravan_station ? caravan_station.name : "the target caravan"] and transmit the packet through the sending beacon."
		if(CONTRACT_STATUS_COMPLETED)
			return "Market intelligence transmitted."
		if(CONTRACT_STATUS_FAILED)
			return failure_reason || "The market-intelligence handoff failed."
	return ..()

/datum/trade_contract/caravan_rendezvous/GetStatusText()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Accept near [source_station ? source_station.name : "the briefing station"] to prepare a market-intelligence handoff."
		if(CONTRACT_STATUS_ACTIVE)
			return "Move within trade range of [caravan_station ? caravan_station.name : "the target caravan"] and transmit the market packet through the sending beacon."
		if(CONTRACT_STATUS_COMPLETED)
			return "Market intelligence delivered."
		if(CONTRACT_STATUS_FAILED)
			return failure_reason || "The rendezvous contract failed."
	return ..()

/datum/trade_contract/caravan_rendezvous/GetActiveActionLabel()
	return "Transmit"

/datum/trade_contract/caravan_rendezvous/GetActionHint()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Requires receiving range to [source_station ? source_station.name : "the briefing station"]."
		if(CONTRACT_STATUS_ACTIVE)
			return "Requires sending range to [caravan_station ? caravan_station.name : "the target caravan"]."
	return null

/datum/trade_contract/caravan_rendezvous/GetResolvedNote()
	if(status == CONTRACT_STATUS_COMPLETED)
		return "[round(reward)] [GLOB.using_map.local_currency_name_short] paid for the intelligence handoff."
	return ..()

/datum/trade_contract/caravan_rendezvous/ShouldDisplayAvailable()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	return (source_station in SSsupply.visible_trading_stations) && (caravan_station in SSsupply.visible_trading_stations) && !caravan_station.GetAvailabilityBlockReason()

/datum/trade_contract/caravan_rendezvous/CanStayActive()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	return istype(caravan_station) && (caravan_station in SSsupply.visible_trading_stations) && !caravan_station.GetAvailabilityBlockReason()

/datum/trade_contract/caravan_rendezvous/HandleActiveTargetLoss()
	Fail("Target caravan departed before data handoff.")

/datum/trade_contract/caravan_rendezvous/CanAccept(obj/machinery/trade_beacon/receiving/receiver_beacon)
	if(status != CONTRACT_STATUS_AVAILABLE || QDELETED(receiver_beacon))
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	if(!istype(source_station) || !istype(caravan_station))
		return FALSE
	if(caravan_station.GetAvailabilityBlockReason())
		return FALSE
	return !SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station)

/datum/trade_contract/caravan_rendezvous/GetAcceptBlockReason(obj/machinery/trade_beacon/receiving/receiver_beacon)
	if(!istype(receiver_beacon))
		return "Select a receiving beacon first."
	if(status != CONTRACT_STATUS_AVAILABLE)
		return "This contract is no longer available."
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	if(!istype(source_station) || !istype(caravan_station))
		return "Contract route data is invalid."
	var/caravan_block = caravan_station.GetAvailabilityBlockReason()
	if(caravan_block)
		return "[caravan_station.name]: [caravan_block]"
	var/range_block = SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station)
	if(range_block)
		return "[source_station.name]: [range_block]"
	return null

/datum/trade_contract/caravan_rendezvous/Accept(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account)
	if(!CanAccept(receiver_beacon) || !istype(account))
		return FALSE

	status = CONTRACT_STATUS_ACTIVE
	linked_account = account
	accepted_by = account.owner_name
	accepted_at = world.time
	return TRUE

/datum/trade_contract/caravan_rendezvous/CanDeliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(status != CONTRACT_STATUS_ACTIVE || QDELETED(sender_beacon) || !istype(linked_account))
		return FALSE

	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	if(!istype(caravan_station))
		return FALSE
	if(caravan_station.GetAvailabilityBlockReason())
		return FALSE
	if(sender_beacon.export_cooldown > world.time)
		return FALSE
	return !SSsupply.GetTradeRangeBlockReason(sender_beacon, caravan_station)

/datum/trade_contract/caravan_rendezvous/GetDeliverBlockReason(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!istype(sender_beacon))
		return "Select a sending beacon first."
	if(status != CONTRACT_STATUS_ACTIVE)
		return "This contract is not active."
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	if(!istype(caravan_station))
		return "The target caravan is unavailable."
	var/caravan_block = caravan_station.GetAvailabilityBlockReason()
	if(caravan_block)
		return "[caravan_station.name]: [caravan_block]"
	var/range_block = SSsupply.GetTradeRangeBlockReason(sender_beacon, caravan_station)
	if(range_block)
		return "[caravan_station.name]: [range_block]"
	if(sender_beacon.export_cooldown > world.time)
		return "The sending beacon is on cooldown."
	return null

/datum/trade_contract/caravan_rendezvous/Deliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!CanDeliver(sender_beacon))
		return FALSE
	if(!sender_beacon.StartExport())
		return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	linked_account.deposit(reward, "Trade Contract Delivery", "Trade Network")
	if(istype(caravan_station))
		caravan_station.AddToWealth(reward, TRUE)
	if(istype(source_station))
		source_station.AddToWealth(round(reward * 0.25), TRUE)

	status = CONTRACT_STATUS_COMPLETED
	resolved_at = world.time
	SSsupply.CreateLogEntry(
		"Contract",
		linked_account.owner_name,
		"<li>Contract #[id]: [GetSummaryText()]</li><li>Route: [source_station ? source_station.name : "Unknown"] -> [caravan_station ? caravan_station.name : "Unknown"]</li><li>Status: Completed</li><li>Payload: Market intelligence packet transmitted.</li>",
		reward,
		TRUE,
		get_turf(sender_beacon)
	)
	return TRUE

#undef CONTRACT_STATUS_AVAILABLE
#undef CONTRACT_STATUS_ACTIVE
#undef CONTRACT_STATUS_COMPLETED
#undef CONTRACT_STATUS_FAILED
