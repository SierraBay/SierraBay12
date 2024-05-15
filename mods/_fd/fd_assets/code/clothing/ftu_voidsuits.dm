// ��������� ���������� ��������� �����

/obj/item/clothing/head/helmet/space/void/ftu_salvager
	name = "old-ass voidsuit helmet"
	desc = "Old space helmet model, designed for work in dangerous environment, where you will get hit with different things"
	icon_state = "rig0-ftu"
	item_state = "rig0-ftu"
	icon = 'mods/_fd/fd_assets/icons/obj/clothing_head.dmi'
	icon_override = 'mods/_fd/fd_assets/icons/onmob/clothing_head.dmi'
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_BIO_SHIELDED
		)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN,SPECIES_IPC)
	light_overlay = "explorer_light"

/obj/item/clothing/suit/space/void/ftu_salvager
	icon_state = "rig-ftu"
	icon = 'mods/_fd/fd_assets/icons/obj/clothing_suit.dmi'
	name = "old-ass green voidsuit"
	desc = "Old space suit model, designed for work in dangerous environment, where you will get hit with different things"
	item_state_slots = list(
		slot_l_hand_str = "syndicate-green-dark",
		slot_r_hand_str = "syndicate-green-dark",
	)
	w_class = ITEM_SIZE_LARGE //normally voidsuits are bulky but the merc voidsuit is 'advanced' or something
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_BIO_SHIELDED
		)
	allowed = list(/obj/item/device/flashlight,/obj/item/tank,/obj/item/device/suit_cooling_unit,/obj/item/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword,/obj/item/handcuffs)
	siemens_coefficient = 0.3
	species_restricted = list(SPECIES_HUMAN,SPECIES_IPC)

/obj/item/clothing/suit/space/void/ftu_salvager/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/ftu_salvager
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen

/obj/machinery/suit_storage_unit/ftu
	name = "Salvage Voidsuit Storage Unit"
	suit= /obj/item/clothing/suit/space/void/ftu_salvager
	helmet = /obj/item/clothing/head/helmet/space/void/ftu_salvager
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/tank/oxygen
	mask = /obj/item/clothing/mask/breath
	islocked = FALSE
