// TRADE: include freight boards in Sierra's existing research unlock tree.
/datum/technology/engineering/advanced_tools_wt/New()
	..()
	if(GLOB.using_map.path == "sierra")
		unlocks_designs = unlocks_designs.Copy()
		unlocks_designs |= list("trade_sending", "trade_receiving")
