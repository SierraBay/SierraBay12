/obj/item/device/scanner/price
	name = "price scanner"
	desc = "Using an up-to-date database of various costs and prices, this device estimates the market price of an item up to 0.001% accuracy."
	icon = 'icons/obj/tools/price_scanner.dmi'
	icon_state = "price_scanner"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 4)
	scan_sound = 'sound/effects/checkout.ogg'

/obj/item/device/scanner/price/is_valid_scan_target(atom/target) // [SIERRA-EDIT] TRADE
	if(SStrade.enabled) // [SIERRA-ADD] TRADE
		return istype(target) // [/SIERRA-ADD]
	return !!get_value(target)

/obj/item/device/scanner/price/scan(atom/target, mob/user) // [SIERRA-EDIT] TRADE
	scan_title = "Price estimations"
	if(!target) // [SIERRA-ADD] TRADE
		return // [/SIERRA-ADD]
	// [SIERRA-ADD] TRADE
	if(SStrade.enabled)
		var/datum/trade_appraisal/quote = SStrade.appraise(target)
		var/result = "[html_encode(target.name)]: export value [quote.total] [GLOB.using_map.local_currency_name]."
		qdel(quote)
		scan_data = scan_data ? "[scan_data]<br>[result]" : result
		to_chat(user, SPAN_NOTICE(result))
		return
	// [/SIERRA-ADD]
	var/data = "\The [target]: [get_value(target)] [GLOB.using_map.local_currency_name]"
	if(!scan_data)
		scan_data = data
	else
		scan_data += "<br>[data]"
	user.show_message(data)
