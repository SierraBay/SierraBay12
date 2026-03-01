/obj/item/cell/ancient_cell
	name = "Ancient cell."
	desc = "Ancient battery of unknown design."
	icon = 'icons/mob/human_races/species/adherent/organs.dmi'
	icon_state = "cell"
	origin_tech =  null
	maxcharge = 9000
	matter = list(MATERIAL_STEEL = 700, MATERIAL_GLASS = 80, MATERIAL_ALUMINIUM = 20)

/obj/item/cell/infinite/check_charge()
	return 0
