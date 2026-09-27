/obj/structure/closet/crate/trade_contract
	name = "sealed contract crate"
	desc = "A sealed freight crate assigned to a trade-network delivery contract."
	closet_appearance = /singleton/closet_appearance/crate/secure
	var/contract_id
	var/contract_serial
	var/destination_uid
	var/destination_name
	var/reward = 0
	var/penalty = 0
	var/deposit = 0
	var/allow_contract_disposal = FALSE
	var/datum/trade_contract/linked_contract

/obj/structure/closet/crate/trade_contract/Initialize(mapload)
	. = ..()
	color = "#d6b55a"

/obj/structure/closet/crate/trade_contract/proc/GetCurrencyName()
	return GLOB.using_map?.local_currency_name_short || "credits"

/obj/structure/closet/crate/trade_contract/proc/GetLinkedContract()
	if(istype(linked_contract) && !QDELETED(linked_contract))
		return linked_contract
	if(contract_id)
		linked_contract = SSsupply.GetTradeContract(contract_id)
		return linked_contract
	return null

/obj/structure/closet/crate/trade_contract/proc/IsActiveContractCrate()
	var/datum/trade_contract/contract = GetLinkedContract()
	return istype(contract) && contract.status == CONTRACT_STATUS_ACTIVE && contract.assigned_crate == src

/obj/structure/closet/crate/trade_contract/proc/UpdateContractLabel()
	name = "sealed contract crate"
	if(contract_serial)
		name = "[name] #[contract_serial]"
	if(destination_name)
		name = "[name] -> [destination_name]"
	desc = "A sealed freight crate assigned to trade contract #[contract_id]."
	if(destination_name)
		desc += " Destination: [destination_name]."
	var/currency = GetCurrencyName()
	if(reward)
		desc += " Delivery reward: [round(reward)] [currency]."
	if(deposit)
		desc += " Security deposit: [round(deposit)] [currency]."
	if(penalty)
		desc += " Tampering penalty: [round(penalty)] [currency]."
	desc += " Unauthorized opening voids the contract."

/obj/structure/closet/crate/trade_contract/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("Contract #[contract_id], serial #[contract_serial]."))
	if(destination_name)
		to_chat(user, SPAN_NOTICE("Destination beacon: [destination_name]."))
	var/currency = GetCurrencyName()
	if(reward)
		to_chat(user, SPAN_NOTICE("Delivery reward: [round(reward)] [currency]."))
	if(deposit)
		to_chat(user, SPAN_NOTICE("Security deposit: [round(deposit)] [currency] (refunded upon successful delivery)."))
	if(penalty)
		to_chat(user, SPAN_WARNING("Tampering penalty: [round(penalty)] [currency]."))

/obj/structure/closet/crate/trade_contract/proc/IsBreachTool(obj/item/tool)
	return isCrowbar(tool) || isWirecutter(tool) || isWelder(tool) || isScrewdriver(tool) || istype(tool, /obj/item/gun/energy/plasmacutter)

/obj/structure/closet/crate/trade_contract/proc/ShouldBreachSeal(mob/user, force_open = FALSE)
	if(force_open || !user || !user.client)
		return TRUE
	return user.a_intent == I_HURT

/obj/structure/closet/crate/trade_contract/proc/HandleTamper(mob/user, reason = "Tampering detected.")
	var/datum/trade_contract/contract = GetLinkedContract()
	if(!istype(contract) || contract.status != CONTRACT_STATUS_ACTIVE || contract.assigned_crate != src)
		return FALSE
	var/user_name = user ? (user.real_name || user.name) : null
	visible_message(
		SPAN_DANGER("\The [src] security seal is breached! Alarm sirens blare and emergency locks disengage!"),
		SPAN_DANGER("A sharp alarm sounds from \the [src] as its security seal is breached!")
	)
	var/datum/effect/spark_spread/sparks = new /datum/effect/spark_spread
	sparks.set_up(3, 1, src)
	sparks.start()
	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 1)

	contract.assigned_crate = null
	linked_contract = null
	contract_id = null
	name = "breached contract crate"
	desc = "A freight crate whose trade-network security seal was forcefully breached."

	locked = FALSE
	open()

	contract.Fail(reason, null, user_name)
	return TRUE

/obj/structure/closet/crate/trade_contract/proc/AttemptTamper(mob/user, reason, force_open = FALSE)
	if(opened || !IsActiveContractCrate())
		return FALSE
	if(!ShouldBreachSeal(user, force_open))
		var/currency = GetCurrencyName()
		to_chat(user, SPAN_WARNING("\The [src] is sealed for trade contract #[contract_id] (Tampering penalty: [round(penalty)] [currency]). Switch to Harm intent or pry with a tool to force it open."))
		return TRUE
	if(user && (!user.Adjacent(src) || !user.client))
		return TRUE
	HandleTamper(user, reason)
	return TRUE

/obj/structure/closet/crate/trade_contract/can_open()
	if(IsActiveContractCrate())
		return FALSE
	return ..()

/obj/structure/closet/crate/trade_contract/toggle(mob/user)
	if(!opened && IsActiveContractCrate())
		AttemptTamper(user, "Cargo seal was forced open before delivery.")
		return
	return ..()

/obj/structure/closet/crate/trade_contract/use_tool(obj/item/tool, mob/user, list/click_params)
	if(!opened && IsActiveContractCrate())
		var/is_breach_tool = IsBreachTool(tool)
		if(user && user.a_intent == I_HELP && !is_breach_tool)
			to_chat(user, SPAN_NOTICE("\The [src] is sealed for trade contract #[contract_id]. Use a prying or cutting tool to breach the seal."))
			return TRUE
		var/who = user ? (user.real_name || user.name) : "Unknown"
		AttemptTamper(user, "[who] tampered with the cargo seal.", is_breach_tool)
		return TRUE
	return ..()

/obj/structure/closet/crate/trade_contract/use_weapon(obj/item/weapon, mob/user, list/click_params)
	if(!opened && IsActiveContractCrate())
		var/who = user ? (user.real_name || user.name) : "Unknown"
		AttemptTamper(user, "[who] forced open the security seal.")
		return TRUE
	return ..()

/obj/structure/closet/crate/trade_contract/slice_into_parts(obj/W, mob/user)
	if(IsActiveContractCrate())
		AttemptTamper(user, "Contract cargo was dismantled before delivery.")
		return
	return ..()

/obj/structure/closet/crate/trade_contract/Destroy()
	var/datum/trade_contract/contract = GetLinkedContract()
	if(istype(contract) && contract.assigned_crate == src)
		if(!allow_contract_disposal && contract.status == CONTRACT_STATUS_ACTIVE)
			contract.Fail("Contract cargo was destroyed or lost in transit.", null)
		contract.assigned_crate = null
	linked_contract = null
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
	var/deposit = 0
	var/deposit_paid = 0
	var/pending_refund = 0
	var/distance = 0
	var/status = CONTRACT_STATUS_AVAILABLE
	var/list/contents = list()
	var/cargo_summary
	var/datum/money_account/linked_account
	var/accepted_by
	var/failure_reason
	var/actual_penalty = 0
	var/created_at = 0
	var/accepted_at = 0
	var/resolved_at = 0
	var/obj/structure/closet/crate/trade_contract/assigned_crate

/datum/trade_contract/Destroy()
	SSsupply?.trade_contracts -= src
	linked_account = null
	CleanupPayload()
	if(islist(contents))
		contents.Cut()
		contents = null
	return ..()

/datum/trade_contract/proc/GetCurrencyName()
	return GLOB.using_map?.local_currency_name_short || "credits"

/datum/trade_contract/proc/CleanupPayload()
	if(istype(assigned_crate))
		if(!QDELETED(assigned_crate))
			assigned_crate.allow_contract_disposal = TRUE
			qdel(assigned_crate)
		else if(assigned_crate.linked_contract == src)
			assigned_crate.linked_contract = null
	assigned_crate = null

/datum/trade_contract/proc/GetSourceStation()
	return SSsupply.GetStationByUid(source_uid)

/datum/trade_contract/proc/GetDestinationStation()
	return SSsupply.GetStationByUid(destination_uid)

/datum/trade_contract/proc/GetTypeId()
	return "delivery"

/datum/trade_contract/proc/GetTypeLabel()
	return "Delivery Contract"

/datum/trade_contract/proc/GetActiveActionLabel()
	return "Deliver"

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
	var/list/entries = list()
	for(var/list/content as anything in contents)
		if(islist(content))
			entries += "<li>[content["amount"]]x [content["name"]]</li>"
	return jointext(entries, "")

/datum/trade_contract/proc/GetSummaryText()
	if(cargo_summary)
		return cargo_summary
	var/list/parts = list()
	for(var/list/content as anything in contents)
		if(islist(content))
			parts += "[content["amount"]]x [content["name"]]"
	cargo_summary = jointext(parts, ", ")
	return cargo_summary

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
	var/currency = GetCurrencyName()
	if(status == CONTRACT_STATUS_COMPLETED)
		var/note = "[round(reward)] [currency] paid."
		if(deposit > 0)
			note += " [round(deposit)] [currency] deposit returned."
		return note
	if(status == CONTRACT_STATUS_FAILED)
		var/reason = failure_reason || "Contract failed."
		return (actual_penalty > 0) ? "[reason] ([round(actual_penalty)] [currency] penalty)" : reason
	return null

/datum/trade_contract/proc/GetAcceptFailureMessage()
	return "Contract acceptance failed. Check source stock and the receiving area."

/datum/trade_contract/proc/GetDeliverFailureMessage()
	return "Contract delivery failed. The crate may be missing or the beacon may be on cooldown."

/datum/trade_contract/proc/ShouldDisplayAvailable()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station))
		return FALSE
	if(!(source_station in SSsupply.visible_trading_stations) || !(destination_station in SSsupply.visible_trading_stations))
		return FALSE
	if(source_station.GetAvailabilityBlockReason() || destination_station.GetAvailabilityBlockReason())
		return FALSE
	return TRUE

/datum/trade_contract/proc/CanStayActive()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station))
		return FALSE
	if(!(destination_station in SSsupply.visible_trading_stations) || destination_station.GetAvailabilityBlockReason())
		return FALSE
	return TRUE

/datum/trade_contract/proc/HandleActiveTargetLoss()
	Fail("Route data was lost before delivery.", 0)

/datum/trade_contract/proc/GetAssignedCrate()
	if(istype(assigned_crate) && !QDELETED(assigned_crate))
		return assigned_crate
	return null

/datum/trade_contract/proc/GetCrate(obj/machinery/trade_beacon/sending/sender_beacon = null)
	var/obj/structure/closet/crate/trade_contract/crate = GetAssignedCrate()
	if(!istype(crate))
		return null
	if(!sender_beacon)
		return crate
	if(QDELETED(sender_beacon))
		return null
	if(crate in sender_beacon.GetObjects())
		return crate
	return null

/datum/trade_contract/proc/CanAccept(obj/machinery/trade_beacon/receiving/receiver_beacon = null, datum/money_account/account = null, buyer_faction = null)
	if(status != CONTRACT_STATUS_AVAILABLE)
		return FALSE
	if(deposit > 0 && istype(account) && account.money < deposit)
		return FALSE
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station) || GetRouteAcceptBlockReason(source_station, destination_station, buyer_faction))
		return FALSE
	if(receiver_beacon)
		if(QDELETED(receiver_beacon) || !receiver_beacon.anchored || receiver_beacon.inoperable())
			return FALSE
		if(SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station))
			return FALSE
	return CanFulfillCargoRequirements(source_station)

/datum/trade_contract/proc/IsValidCargoContent(list/content)
	if(!islist(content))
		return FALSE
	var/item_path = content["item_path"]
	var/amount = content["amount"]
	return ispath(item_path, /atom/movable) && isnum(amount) && amount > 0 && amount == round(amount)

/datum/trade_contract/proc/CanFulfillCargoRequirements(datum/trading_station/source_station)
	if(!length(contents))
		return FALSE
	for(var/list/content as anything in contents)
		if(!IsValidCargoContent(content))
			return FALSE
		if(source_station.GetGoodAmount(content["category"], content["good_id"]) < content["amount"])
			return FALSE
	return TRUE

/datum/trade_contract/proc/GetAcceptBlockReason(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account = null, buyer_faction = null)
	if(!istype(receiver_beacon))
		return "Select a receiving beacon first."
	if(status != CONTRACT_STATUS_AVAILABLE)
		return "This contract is no longer available."
	if(deposit > 0 && istype(account) && account.money < deposit)
		return "Insufficient funds for security deposit ([round(deposit)] [GetCurrencyName()] required)."
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(source_station) || !istype(destination_station))
		return "Contract route data is invalid."
	var/route_block = GetRouteAcceptBlockReason(source_station, destination_station, buyer_faction)
	if(route_block)
		return route_block
	if(QDELETED(receiver_beacon) || !receiver_beacon.anchored || receiver_beacon.inoperable())
		return "The receiving beacon is unavailable."
	var/range_block = SSsupply.GetTradeRangeBlockReason(receiver_beacon, source_station)
	if(range_block)
		return "[source_station.name]: [range_block]"
	return GetCargoAcceptBlockReason(source_station)

/datum/trade_contract/proc/GetRouteAcceptBlockReason(datum/trading_station/source_station, datum/trading_station/destination_station, buyer_faction = null)
	if(buyer_faction)
		if(SSsupply.GetStationTradeRelationMultiplier(source_station, buyer_faction) <= 0)
			return "[source_station.name] refuses trade relations with your faction."
		if(SSsupply.GetStationTradeRelationMultiplier(destination_station, buyer_faction) <= 0)
			return "[destination_station.name] refuses trade relations with your faction."
	if(!(source_station in SSsupply.visible_trading_stations))
		return "[source_station.name] is out of communication range."
	if(!(destination_station in SSsupply.visible_trading_stations))
		return "[destination_station.name] is out of communication range."
	var/source_block = source_station.GetAvailabilityBlockReason()
	if(source_block)
		return "[source_station.name]: [source_block]"
	var/dest_block = destination_station.GetAvailabilityBlockReason()
	if(dest_block)
		return "[destination_station.name]: [dest_block]"
	return null

/datum/trade_contract/proc/GetCargoAcceptBlockReason(datum/trading_station/source_station)
	if(!CanFulfillCargoRequirements(source_station))
		return "The source station cannot assemble this cargo right now."
	return null

/datum/trade_contract/proc/Accept(obj/machinery/trade_beacon/receiving/receiver_beacon, datum/money_account/account, buyer_faction = null)
	if(!istype(receiver_beacon) || !CanAccept(receiver_beacon, account, buyer_faction) || !istype(account))
		return FALSE
	if(deposit > 0)
		if(account.money < deposit || !account.withdraw(deposit, "Trade Contract Deposit", "Trade Network"))
			return FALSE
		deposit_paid = deposit
	if(!ExecuteAccept(receiver_beacon))
		RefundFailedAcceptance(account)
		return FALSE
	status = CONTRACT_STATUS_ACTIVE
	linked_account = account
	accepted_by = account.owner_name
	accepted_at = world.time
	cargo_summary = GetSummaryText()
	return TRUE

/datum/trade_contract/proc/RefundFailedAcceptance(datum/money_account/account)
	if(deposit_paid <= 0)
		return
	if(account.deposit(deposit_paid, "Trade Contract Deposit Refund", "Trade Network"))
		deposit_paid = 0
		return
	linked_account = account
	Fail("Unable to prepare the contract cargo. The security deposit will be refunded when the linked account is available.", 0, account.owner_name)

/datum/trade_contract/proc/ExecuteAccept(obj/machinery/trade_beacon/receiving/receiver_beacon)
	for(var/list/content as anything in contents)
		if(!IsValidCargoContent(content))
			return FALSE

	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/obj/structure/closet/crate/trade_contract/crate = receiver_beacon.DropItem(/obj/structure/closet/crate/trade_contract)
	if(!crate)
		return FALSE

	PopulateContractCrate(crate, source_station)
	SetupCrateMetadata(crate, destination_station)
	assigned_crate = crate
	return TRUE

/datum/trade_contract/proc/PopulateContractCrate(obj/structure/closet/crate/trade_contract/crate, datum/trading_station/source_station)
	for(var/list/content as anything in contents)
		var/item_path = content["item_path"]
		for(var/i in 1 to content["amount"])
			new item_path(crate)
		var/remaining = source_station.GetGoodAmount(content["category"], content["good_id"]) - content["amount"]
		source_station.SetGoodAmount(content["category"], content["good_id"], max(0, remaining))

/datum/trade_contract/proc/SetupCrateMetadata(obj/structure/closet/crate/trade_contract/crate, datum/trading_station/destination_station)
	crate.contract_id = id
	crate.linked_contract = src
	crate.contract_serial = contract_serial
	crate.destination_uid = destination_uid
	crate.destination_name = destination_station ? destination_station.name : "Unknown"
	crate.reward = reward
	crate.deposit = deposit
	crate.penalty = penalty
	crate.UpdateContractLabel()

/datum/trade_contract/proc/CanDeliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(status != CONTRACT_STATUS_ACTIVE || QDELETED(sender_beacon) || !istype(linked_account))
		return FALSE
	if(linked_account.suspended)
		return FALSE
	if(!sender_beacon.CanExport())
		return FALSE
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(destination_station) || destination_station.GetAvailabilityBlockReason())
		return FALSE
	if(SSsupply.GetTradeRangeBlockReason(sender_beacon, destination_station))
		return FALSE
	return CanFulfillDeliveryPayload(sender_beacon)

/datum/trade_contract/proc/CanFulfillDeliveryPayload(obj/machinery/trade_beacon/sending/sender_beacon)
	var/obj/structure/closet/crate/trade_contract/crate = GetCrate(sender_beacon)
	return HasIntactCargo(crate)

/datum/trade_contract/proc/HasIntactCargo(obj/structure/closet/crate/trade_contract/crate)
	if(!istype(crate) || crate.opened || !length(contents))
		return FALSE
	var/list/remaining_by_type = list()
	for(var/list/content as anything in contents)
		if(!IsValidCargoContent(content))
			return FALSE
		var/item_path = content["item_path"]
		var/amount = content["amount"]
		remaining_by_type[item_path] = (remaining_by_type[item_path] || 0) + amount
	for(var/atom/movable/item as anything in crate.contents)
		if(!QDELETED(item) && remaining_by_type[item.type] > 0)
			remaining_by_type[item.type]--
	for(var/item_path in remaining_by_type)
		if(remaining_by_type[item_path] > 0)
			return FALSE
	return TRUE

/datum/trade_contract/proc/GetDeliverBlockReason(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!istype(sender_beacon))
		return "Select a sending beacon first."
	if(status != CONTRACT_STATUS_ACTIVE)
		return "This contract is not active."
	if(!istype(linked_account))
		return "Linked payment account is invalid or missing."
	if(linked_account.suspended)
		return "Linked payment account is suspended."
	if(QDELETED(sender_beacon) || !sender_beacon.anchored || sender_beacon.inoperable())
		return "The sending beacon is unavailable."
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(destination_station))
		return "The destination station is unavailable."
	var/dest_block = destination_station.GetAvailabilityBlockReason()
	if(dest_block)
		return "[destination_station.name]: [dest_block]"
	var/payload_block = GetPayloadDeliverBlockReason(sender_beacon)
	if(payload_block)
		return payload_block
	var/range_block = SSsupply.GetTradeRangeBlockReason(sender_beacon, destination_station)
	if(range_block)
		return "[destination_station.name]: [range_block]"
	if(sender_beacon.export_cooldown > world.time)
		return "The sending beacon is on cooldown."
	return null

/datum/trade_contract/proc/GetPayloadDeliverBlockReason(obj/machinery/trade_beacon/sending/sender_beacon)
	var/obj/structure/closet/crate/trade_contract/crate = GetCrate(sender_beacon)
	if(!istype(crate))
		return "Move the contract crate into the sending beacon range."
	if(!HasIntactCargo(crate))
		return "The contract crate is missing required cargo."
	return null

/datum/trade_contract/proc/Fail(reason = "Contract failed.", penalty_multiplier = null, failed_by = null)
	if(status == CONTRACT_STATUS_COMPLETED || status == CONTRACT_STATUS_FAILED)
		return FALSE

	DeductPenalty(penalty_multiplier)
	CleanupPayload()
	cargo_summary = GetSummaryText()
	status = CONTRACT_STATUS_FAILED
	failure_reason = reason
	resolved_at = world.time
	LogContractFailure(reason, failed_by)
	if(!HasPendingRefund())
		linked_account = null
	SSsupply?.TrimResolvedContracts()
	return TRUE

/datum/trade_contract/proc/HasPendingRefund()
	return pending_refund > 0

/datum/trade_contract/proc/TrySettlePendingRefund()
	if(!HasPendingRefund())
		return TRUE
	if(!istype(linked_account) || linked_account.suspended)
		return FALSE
	if(!linked_account.deposit(pending_refund, "Trade Contract Deposit Refund", "Trade Network"))
		return FALSE
	deposit_paid = max(0, deposit_paid - pending_refund)
	pending_refund = 0
	if(status == CONTRACT_STATUS_FAILED)
		linked_account = null
	return TRUE

/datum/trade_contract/proc/DeductPenalty(penalty_multiplier)
	if(isnum(penalty_multiplier) && penalty_multiplier == 0)
		pending_refund = 0
		if(istype(linked_account) && deposit_paid > 0)
			if(linked_account.deposit(deposit_paid, "Trade Contract Deposit Refund", "Trade Network"))
				deposit_paid = 0
			else
				pending_refund = deposit_paid
		actual_penalty = 0
		return

	var/total_penalty = isnum(penalty_multiplier) ? round(base_value * penalty_multiplier) : penalty
	var/remaining_penalty = max(0, total_penalty - deposit_paid)
	var/deduction = 0
	if(istype(linked_account) && remaining_penalty > 0 && linked_account.money > 0)
		var/attempted_deduction = min(remaining_penalty, linked_account.money)
		if(attempted_deduction > 0 && linked_account.withdraw(attempted_deduction, "Trade Contract Penalty", "Trade Network"))
			deduction = attempted_deduction
	actual_penalty = deposit_paid + deduction

/datum/trade_contract/proc/LogContractFailure(reason, failed_by)
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/account_name = accepted_by || (linked_account ? linked_account.owner_name : "Unassigned")
	var/list/log_lines = list(
		"<li>Contract #[id]: [GetSummaryText()]</li>",
		"<li>Route: [source_station ? source_station.name : "Unknown"] -> [destination_station ? destination_station.name : "Unknown"]</li>",
		"<li>Status: Failed</li>",
		"<li>Reason: [reason]</li>"
	)
	if(failed_by)
		log_lines += "<li>Triggered by: [failed_by]</li>"
	SSsupply.CreateLogEntry("Contract", account_name, jointext(log_lines, ""), -actual_penalty, FALSE, null)

/datum/trade_contract/proc/Deliver(obj/machinery/trade_beacon/sending/sender_beacon)
	if(!CanDeliver(sender_beacon) || !sender_beacon.StartExport())
		return FALSE
	if(!PayoutReward())
		return FALSE

	cargo_summary = GetSummaryText()
	ExecuteDeliver(sender_beacon)
	DistributeStationWealth()

	status = CONTRACT_STATUS_COMPLETED
	resolved_at = world.time
	LogContractCompletion(sender_beacon)
	linked_account = null
	SSsupply?.TrimResolvedContracts()
	return TRUE

/datum/trade_contract/proc/PayoutReward()
	if(!istype(linked_account) || linked_account.suspended)
		return FALSE
	var/total_payout = reward + deposit_paid
	if(!linked_account.deposit(total_payout, "Trade Contract Delivery", "Trade Network"))
		return FALSE
	deposit_paid = 0
	return TRUE

/datum/trade_contract/proc/DistributeStationWealth()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(istype(destination_station))
		destination_station.SubtractFromWealth(reward)
	if(istype(source_station))
		source_station.AddToWealth(base_value, TRUE)

/datum/trade_contract/proc/ExecuteDeliver(obj/machinery/trade_beacon/sending/sender_beacon)
	CleanupPayload()
	var/datum/trading_station/destination_station = GetDestinationStation()
	if(!istype(destination_station))
		return
	for(var/list/content as anything in contents)
		if(islist(content))
			ApplyDeliveredContent(destination_station, content)

/datum/trade_contract/proc/ApplyDeliveredContent(datum/trading_station/destination_station, list/content)
	var/target_category = content["destination_category"] || destination_category
	var/target_good = content["destination_good_id"] || destination_good_id
	if((!target_category || !target_good) && content["item_path"])
		var/list/destination_match = SSsupply.FindStationCommodityByPath(destination_station, content["item_path"])
		if(islist(destination_match))
			target_category ||= destination_match["category"]
			target_good ||= destination_match["good_id"]
	var/delivery_amount = content["amount"]
	if(target_category && target_good && isnum(delivery_amount) && delivery_amount > 0)
		SSsupply.ApplyTradeTransaction(destination_station, target_category, target_good, delivery_amount, "sell")

/datum/trade_contract/proc/LogContractCompletion(obj/machinery/trade_beacon/sending/sender_beacon)
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/destination_station = GetDestinationStation()
	var/list/log_lines = list(
		"<li>Contract #[id]: [GetSummaryText()]</li>",
		"<li>Route: [source_station ? source_station.name : "Unknown"] -> [destination_station ? destination_station.name : "Unknown"]</li>",
		"<li>Status: Completed</li>",
		GetCompletionLogPayload()
	)
	SSsupply.CreateLogEntry("Contract", linked_account.owner_name, jointext(log_lines, ""), reward, TRUE, get_turf(sender_beacon))

/datum/trade_contract/proc/GetCompletionLogPayload()
	return ""

/obj/item/disk/trade_data
	name = "encrypted intelligence disk"
	desc = "An encrypted data storage medium containing sensitive market intelligence."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk3"
	w_class = ITEM_SIZE_TINY
	var/contract_id
	var/contract_serial
	var/destination_uid
	var/destination_name
	var/allow_contract_disposal = FALSE
	var/datum/trade_contract/linked_contract

/obj/item/disk/trade_data/proc/GetLinkedContract()
	if(istype(linked_contract) && !QDELETED(linked_contract))
		return linked_contract
	if(contract_id)
		linked_contract = SSsupply.GetTradeContract(contract_id)
		return linked_contract
	return null

/obj/item/disk/trade_data/proc/UpdateIntelLabel()
	name = "encrypted intelligence disk"
	if(contract_serial)
		name = "[name] #[contract_serial]"
	if(destination_name)
		name = "[name] -> [destination_name]"
	desc = "An encrypted data storage medium assigned to rendezvous contract #[contract_id]."
	if(destination_name)
		desc += " Destination: [destination_name]."

/obj/item/disk/trade_data/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("Contract #[contract_id], serial #[contract_serial]."))
	if(destination_name)
		to_chat(user, SPAN_NOTICE("Caravan destination: [destination_name]."))

/obj/item/disk/trade_data/Destroy()
	var/datum/trade_contract/contract = GetLinkedContract()
	var/datum/trade_contract/caravan_rendezvous/caravan_contract = contract
	if(istype(caravan_contract) && caravan_contract.assigned_disk == src)
		if(!allow_contract_disposal && contract.status == CONTRACT_STATUS_ACTIVE)
			contract.Fail("Market intelligence disk was destroyed before transmission.", null)
		caravan_contract.assigned_disk = null
	linked_contract = null
	return ..()

/datum/trade_contract/caravan_rendezvous
	var/briefing_text = "Market intelligence data packet (encrypted disk required)"
	var/trade_window_end = 0
	var/obj/item/disk/trade_data/assigned_disk

/datum/trade_contract/caravan_rendezvous/proc/GetCaravanStation()
	return GetDestinationStation()

/datum/trade_contract/caravan_rendezvous/GetTypeId()
	return "rendezvous"

/datum/trade_contract/caravan_rendezvous/GetTypeLabel()
	return "Rendezvous Contract"

/datum/trade_contract/caravan_rendezvous/GetActiveActionLabel()
	return "Transmit"

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
			return "Accept near [source_station ? source_station.name : "the briefing station"] to receive the encrypted intelligence disk."
		if(CONTRACT_STATUS_ACTIVE)
			return "Move within trade range of [caravan_station ? caravan_station.name : "the target caravan"] and transmit the encrypted intelligence disk via the sending beacon."
		if(CONTRACT_STATUS_COMPLETED)
			return "Market intelligence transmitted."
		if(CONTRACT_STATUS_FAILED)
			return failure_reason || "The market-intelligence handoff failed."
	return ..()

/datum/trade_contract/caravan_rendezvous/GetActionHint()
	var/datum/trading_station/source_station = GetSourceStation()
	var/datum/trading_station/caravan/caravan_station = GetCaravanStation()
	switch(status)
		if(CONTRACT_STATUS_AVAILABLE)
			return "Requires receiving range to [source_station ? source_station.name : "the briefing station"]."
		if(CONTRACT_STATUS_ACTIVE)
			return "Requires the encrypted intelligence disk and sending range to [caravan_station ? caravan_station.name : "the target caravan"]."
	return null

/datum/trade_contract/caravan_rendezvous/GetResolvedNote()
	if(status == CONTRACT_STATUS_COMPLETED)
		return "[round(reward)] [GetCurrencyName()] paid for the intelligence handoff."
	return ..()

/datum/trade_contract/caravan_rendezvous/GetAcceptFailureMessage()
	return "Market-intelligence briefing failed. Check source access and caravan availability."

/datum/trade_contract/caravan_rendezvous/GetDeliverFailureMessage()
	return "Market-intelligence transmission failed. The caravan may have moved out of range or the beacon may be on cooldown."

/datum/trade_contract/caravan_rendezvous/HandleActiveTargetLoss()
	Fail("Target caravan departed before data handoff.", 0)

/datum/trade_contract/caravan_rendezvous/CanFulfillCargoRequirements(datum/trading_station/source_station)
	return TRUE

/datum/trade_contract/caravan_rendezvous/CleanupPayload()
	..()
	if(istype(assigned_disk))
		if(!QDELETED(assigned_disk))
			assigned_disk.allow_contract_disposal = TRUE
			qdel(assigned_disk)
		else if(assigned_disk.linked_contract == src)
			assigned_disk.linked_contract = null
	assigned_disk = null

/datum/trade_contract/caravan_rendezvous/ExecuteAccept(obj/machinery/trade_beacon/receiving/receiver_beacon)
	var/obj/item/disk/trade_data/disk = receiver_beacon.DropItem(/obj/item/disk/trade_data)
	if(!disk)
		return FALSE
	var/datum/trading_station/destination_station = GetDestinationStation()
	disk.contract_id = id
	disk.linked_contract = src
	disk.contract_serial = contract_serial
	disk.destination_uid = destination_uid
	disk.destination_name = destination_station ? destination_station.name : "Caravan"
	disk.UpdateIntelLabel()
	assigned_disk = disk
	return TRUE

/datum/trade_contract/caravan_rendezvous/proc/GetIntelDisk(obj/machinery/trade_beacon/sending/sender_beacon = null)
	if(!istype(assigned_disk) || QDELETED(assigned_disk))
		return null
	if(sender_beacon && !(assigned_disk in sender_beacon.GetObjects()))
		return null
	return assigned_disk

/datum/trade_contract/caravan_rendezvous/CanFulfillDeliveryPayload(obj/machinery/trade_beacon/sending/sender_beacon)
	var/obj/item/disk/trade_data/disk = GetIntelDisk(sender_beacon)
	return istype(disk)

/datum/trade_contract/caravan_rendezvous/GetPayloadDeliverBlockReason(obj/machinery/trade_beacon/sending/sender_beacon)
	var/obj/item/disk/trade_data/disk = GetIntelDisk(sender_beacon)
	if(!istype(disk))
		return "Place the encrypted market intelligence disk on the sending beacon."
	return null

/datum/trade_contract/caravan_rendezvous/ExecuteDeliver(obj/machinery/trade_beacon/sending/sender_beacon)
	var/obj/item/disk/trade_data/disk = GetIntelDisk(sender_beacon)
	if(istype(disk))
		disk.allow_contract_disposal = TRUE
		qdel(disk)
	assigned_disk = null

/datum/trade_contract/caravan_rendezvous/GetCompletionLogPayload()
	return "<li>Payload: Encrypted intelligence disk transmitted.</li>"
