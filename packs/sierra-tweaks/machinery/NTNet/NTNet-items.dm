//  HACSO's HUD and related interactions
// code\__defines\items_clothing.dm - used outside pack


/obj/item/clothing/glasses/hud/it
	name = "IT special HUD"
	desc = "An augmented reality device that allows you to see doors NTNet ID's."
	icon_state = "ithud"
	off_state = "ithud_off"
	hud_type = HUD_IT
	body_parts_covered = 0

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if (lock_cut_state == BOLTS_EXPOSED)
		to_chat(user, "The bolt cover has been cut open.")
	if (lock_cut_state == BOLTS_CUT)
		to_chat(user, "The door bolts have been cut.")
	if(brace)
		to_chat(user, "\The [brace] is installed on \the [src], preventing it from opening.")
		brace.examine_damage_state(user)
	if(hasHUD(user, HUD_IT) && arePowerSystemsOn())
		to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [t_ntnet_id]")))

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	if(hasHUD(user, HUD_IT))
		if(network_card && network_card.check_functionality() && enabled)
			to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [network_card.get_network_tag()].")))

/obj/machinery/computer/modular/examine(mob/user)
	. = ..()
	if(hasHUD(user, HUD_IT))
		var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos)
		var/obj/item/stock_parts/computer/network_card/network_card = os.get_component(PART_NETWORK)
		if(istype(network_card) && network_card.check_functionality() && os.on)
			to_chat(user, SPAN_INFO(SPAN_ITALIC("You may notice a small hologram that says: [network_card.get_network_tag()].")))
