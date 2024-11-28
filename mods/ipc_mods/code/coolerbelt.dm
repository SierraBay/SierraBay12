/obj/item/device/suit_cooling_unit/is_in_slot()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return 0

	return (H.back == src) || (H.s_store == src) || (H.belt == src)

/obj/item/device/suit_cooling_unit/miniature
	name = "miniature cooling device"
	desc = "Minituarized heat sink that can be hooked up to around waist. Weaker than it's bigger counterpart."
	w_class = ITEM_SIZE_NORMAL
	icon = 'mods/ipc_mods/icons/beltcooler.dmi'
	item_icons = list(
		slot_belt_str = 'mods/ipc_mods/icons/beltcooler.dmi',
		)
	icon_state = "miniaturesuitcooler0"
	item_state = "coolingbelt"

	max_cooling = 6
	charge_consumption = 2.4 KILOWATTS
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_ALUMINIUM = 5000, MATERIAL_GLASS = 3000)

/obj/item/device/suit_cooling_unit/miniature/on_update_icon()
	ClearOverlays()
	if (cover_open)
		if (cell)
			icon_state = "miniaturesuitcooler1"
		else
			icon_state = "miniaturesuitcooler2"
		return

	icon_state = "miniaturesuitcooler0"

	if(!cell || !on)
		return

	switch(round(cell.percent()))
		if(86 to INFINITY)
			AddOverlays("minibattery-0")
		if(69 to 85)
			AddOverlays("minibattery-1")
		if(52 to 68)
			AddOverlays("minibattery-2")
		if(35 to 51)
			AddOverlays("minibattery-3")
		if(18 to 34)
			AddOverlays("minibattery-4")
		if(-INFINITY to 17)
			AddOverlays("minibattery-5")


/obj/item/device/suit_cooling_unit/miniature/Process()
	if (!on || !cell)
		return

	if (!is_in_slot())
		return

	var/mob/living/carbon/human/H = loc
	if ((H.pressure_alert == -1) || (H.pressure_alert == -2))
		max_cooling = max_cooling/2

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.bodytemperature -= temp_adj

	cell.use(charge_usage * CELLRATE)
	update_icon()

	if(cell.charge <= 0)
		turn_off(1)


/obj/item/device/suit_cooling_unit/miniature/empty


/obj/item/device/suit_cooling_unit/empty/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	cell = null

/datum/fabricator_recipe/mini_suit_cooler
	path = /obj/item/device/suit_cooling_unit/miniature/empty
