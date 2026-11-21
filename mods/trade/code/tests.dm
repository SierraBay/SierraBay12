/datum/unit_test/frontier_trade_catalog_integrity
	name = "TRADE: Frontier Trade 100% legacy coverage, 10 relays, and zero-arbitrage integrity"

/datum/unit_test/frontier_trade_catalog_integrity/start_test()
	if(!SStrade.enabled)
		skip("Frontier Trade is only active on Sierra.")
		return TRUE
	var/failures = 0
	var/list/expected_stations = list(
		"engineering",
		"medicine",
		"general",
		"engines",
		"electronics",
		"fauna",
		"security",
		"morpheus",
		"skrell",
		"smugglers",
	)
	var/list/core_discovered = list(
		"engineering",
		"medicine",
		"general",
		"engines",
		"electronics",
		"fauna",
		"security",
		"smugglers",
	)
	for(var/req_uid in expected_stations)
		var/datum/trade_station/st = SStrade.stations[req_uid]
		if(!istype(st))
			log_bad("Expected trade station '[req_uid]' is missing from SStrade.stations.")
			failures++
			continue
		if(st.spawn_chance != 100)
			log_bad("Station [req_uid] must have spawn_chance = 100 (got [st.spawn_chance]).")
			failures++
		if((req_uid in core_discovered) && !st.start_discovered)
			log_bad("Station [req_uid] must have start_discovered = TRUE.")
			failures++
	var/datum/trade_station/smugglers = SStrade.stations["smugglers"]
	if(smugglers && !smugglers.black_market)
		log_bad("Smugglers station must have black_market = TRUE.")
		failures++

	// Verify 100% coverage of all active legacy supply packs in SSsupply.master_supply_list.
	var/active_legacy_packs = 0
	var/unmapped_legacy_packs = 0
	for(var/singleton/hierarchy/supply_pack/sp as anything in SSsupply.master_supply_list)
		if(!istype(sp) || isnull(sp.cost) || sp.is_category())
			continue
		active_legacy_packs++
		if(!(sp.type in SStrade.routed_packs) && !(sp.type in SStrade.aliased_packs))
			log_bad("Legacy supply pack [sp.type] ([sp.name]) is neither routed nor aliased in SStrade.")
			unmapped_legacy_packs++
			failures++
	if(active_legacy_packs < 450 || unmapped_legacy_packs > 0)
		log_bad("Legacy supply pack coverage incomplete: [active_legacy_packs - unmapped_legacy_packs]/[active_legacy_packs] covered.")
		failures++

	var/list/occupied_turfs = list()
	for(var/uid in SStrade.stations)
		var/datum/trade_station/station = SStrade.stations[uid]
		var/obj/overmap/trade_station/relay = station.overmap_object
		if(!istype(relay))
			log_bad("Station [uid] missing overmap object.")
			failures++
		else
			if(!(relay.icon_state in icon_states(relay.icon)))
				log_bad("Overmap relay for [uid] has invalid icon_state '[relay.icon_state]'.")
				failures++
			if(!relay.desc || !length(relay.scans))
				log_bad("Overmap relay for [uid] missing desc or base scan data.")
				failures++
			if(station.start_discovered && !relay.instant_contact)
				log_bad("Start-discovered station [uid] should have instant_contact = TRUE.")
				failures++
			var/turf/relay_turf = get_turf(relay)
			if(relay_turf in occupied_turfs)
				log_bad("Station [uid] overlaps another trade relay on the overmap.")
				failures++
			occupied_turfs += relay_turf
		for(var/id in station.goods)
			var/datum/trade_good/good = station.goods[id]
			var/price = good.get_price()
			if(price <= 0)
				log_bad("Good [id] has non-positive price [price].")
				failures++
			if(good.export_floor >= price)
				log_bad("Good [id] ([good.name]) has export_floor [good.export_floor] >= buy price [price].")
				failures++
			var/obj/item/storage/box/holder = new(null)
			var/atom/movable/spawned = good.spawn_item(holder)
			if(!istype(spawned))
				log_bad("Good [id] ([good.name]) failed to spawn.")
				failures++
				qdel(holder)
				continue
			if(good.supply_pack_type && !(TRADE_TAG_NONEXPORTABLE in spawned.trade_export_tags))
				log_bad("Pack-backed good [id] container missing TRADE_TAG_NONEXPORTABLE.")
				failures++
			var/datum/trade_appraisal/quote = SStrade.appraise(spawned)
			if(quote.total >= price)
				log_bad("Buy/export arbitrage on [id] ([good.name]): price [price] <= appraisal [quote.total].")
				failures++
			if(istype(spawned, /obj/structure/largecrate/animal))
				var/animal_value = 0
				for(var/mob/living/simple_animal/animal in spawned.contents)
					animal_value += SStrade.get_animal_export_points(animal.type, animal.stat != DEAD) * TRADE_POINT_VALUE
				if(animal_value >= price)
					log_bad("Livestock buy/export arbitrage on [id] ([good.name]): price [price] <= payout [animal_value].")
					failures++
			if(istype(spawned, /obj/item/prosthetic_kit) && price <= 400)
				log_bad("Prosthetic kit [id] priced at [price] <= unpacked organ worth 400.")
				failures++
			qdel(quote)
			qdel(spawned)
			for(var/atom/movable/leftover as anything in holder.contents.Copy())
				qdel(leftover)
			qdel(holder)
		for(var/id in station.offers)
			var/datum/trade_offer/offer = station.offers[id]
			if(offer.unit_price < 1)
				log_bad("Offer [id] has invalid unit_price [offer.unit_price].")
				failures++
			for(var/good_id in SStrade.goods)
				var/datum/trade_good/good = SStrade.goods[good_id]
				var/good_price = good.get_price()
				if(offer.reagent_type)
					if(!good.supply_pack_type && ispath(good.item_type, /obj/item/reagent_containers))
						var/atom/movable/sample = good.spawn_item(null)
						var/volume = sample?.reagents?.get_reagent_amount(offer.reagent_type) || 0
						qdel(sample)
						if(volume > 0 && offer.unit_price >= good_price * (offer.reagent_volume / volume))
							log_bad("Reagent bounty arbitrage on [id] from single good [good_id].")
							failures++
				else if(!good.supply_pack_type && ispath(good.item_type, offer.item_type))
					var/qty = good.stack_size || get_implicit_stack_amount(good.item_type)
					if(offer.unit_price >= good_price * offer.native_stack_size / qty)
						log_bad("Item bounty arbitrage on [id] from single good [good_id].")
						failures++
				else if(!offer.reagent_type && good.supply_pack_type)
					var/singleton/hierarchy/supply_pack/pack = GET_SINGLETON(good.supply_pack_type)
					if(!pack)
						continue
					var/is_rand = (pack.supply_method == /singleton/supply_method/randomized)
					var/total_cnt = get_pack_item_count(pack)
					for(var/cpath in pack.contains)
						if(!ispath(cpath, offer.item_type))
							continue
						var/cnt = is_rand ? max(1, pack.num_contained || 1) : max(1, pack.contains[cpath] || 1)
						var/c_stk = get_implicit_stack_amount(cpath)
						var/unit_buy = (good_price / (is_rand ? cnt : total_cnt)) * (offer.native_stack_size / c_stk)
						if(offer.unit_price >= unit_buy)
							log_bad("Bundle bounty arbitrage on [id] ([offer.unit_price]) from pack good [good_id] ([unit_buy]).")
							failures++
	if(failures)
		fail("[failures] trade catalog integrity error(s) found.")
	else
		pass("All 10 Frontier Trade stations, [active_legacy_packs] legacy packs, goods, and bounties passed integrity checks.")
	return TRUE

/datum/unit_test/frontier_trade_reserved_stock
	name = "TRADE: Restocking respects reserved stock"

/datum/unit_test/frontier_trade_reserved_stock/start_test()
	var/datum/trade_station/station = new
	var/datum/trade_good/good = new
	good.station = station
	good.reserved_stock = good.max_stock
	station.goods = list("unit-test-reservation" = good)
	station.update_tick()
	station.restock(good, 0)
	if(good.stock != 0)
		fail("Restocking exceeded capacity when the entire stock was reserved.")
	else
		good.reserved_stock = 0
		station.restock(good, 0)
		if(good.stock == 1)
			pass("Restocking respected the reservation and recovered an empty item when capacity was available.")
		else
			fail("Restocking did not recover an empty item with free capacity.")
	qdel(station)
	return TRUE

/datum/unit_test/frontier_trade_orders_and_delivery
	name = "TRADE: Orders, fees, refunds, special supply pack spawning, and hangar-safe delivery"

/datum/unit_test/frontier_trade_orders_and_delivery/start_test()
	if(!SStrade.enabled)
		skip("Frontier Trade is only active on Sierra.")
		return TRUE
	if(!length(SStrade.beacons_receiving))
		fail("No receiving trade beacons mapped on Sierra.")
		return TRUE
	var/obj/machinery/trade_beacon/receiving/beacon = SStrade.beacons_receiving[1]
	var/datum/trade_station/eng_station = SStrade.stations["engineering"]
	var/datum/trade_station/sec_station = SStrade.stations["security"] || eng_station
	var/datum/trade_good/steel_good
	var/datum/trade_good/vest_good
	for(var/id in eng_station?.goods)
		var/datum/trade_good/candidate = eng_station.goods[id]
		if(!candidate.supply_pack_type && candidate.item_type == /obj/item/stack/material/steel)
			steel_good = candidate
			break
	for(var/id in sec_station?.goods)
		var/datum/trade_good/candidate = sec_station.goods[id]
		if(!candidate.supply_pack_type && candidate.item_type == /obj/item/clothing/suit/armor/vest)
			vest_good = candidate
			break
	if(!vest_good)
		for(var/id in SStrade.goods)
			var/datum/trade_good/candidate = SStrade.goods[id]
			if(!candidate.supply_pack_type && candidate.req_access && !candidate.hidden && candidate.station.discovered)
				vest_good = candidate
				break
	if(!steel_good || !vest_good)
		fail("Expected steel or restricted armor good missing from Frontier Trade stations.")
		return TRUE

	var/orig_steel_stock = steel_good.stock
	var/orig_vest_stock = vest_good.stock
	var/orig_eng_wealth = eng_station.wealth
	var/orig_eng_favor = eng_station.favor
	var/orig_sec_wealth = vest_good.station.wealth
	var/orig_sec_favor = vest_good.station.favor
	var/datum/money_account/supply = department_accounts["Снабжения"]
	var/orig_supply_money = supply.money
	steel_good.stock = max(steel_good.stock, 5)
	vest_good.stock = max(vest_good.stock, 3)

	var/turf/spawn_turf = get_turf(beacon)
	var/mob/living/carbon/human/buyer = new(spawn_turf)
	buyer.real_name = "Test Quartermaster"
	var/obj/item/card/id/card = new(buyer)
	card.registered_name = buyer.real_name
	card.access = list(access_cargo)
	var/datum/money_account/personal_acc = create_account("Personal Test", buyer.real_name, 10000, ACCOUNT_TYPE_PERSONAL)
	card.associated_account_number = personal_acc.account_number
	all_money_accounts |= personal_acc

	var/failures = 0
	var/list/cart = list()
	cart[steel_good.id] = 1
	var/datum/trade_order/order = SStrade.create_order(cart, buyer.real_name, "Test direct buy", FALSE, buyer, TRUE, card)
	if(!order)
		log_bad("Failed to create personal trade order.")
		failures++
	else
		order.receiver_id = "\ref[beacon]"
		if(!SStrade.pay_order(order, personal_acc, TRUE, FALSE, buyer, card))
			log_bad("Personal order payment failed.")
			failures++
		else
			var/expected_fee = ceil(order.total * TRADE_HANDLING_FEE)
			if(personal_acc.money != 10000 - order.total - expected_fee)
				log_bad("Personal account balance mismatch after purchase.")
				failures++
			if(supply.money != orig_supply_money + expected_fee)
				log_bad("Supply account did not receive expected handling fee [expected_fee].")
				failures++
			if(!SStrade.deliver(order) || order.state != TRADE_DELIVERED)
				log_bad("Order failed to deliver to receiving beacon.")
				failures++
			var/obj/structure/closet/secure_closet/personal/trade/crate
			for(var/turf/floor as anything in beacon.get_transfer_turfs())
				crate = locate(/obj/structure/closet/secure_closet/personal/trade) in floor
				if(crate)
					break
			if(!crate || !crate.locked || crate.registered_name != buyer.real_name)
				log_bad("Delivered personal crate missing or unlocked.")
				failures++
			if(crate)
				QDEL_NULL(crate)
		SStrade.orders -= order.id
		qdel(order)

	var/list/refund_cart = list()
	refund_cart[steel_good.id] = 1
	var/datum/trade_order/refund_order = SStrade.create_order(refund_cart, buyer.real_name, "Test refund", FALSE, buyer, TRUE, card)
	if(refund_order)
		refund_order.receiver_id = "\ref[beacon]"
		var/pre_bal = personal_acc.money
		var/pre_sup = supply.money
		if(!SStrade.pay_order(refund_order, personal_acc, TRUE, FALSE, buyer, card) || !SStrade.cancel_order(refund_order))
			log_bad("Paid order refund flow failed.")
			failures++
		if(personal_acc.money != pre_bal || supply.money != pre_sup || refund_order.state != TRADE_CANCELLED)
			log_bad("Refund did not restore exact balances and cancel state.")
			failures++
		SStrade.orders -= refund_order.id
		qdel(refund_order)

	var/list/restricted_cart = list()
	restricted_cart[vest_good.id] = 1
	if(SStrade.create_order(restricted_cart, buyer.real_name, "Unauthorized buy", FALSE, buyer, TRUE, card))
		log_bad("Restricted item was allowed for unauthorized personal order.")
		failures++
	var/datum/trade_order/req_order = SStrade.create_order(restricted_cart, buyer.real_name, "Security vest needed", FALSE, buyer, FALSE, card, "testreq")
	if(!req_order || req_order.state != TRADE_REQUEST)
		log_bad("Department requisition creation failed.")
		failures++
	else
		req_order.receiver_id = "\ref[beacon]"
		if(!SStrade.pay_order(req_order, supply, FALSE, FALSE) || req_order.fee != 0)
			log_bad("Department approval failed or charged handling fee.")
			failures++
		SStrade.orders -= req_order.id
		qdel(req_order)

	// Verify special supply pack spawning & hangar-safe delivery (canister, {anchored = FALSE} vendor, animal crate, randomized pack, /obj/random/fish, supermatter sealed crate, full prosthetic set).
	var/turf/safe = get_safe_turf()
	var/list/special_packs = list(
		/singleton/hierarchy/supply_pack/atmospherics/canister_oxygen,
		/singleton/hierarchy/supply_pack/supply/sodavendor,
		/singleton/hierarchy/supply_pack/livecargo/corgi,
		/singleton/hierarchy/supply_pack/galley/pizza,
		/singleton/hierarchy/supply_pack/galley/seafood,
		/singleton/hierarchy/supply_pack/engineering/smsmall,
		/singleton/hierarchy/supply_pack/prosthesis/nanotrasen,
	)
	for(var/pack_path in special_packs)
		var/good_id = SStrade.routed_packs[pack_path]
		var/datum/trade_good/pgood = good_id ? SStrade.goods[good_id] : null
		if(!pgood)
			log_bad("Special supply pack [pack_path] is not routed to a trade good.")
			failures++
			continue
		var/atom/movable/container = pgood.spawn_item(safe, buyer.real_name)
		if(!istype(container) || QDELETED(container))
			log_bad("Special pack [pack_path] failed to spawn container.")
			failures++
			continue
		if(pack_path == /singleton/hierarchy/supply_pack/supply/sodavendor)
			var/obj/machinery/vending/vend = locate(/obj/machinery/vending) in container.contents
			if(!vend || vend.anchored)
				log_bad("Soda vendor pack failed to spawn unanchored vendor inside container.")
				failures++
		else if(pack_path == /singleton/hierarchy/supply_pack/livecargo/corgi)
			if(!istype(container, /obj/structure/largecrate/animal/corgi))
				log_bad("Corgi pack did not spawn inside /obj/structure/largecrate/animal/corgi.")
				failures++
		else if(pack_path == /singleton/hierarchy/supply_pack/galley/pizza)
			if(length(container.contents) < 5)
				log_bad("Randomized pizza pack spawned [length(container.contents)] items (expected 5).")
				failures++
		else if(pack_path == /singleton/hierarchy/supply_pack/galley/seafood)
			if(length(container.contents) < 8)
				log_bad("Seafood (/obj/random/fish) pack spawned [length(container.contents)] items (expected 8).")
				failures++
		else if(pack_path == /singleton/hierarchy/supply_pack/engineering/smsmall)
			var/obj/machinery/power/supermatter/shard = locate(/obj/machinery/power/supermatter) in container.contents
			if(!istype(container, /obj/structure/closet/crate/secure/large/phoron) || !shard)
				log_bad("Supermatter shard pack must arrive inside sealed phoron secure crate.")
				failures++
		else if(pack_path == /singleton/hierarchy/supply_pack/prosthesis/nanotrasen)
			var/organ_count = 0
			for(var/obj/item/organ/external/O in container.contents)
				organ_count++
			if(organ_count != 7)
				log_bad("Full NanoTrasen prosthetic set spawned [organ_count] organs (expected 7).")
				failures++
		qdel(container)

	// Verify pack-only order does NOT spawn an empty personal/trade locker, and mixed loose + largecrate order does NOT suck loose items into the largecrate.
	var/canister_good_id = SStrade.routed_packs[/singleton/hierarchy/supply_pack/atmospherics/canister_oxygen]
	var/datum/trade_good/canister_good = canister_good_id ? SStrade.goods[canister_good_id] : null
	if(canister_good)
		var/orig_can_stock = canister_good.stock
		var/orig_can_wealth = canister_good.station.wealth
		var/orig_can_favor = canister_good.station.favor
		canister_good.stock = max(canister_good.stock, 3)
		beacon.reset_instability()

		// 1) Pack-only order -> no personal/trade locker spawned!
		var/list/pack_cart = list()
		pack_cart[canister_good.id] = 1
		var/datum/trade_order/pack_order = SStrade.create_order(pack_cart, buyer.real_name, "Test canister pack", FALSE, buyer, FALSE, card)
		if(!pack_order || !SStrade.pay_order(pack_order, supply, FALSE, FALSE) || !SStrade.deliver(pack_order))
			log_bad("Pack-only order creation/delivery failed.")
			failures++
		else
			var/obj/structure/closet/secure_closet/personal/trade/empty_locker
			var/obj/structure/largecrate/delivered_largecrate
			for(var/turf/floor as anything in beacon.get_transfer_turfs())
				if(!empty_locker)
					empty_locker = locate(/obj/structure/closet/secure_closet/personal/trade) in floor
				if(!delivered_largecrate)
					delivered_largecrate = locate(/obj/structure/largecrate) in floor
			if(empty_locker)
				log_bad("Pack-only order spawned an unnecessary personal/trade wrapper locker.")
				failures++
				qdel(empty_locker)
			if(!delivered_largecrate)
				log_bad("Pack-only canister order did not deliver largecrate to receiving floor.")
				failures++
			else
				qdel(delivered_largecrate)
			for(var/turf/floor as anything in beacon.get_transfer_turfs())
				for(var/obj/item/paper/trade_invoice/inv in floor)
					qdel(inv)
		if(pack_order)
			SStrade.orders -= pack_order.id
			qdel(pack_order)

		// 2) Mixed loose item + largecrate order -> loose steel stays in personal locker, not sucked into largecrate!
		beacon.reset_instability()
		var/list/mixed_cart = list()
		mixed_cart[steel_good.id] = 1
		mixed_cart[canister_good.id] = 1
		var/datum/trade_order/mixed_order = SStrade.create_order(mixed_cart, buyer.real_name, "Test mixed loose + largecrate", FALSE, buyer, TRUE, card)
		if(!mixed_order || !SStrade.pay_order(mixed_order, personal_acc, TRUE, FALSE, buyer, card) || !SStrade.deliver(mixed_order))
			log_bad("Mixed loose + largecrate order failed to deliver.")
			failures++
		else
			var/obj/structure/closet/secure_closet/personal/trade/mixed_locker
			var/obj/structure/largecrate/mixed_largecrate
			for(var/turf/floor as anything in beacon.get_transfer_turfs())
				if(!mixed_locker)
					mixed_locker = locate(/obj/structure/closet/secure_closet/personal/trade) in floor
				if(!mixed_largecrate)
					mixed_largecrate = locate(/obj/structure/largecrate) in floor
			if(!mixed_locker || !(locate(/obj/item/stack/material/steel) in mixed_locker.contents))
				log_bad("Loose steel sheets missing from personal trade locker in mixed order (sucked into largecrate?).")
				failures++
			if(mixed_largecrate && (locate(/obj/item/stack/material/steel) in mixed_largecrate.contents))
				log_bad("Largecrate sucked loose steel sheets out of personal trade locker.")
				failures++
			if(mixed_locker)
				qdel(mixed_locker)
			if(mixed_largecrate)
				qdel(mixed_largecrate)
		if(mixed_order)
			SStrade.orders -= mixed_order.id
			qdel(mixed_order)

		canister_good.stock = orig_can_stock
		canister_good.station.wealth = orig_can_wealth
		canister_good.station.favor = orig_can_favor

	steel_good.stock = orig_steel_stock
	vest_good.stock = orig_vest_stock
	eng_station.wealth = orig_eng_wealth
	eng_station.favor = orig_eng_favor
	vest_good.station.wealth = orig_sec_wealth
	vest_good.station.favor = orig_sec_favor
	supply.money = orig_supply_money
	beacon.reset_instability()
	all_money_accounts -= personal_acc
	qdel(personal_acc)
	qdel(card)
	qdel(buyer)

	if(failures)
		fail("[failures] order/delivery check(s) failed.")
	else
		pass("Orders, personal fees, refunds, requisitions, special pack spawning, and hangar-safe delivery passed.")
	return TRUE

/datum/unit_test/frontier_trade_exports_and_bounties
	name = "TRADE: Beacon panels, 4-Class exports, integer commissions, and reagent bounties"

/datum/unit_test/frontier_trade_exports_and_bounties/start_test()
	if(!SStrade.enabled)
		skip("Frontier Trade is only active on Sierra.")
		return TRUE
	if(!length(SStrade.beacons_sending))
		fail("No sending trade beacons mapped on Sierra.")
		return TRUE
	var/obj/machinery/trade_beacon/sending/beacon = SStrade.beacons_sending[1]
	var/turf/beacon_turf = get_turf(beacon)
	var/datum/trade_station/veymed = SStrade.stations["medicine"]
	var/datum/trade_offer/tricord_offer
	for(var/id in veymed?.offers)
		var/datum/trade_offer/candidate = veymed.offers[id]
		if(candidate.reagent_type == /datum/reagent/tricordrazine)
			tricord_offer = candidate
			break
	if(!tricord_offer)
		fail("Expected tricordrazine reagent offer missing from Vey-Med.")
		return TRUE

	var/datum/money_account/supply = department_accounts["Снабжения"]
	var/orig_supply_money = supply.money
	var/orig_wealth = veymed.wealth
	var/orig_favor = veymed.favor
	var/orig_hidden = veymed.hidden_inv_unlocked
	var/orig_amount = tricord_offer.amount
	var/orig_completed = tricord_offer.completed
	var/datum/money_account/slave_acc = create_account("Slave Export Test", "Test Tech", 500, ACCOUNT_TYPE_PERSONAL)
	all_money_accounts |= slave_acc

	var/failures = 0
	beacon.panel_open = TRUE
	beacon.update_icon()
	if(beacon.icon_state != "beacon_sending_panel" || beacon.is_ready())
		log_bad("Beacon open panel did not update icon or disable readiness.")
		failures++
	beacon.panel_open = FALSE
	beacon.update_icon()
	if(beacon.icon_state != "beacon_sending" || !beacon.is_ready())
		log_bad("Beacon closed panel did not restore icon or readiness.")
		failures++

	var/obj/item/disk/nuclear/nuke_disk = new(beacon_turf)
	var/datum/trade_appraisal/protected_quote = SStrade.appraise(nuke_disk)
	if(protected_quote.total != 0)
		log_bad("Protected nuclear disk appraised for non-zero value.")
		failures++
	qdel(protected_quote)
	qdel(nuke_disk)

	// Verify research_report direct thaler appraisal (no double-15x multiplication) and Class A non-exportable guards.
	var/obj/item/disk/research_report/report = new(null)
	report.cargo_value = 450
	var/datum/trade_appraisal/report_quote = SStrade.appraise(report)
	if(report_quote.total != 450)
		log_bad("Research report with cargo_value=450 appraised for [report_quote.total] (expected 450).")
		failures++
	qdel(report_quote)
	qdel(report)

	var/obj/item/reagent_containers/glass/beaker/large/beaker = new(beacon_turf)
	beaker.reagents.add_reagent(/datum/reagent/tricordrazine, 90)
	tricord_offer.amount = 1
	tricord_offer.completed = FALSE
	beacon.reset_export()
	beacon.reset_instability()

	var/ok = SStrade.fulfill_offer(beacon, tricord_offer, FALSE, slave_acc, TRUE)
	if(!ok || !tricord_offer.completed)
		log_bad("Reagent bounty fulfillment failed.")
		failures++
	var/expected_total = tricord_offer.unit_price
	var/expected_fee = ceil(expected_total * TRADE_HANDLING_FEE)
	if(slave_acc.money != 500 + expected_total - expected_fee || supply.money != orig_supply_money + expected_fee)
		log_bad("Slave bounty payout or integer commission mismatch.")
		failures++
	if(QDELETED(beaker) || beaker.reagents.get_reagent_amount(/datum/reagent/tricordrazine) != 30)
		log_bad("Reagent bounty did not leave remaining 30u behind.")
		failures++

	if(!QDELETED(beaker))
		qdel(beaker)
	veymed.wealth = orig_wealth
	veymed.favor = orig_favor
	veymed.hidden_inv_unlocked = orig_hidden
	tricord_offer.amount = orig_amount
	tricord_offer.completed = orig_completed
	supply.money = orig_supply_money
	beacon.reset_export()
	beacon.reset_instability()
	all_money_accounts -= slave_acc
	qdel(slave_acc)

	if(failures)
		fail("[failures] export/bounty check(s) failed.")
	else
		pass("Beacon panels, protected appraisal, 4-Class appraisal, reagent bounties, and integer commission passed.")
	return TRUE

/datum/unit_test/frontier_trade_tgui_lifecycle
	name = "TRADE: TGUI static/dynamic split, spoiler gating, and NTOS lifecycle"

/datum/unit_test/frontier_trade_tgui_lifecycle/start_test()
	if(!SStrade.enabled)
		skip("Frontier Trade is only active on Sierra.")
		return TRUE
	var/turf/safe = get_safe_turf()
	var/obj/machinery/computer/modular/preset/dock/console = new(safe)
	var/datum/extension/interactive/ntos/os = get_extension(console, /datum/extension/interactive/ntos)
	if(!os)
		qdel(console)
		fail("Preset dock console missing NTOS extension.")
		return TRUE
	os.system_boot()
	var/mob/living/carbon/human/user = new(safe)
	var/datum/computer_file/program/trade/prog = os.run_program("trade", user)
	var/failures = 0
	if(!prog || !istype(prog.trade_ui))
		log_bad("Running trade program failed to initialize TGUI module.")
		failures++
	else
		var/list/static_data = prog.trade_ui.tgui_static_data(user)
		var/list/data = prog.trade_ui.tgui_data(user)
		if(!isnum(static_data["catalog_version"]) || !islist(static_data["catalog"]) || !length(static_data["catalog"]) || !islist(static_data["categories"]))
			log_bad("TGUI static payload missing catalog_version, catalog, or categories.")
			failures++
		if(!length(data["stations"]) || !islist(data["beacons"]) || !islist(data["ntos"]) || !islist(data["stocks"]) || !islist(data["prices"]))
			log_bad("TGUI dynamic payload missing stations, beacons, ntos, stocks, or prices sections.")
			failures++
		// Verify zero spoiler leak in static catalog when un-hacked.
		for(var/list/cat_row as anything in static_data["catalog"])
			var/datum/trade_good/g = SStrade.goods[cat_row["id"]]
			if(!g)
				log_bad("Static catalog contains unknown good id '[cat_row["id"]]'.")
				failures++
				continue
			if(!g.station.discovered)
				log_bad("Static catalog leaked good '[g.id]' from undiscovered station '[g.station.uid]'.")
				failures++
			if(g.station.black_market)
				log_bad("Static catalog leaked black-market good '[g.id]' on un-emagged terminal.")
				failures++
			if(g.hidden && !g.station.hidden_inv_unlocked)
				log_bad("Static catalog leaked locked hidden good '[g.id]'.")
				failures++
		// Verify catalog_version bumps when hidden inventory unlocks.
		var/datum/trade_station/eng = SStrade.stations["engineering"]
		if(eng)
			var/orig_favor = eng.favor
			var/orig_hidden = eng.hidden_inv_unlocked
			var/orig_wealth = eng.wealth
			var/orig_ver = SStrade.catalog_version
			eng.hidden_inv_unlocked = FALSE
			eng.favor = 0
			eng.add_to_wealth(eng.hidden_inv_threshold * 4, is_offer = TRUE)
			if(!eng.hidden_inv_unlocked || SStrade.catalog_version <= orig_ver)
				log_bad("Unlocking hidden inventory did not bump SStrade.catalog_version.")
				failures++
			eng.favor = orig_favor
			eng.hidden_inv_unlocked = orig_hidden
			eng.wealth = orig_wealth

		var/datum/trade_good/first_good
		for(var/id in SStrade.goods)
			var/datum/trade_good/candidate = SStrade.goods[id]
			if(candidate.station.discovered && candidate.stock > 0 && candidate.is_available())
				first_good = candidate
				break
		if(first_good)
			prog.trade_ui.set_cart_quantity(first_good.id, 1)
			if(prog.trade_ui.cart[first_good.id] != 1)
				log_bad("TGUI module failed to add item to cart.")
				failures++
		var/datum/tgui_module/trade/pda/pda_ui = new(os, prog)
		var/list/pda_data = pda_ui.tgui_data(user)
		if(!pda_data["read_only"])
			log_bad("PDA trade module did not report read_only = TRUE.")
			failures++
		qdel(pda_ui)
		os.kill_program(prog, TRUE)
		if(prog.trade_ui)
			log_bad("Killing trade program did not clean up trade_ui.")
			failures++

	qdel(user)
	qdel(console)
	if(failures)
		fail("[failures] TGUI lifecycle check(s) failed.")
	else
		pass("Frontier Trade TGUI static/dynamic split, spoiler gating, cart persistence, and cleanup passed.")
	return TRUE
