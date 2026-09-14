/datum/trading_station/unit_test_contract_source
	name = "Unit Test Source"
	desc = "Trade station used for contract unit tests."
	uid = "unit_test_contract_source"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_source/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Contract Pen", null, 10)),
		"Tools" = list(/obj/item/crowbar = GOODS_DATA("Source Crowbar", null, 20))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_destination
	name = "Unit Test Destination"
	desc = "Destination station used for contract unit tests."
	uid = "unit_test_contract_destination"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_destination/AssembleInventory()
	inventory = list(
		"Demand" = list(/obj/item/pen = GOODS_DATA("Demand Pen", null, 35)),
		"Beta" = list(/obj/item/paper = GOODS_DATA("Destination Paper", null, 5))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_no_market_source
	name = "Unit Test No-Market Source"
	desc = "Trade station used for contract no-market tests."
	uid = "unit_test_contract_no_market_source"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_no_market_source/AssembleInventory()
	inventory = list(
		"Alpha" = list(/obj/item/pen = GOODS_DATA("Stable Pen", null, 10))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/trading_station/unit_test_contract_no_market_destination
	name = "Unit Test No-Market Destination"
	desc = "Destination station used for contract no-market tests."
	uid = "unit_test_contract_no_market_destination"
	spawn_probability = 0
	spawn_cost = 0
	base_income = 0
	live_market_auto_events = FALSE

/datum/trading_station/unit_test_contract_no_market_destination/AssembleInventory()
	inventory = list(
		"Demand" = list(/obj/item/pen = GOODS_DATA("Stable Pen", null, 15))
	)
	hidden_inventory = list()
	amounts_of_goods = list()
	unique_good_count = 0
	next_good_offer_id = 0
	live_market_state = list()
	live_market_modifiers = list()
	NormalizeGoodsRecords()

/datum/cargo_contract_test_fixture
	var/datum/trading_station/source_station
	var/datum/trading_station/destination_station
	var/datum/trading_station/caravan/caravan_station
	var/obj/overmap/trade_beacon/caravan/caravan_object
	var/obj/overmap/trade_beacon/source_beacon
	var/obj/overmap/trade_beacon/destination_beacon
	var/datum/money_account/account
	var/obj/machinery/trade_beacon/receiving/receiver
	var/obj/machinery/trade_beacon/sending/sender
	var/list/spawned_crates
	var/list/original_visible_stations
	var/list/original_all_stations
	var/list/original_contracts
	var/source_shared_good
	var/source_unmatched_good
	var/destination_shared_good

/datum/cargo_contract_test_fixture/New()
	..()
	original_visible_stations = SSsupply.visible_trading_stations
	original_all_stations = SSsupply.all_trading_stations
	original_contracts = SSsupply.trade_contracts
	SSsupply.trade_contracts = list()

/datum/cargo_contract_test_fixture/Destroy()
	SSsupply.visible_trading_stations = original_visible_stations
	SSsupply.all_trading_stations = original_all_stations
	SSsupply.trade_contracts = original_contracts
	original_visible_stations = null
	original_all_stations = null
	original_contracts = null

	if(receiver)
		for(var/obj/structure/closet/crate/trade_contract/crate in range(2, receiver))
			LAZYADD(spawned_crates, crate)
	if(sender)
		for(var/obj/structure/closet/crate/trade_contract/crate in range(2, sender))
			LAZYADD(spawned_crates, crate)
	for(var/obj/structure/closet/crate/trade_contract/crate as anything in spawned_crates)
		qdel(crate)
	spawned_crates = null

	QDEL_NULL(receiver)
	QDEL_NULL(sender)
	QDEL_NULL(account)
	QDEL_NULL(caravan_object)
	QDEL_NULL(caravan_station)
	QDEL_NULL(source_beacon)
	QDEL_NULL(destination_beacon)
	QDEL_NULL(source_station)
	QDEL_NULL(destination_station)
	return ..()

/datum/cargo_contract_test_fixture/proc/setup_route(datum/unit_test/test, source_station_type = /datum/trading_station/unit_test_contract_source, dest_station_type = /datum/trading_station/unit_test_contract_destination)
	var/turf/source_turf = test.get_safe_turf()
	var/obj/overmap/visitable/current_sector = SSsupply.GetOvermapSectorFor(source_turf)
	if(!istype(source_turf) || !istype(current_sector))
		return FALSE

	var/turf/source_market = null
	var/turf/destination_market = null
	var/overmap_limit = GLOB.using_map.overmap_size
	if(current_sector.x + 4 <= overmap_limit)
		source_market = locate(current_sector.x + 1, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x + 4, current_sector.y, current_sector.z)
	else if(current_sector.x - 4 >= 1)
		source_market = locate(current_sector.x - 1, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x - 4, current_sector.y, current_sector.z)
	else if(current_sector.y + 4 <= overmap_limit)
		source_market = locate(current_sector.x, current_sector.y + 1, current_sector.z)
		destination_market = locate(current_sector.x, current_sector.y + 4, current_sector.z)
	else if(current_sector.y - 4 >= 1)
		source_market = locate(current_sector.x, current_sector.y - 1, current_sector.z)
		destination_market = locate(current_sector.x, current_sector.y - 4, current_sector.z)
	else if(current_sector.x + 3 <= overmap_limit)
		source_market = locate(current_sector.x, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x + 3, current_sector.y, current_sector.z)
	else if(current_sector.x - 3 >= 1)
		source_market = locate(current_sector.x, current_sector.y, current_sector.z)
		destination_market = locate(current_sector.x - 3, current_sector.y, current_sector.z)

	if(!istype(source_market) || !istype(destination_market))
		return FALSE

	source_station = new source_station_type
	destination_station = new dest_station_type
	source_station.AssembleInventory()
	source_station.InitGoods()
	destination_station.AssembleInventory()
	destination_station.InitGoods()

	source_beacon = new /obj/overmap/trade_beacon(source_market)
	destination_beacon = new /obj/overmap/trade_beacon(destination_market)
	source_station.overmap_location = source_market
	source_station.overmap_object = source_beacon
	destination_station.overmap_location = destination_market
	destination_station.overmap_object = destination_beacon
	source_station.trade_range = 5
	destination_station.trade_range = 5

	SSsupply.visible_trading_stations = list(source_station, destination_station)
	SSsupply.all_trading_stations = list(source_station, destination_station)
	return TRUE

/datum/cargo_contract_test_fixture/proc/setup_market_fixture()
	if(!istype(source_station) || !istype(destination_station))
		return FALSE

	source_shared_good = source_station.inventory["Alpha"][1]
	source_unmatched_good = source_station.inventory["Tools"][1]
	destination_shared_good = destination_station.inventory["Demand"][1]
	if(!source_shared_good || !source_unmatched_good || !destination_shared_good)
		return FALSE

	source_station.SetGoodAmount("Alpha", source_shared_good, 20)
	source_station.EnsureLiveMarketCommodity("Alpha", source_shared_good, 15, 10)
	source_station.SetGoodAmount("Tools", source_unmatched_good, 20)
	source_station.EnsureLiveMarketCommodity("Tools", source_unmatched_good, 20, 10)
	destination_station.SetGoodAmount("Demand", destination_shared_good, 1)
	destination_station.EnsureLiveMarketCommodity("Demand", destination_shared_good, 35, 10)
	destination_station.AdjustLiveMarketDemand("Demand", destination_shared_good, 5)
	return TRUE

/datum/cargo_contract_test_fixture/proc/setup_caravan_fixture()
	if(!istype(source_station) || !istype(destination_station) || !istype(destination_station.overmap_location))
		return null

	caravan_station = new
	caravan_station.name = "Unit Test Caravan"
	caravan_station.desc = "A mobile caravan used for rendezvous contract tests."
	caravan_station.uid = "unit_test_trade_caravan"
	caravan_station.trade_range = 5
	caravan_station.overmap_location = destination_station.overmap_location

	caravan_object = new(destination_station.overmap_location)
	caravan_object.BindToStation(caravan_station)
	caravan_object.current_stop = source_station
	caravan_object.BeginTradeWindow(10 MINUTES)

	SSsupply.visible_trading_stations = list(source_station, caravan_station)
	SSsupply.all_trading_stations = list(source_station, caravan_station)
	return caravan_station

/datum/cargo_contract_test_fixture/proc/depart_caravan()
	QDEL_NULL(caravan_object)

/datum/cargo_contract_test_fixture/proc/create_account(starting_money = 0)
	account = new
	account.money = starting_money
	return account

/datum/cargo_contract_test_fixture/proc/create_receiver(turf/loc)
	receiver = new(loc)
	return receiver

/datum/cargo_contract_test_fixture/proc/create_sender(turf/loc)
	sender = new(loc)
	return sender

/datum/cargo_contract_test_fixture/proc/track_crate(atom/near_atom)
	var/obj/structure/closet/crate/trade_contract/crate = locate(/obj/structure/closet/crate/trade_contract) in range(2, near_atom)
	if(crate)
		LAZYADD(spawned_crates, crate)
	return crate

/datum/unit_test/cargo_trade_contract_market_selection_test
	name = "CARGO: Trade contracts prefer market-valid shared commodities"

/datum/unit_test/cargo_trade_contract_market_selection_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for trade contract market-selection test.")
		return 1

	fixture.setup_market_fixture()
	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a market-valid contract."
	else
		var/list/content = length(contract.contents) ? contract.contents[1] : null
		if(!islist(content))
			fail_reason = "Generated contract did not contain a cargo line item."
		else if(content["good_id"] != fixture.source_shared_good)
			fail_reason = "Contract chose [content["good_id"]] instead of the shared market commodity [fixture.source_shared_good]."
		else if(content["good_id"] == fixture.source_unmatched_good)
			fail_reason = "Contract selected the unmatched source-only commodity."
		else if(contract.market_reason != "hybrid")
			fail_reason = "Contract market reason was [contract.market_reason] instead of hybrid."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts choose shared live-market opportunities instead of random source goods.")
	return 1

/datum/unit_test/cargo_trade_contract_no_market_candidate_test
	name = "CARGO: Trade contracts require shortage or spread"

/datum/unit_test/cargo_trade_contract_no_market_candidate_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src, /datum/trading_station/unit_test_contract_no_market_source, /datum/trading_station/unit_test_contract_no_market_destination))
		qdel(fixture)
		skip("Overmap sector unavailable for no-market trade contract test.")
		return 1

	var/source_good_id = fixture.source_station.inventory["Alpha"][1]
	var/destination_good_id = fixture.destination_station.inventory["Demand"][1]
	fixture.source_station.SetGoodAmount("Alpha", source_good_id, 10)
	fixture.source_station.EnsureLiveMarketCommodity("Alpha", source_good_id, 10, 10)
	fixture.destination_station.SetGoodAmount("Demand", destination_good_id, 10)
	fixture.destination_station.EnsureLiveMarketCommodity("Demand", destination_good_id, 15, 10)

	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	qdel(fixture)

	if(contract)
		fail("CreateTradeContract() created a contract without shortage, demand, or profitable spread.")
	else
		pass("Trade contracts are not created without a real market opportunity.")
	return 1

/datum/unit_test/cargo_trade_contract_accept_test
	name = "CARGO: Trade contracts spawn cargo crates"

/datum/unit_test/cargo_trade_contract_accept_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for trade contract accept test.")
		return 1

	fixture.setup_market_fixture()
	var/offer_id = fixture.source_shared_good
	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	var/starting_amount = fixture.source_station.GetGoodAmount("Alpha", offer_id)
	var/datum/money_account/account = fixture.create_account()
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else if(contract.status != CONTRACT_STATUS_ACTIVE)
		fail_reason = "Contract status did not update to active."
	else if(fixture.source_station.GetGoodAmount("Alpha", offer_id) >= starting_amount)
		fail_reason = "Accepting a contract did not reserve the source station stock."
	else
		var/obj/structure/closet/crate/trade_contract/crate = fixture.track_crate(receiver)
		if(!istype(crate))
			fail_reason = "Contract acceptance did not spawn a contract crate."
		else if(crate.contract_id != contract.id)
			fail_reason = "Spawned contract crate was not linked to the accepted contract."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts spawn delivery cargo and reserve stock.")
	return 1

/datum/unit_test/cargo_trade_contract_delivery_test
	name = "CARGO: Trade contracts pay out on delivery"

/datum/unit_test/cargo_trade_contract_delivery_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for trade contract delivery test.")
		return 1

	fixture.setup_market_fixture()
	var/destination_good_id = fixture.destination_shared_good
	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	var/datum/money_account/account = fixture.create_account(500)
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = fixture.create_sender(get_turf(receiver))
	var/starting_money = account.money
	var/starting_destination_stock = fixture.destination_station.GetGoodAmount("Demand", destination_good_id)
	var/starting_destination_demand = fixture.destination_station.GetLiveMarketDemandScore("Demand", destination_good_id)
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else
		var/obj/structure/closet/crate/trade_contract/crate = fixture.track_crate(receiver)
		if(!istype(crate))
			fail_reason = "Contract crate was not spawned for delivery test."
		else
			crate.forceMove(get_turf(sender))
			if(!SSsupply.DeliverTradeContract(sender, contract.id))
				fail_reason = "DeliverTradeContract() failed for a crate in sender range."
			else if(account.money <= starting_money)
				fail_reason = "Delivering the contract did not pay the linked account."
			else if(contract.status != CONTRACT_STATUS_COMPLETED)
				fail_reason = "Contract status did not update to completed."
			else if(fixture.destination_station.GetGoodAmount("Demand", destination_good_id) <= starting_destination_stock)
				fail_reason = "Contract delivery did not replenish destination market stock."
			else if(fixture.destination_station.GetLiveMarketDemandScore("Demand", destination_good_id) >= starting_destination_demand)
				fail_reason = "Contract delivery did not cool destination market demand."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contract delivery pays out and completes.")
	return 1

/datum/unit_test/cargo_trade_contract_tamper_test
	name = "CARGO: Tampering fails trade contracts"

/datum/unit_test/cargo_trade_contract_tamper_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for trade contract tamper test.")
		return 1

	fixture.setup_market_fixture()
	var/destination_good_id = fixture.destination_shared_good
	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	var/datum/money_account/account = fixture.create_account(1000)
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/starting_destination_stock = fixture.destination_station.GetGoodAmount("Demand", destination_good_id)
	var/starting_destination_demand = fixture.destination_station.GetLiveMarketDemandScore("Demand", destination_good_id)
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid contract."
	else
		var/obj/structure/closet/crate/trade_contract/crate = fixture.track_crate(receiver)
		if(!istype(crate))
			fail_reason = "Contract crate was not spawned for tamper test."
		else
			crate.toggle(null)
			if(contract.status != CONTRACT_STATUS_FAILED)
				fail_reason = "Tampering did not mark the contract as failed."
			else if(account.money != max(0, 1000 - round(contract.base_value * 2)))
				fail_reason = "Tampering penalty was [account.money], expected [max(0, 1000 - round(contract.base_value * 2))]."
			else if(fixture.destination_station.GetGoodAmount("Demand", destination_good_id) != starting_destination_stock)
				fail_reason = "Failed contract changed destination market stock."
			else if(fixture.destination_station.GetLiveMarketDemandScore("Demand", destination_good_id) != starting_destination_demand)
				fail_reason = "Failed contract changed destination market demand."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Tampering fails contracts and applies penalties.")
	return 1

/datum/unit_test/cargo_trade_contract_reward_snapshot_test
	name = "CARGO: Trade contract reward uses creation snapshot"

/datum/unit_test/cargo_trade_contract_reward_snapshot_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for trade contract reward snapshot test.")
		return 1

	fixture.setup_market_fixture()
	var/destination_good_id = fixture.destination_shared_good
	var/datum/trade_contract/contract = SSsupply.CreateTradeContract(fixture.source_station)
	var/snapshotted_reward = contract ? contract.reward : 0
	var/datum/money_account/account = fixture.create_account(250)
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = fixture.create_sender(get_turf(receiver))
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateTradeContract() did not return a contract."
	else
		fixture.destination_station.SetGoodAmount("Demand", destination_good_id, 0)
		fixture.destination_station.AdjustLiveMarketDemand("Demand", destination_good_id, 5)
		if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
			fail_reason = "AcceptTradeContract() failed for reward snapshot test."
		else
			var/obj/structure/closet/crate/trade_contract/crate = fixture.track_crate(receiver)
			if(!istype(crate))
				fail_reason = "Contract crate was not spawned for reward snapshot test."
			else
				crate.forceMove(get_turf(sender))
				if(!SSsupply.DeliverTradeContract(sender, contract.id))
					fail_reason = "DeliverTradeContract() failed for reward snapshot test."
				else if(account.money != 250 + snapshotted_reward)
					fail_reason = "Delivery paid [account.money - 250] instead of snapshotted reward [snapshotted_reward]."
				else if(contract.reward != snapshotted_reward)
					fail_reason = "Contract reward changed from [snapshotted_reward] to [contract.reward] after market movement."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Trade contracts keep their reward snapshot even if the market moves.")
	return 1

/datum/unit_test/cargo_caravan_rendezvous_contract_test
	name = "CARGO: Caravan rendezvous contracts transmit market intelligence"

/datum/unit_test/cargo_caravan_rendezvous_contract_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for caravan rendezvous contract test.")
		return 1

	var/datum/trading_station/caravan/caravan_station = fixture.setup_caravan_fixture()
	var/datum/trade_contract/caravan_rendezvous/contract = SSsupply.CreateCaravanRendezvousContract(caravan_station)
	var/datum/money_account/account = fixture.create_account(250)
	account.owner_name = "Unit Test"
	var/starting_money = account.money
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/obj/machinery/trade_beacon/sending/sender = fixture.create_sender(get_turf(receiver))
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateCaravanRendezvousContract() did not return a caravan rendezvous contract."
	else if(contract.GetTypeLabel() != "Rendezvous Contract")
		fail_reason = "Caravan contract did not expose the rendezvous type label."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed for a valid caravan rendezvous contract."
	else if(contract.status != CONTRACT_STATUS_ACTIVE)
		fail_reason = "Caravan contract status did not update to active."
	else if(locate(/obj/structure/closet/crate/trade_contract) in range(2, receiver))
		fail_reason = "Caravan rendezvous contracts should not spawn a contract crate."
	else if(!SSsupply.DeliverTradeContract(sender, contract.id))
		fail_reason = "DeliverTradeContract() failed for a caravan rendezvous contract in beacon range."
	else if(contract.status != CONTRACT_STATUS_COMPLETED)
		fail_reason = "Caravan rendezvous contract did not complete after transmission."
	else if(account.money <= starting_money)
		fail_reason = "Completing a caravan rendezvous contract did not pay the linked account."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Caravan rendezvous contracts accept, transmit, and pay out without spawning cargo.")
	return 1

/datum/unit_test/cargo_caravan_rendezvous_departure_fail_test
	name = "CARGO: Caravan rendezvous contracts fail when the caravan departs"

/datum/unit_test/cargo_caravan_rendezvous_departure_fail_test/start_test()
	var/datum/cargo_contract_test_fixture/fixture = new
	if(!fixture.setup_route(src))
		qdel(fixture)
		skip("Overmap sector unavailable for caravan departure fail test.")
		return 1

	var/datum/trading_station/caravan/caravan_station = fixture.setup_caravan_fixture()
	var/datum/trade_contract/caravan_rendezvous/contract = SSsupply.CreateCaravanRendezvousContract(caravan_station)
	var/datum/money_account/account = fixture.create_account()
	account.owner_name = "Unit Test"
	var/obj/machinery/trade_beacon/receiving/receiver = fixture.create_receiver(get_safe_turf())
	var/fail_reason = null

	if(!istype(contract))
		fail_reason = "CreateCaravanRendezvousContract() did not return a contract for departure fail test."
	else if(!SSsupply.AcceptTradeContract(receiver, account, contract.id))
		fail_reason = "AcceptTradeContract() failed before departure fail test could run."
	else
		fixture.depart_caravan()
		SSsupply.RefreshCaravanContracts()
		if(contract.status != CONTRACT_STATUS_FAILED)
			fail_reason = "Caravan contract did not fail after the caravan became unavailable."
		else if(contract.failure_reason != "Target caravan departed before data handoff.")
			fail_reason = "Caravan departure failure reason was '[contract.failure_reason]' instead of the expected data-handoff message."

	qdel(fixture)

	if(fail_reason)
		fail(fail_reason)
	else
		pass("Caravan rendezvous contracts fail immediately when the target caravan departs.")
	return 1
