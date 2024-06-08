/obj/item/device/kit/mech
	name = "Mod - Exosuit customization kit"
	desc = "A kit containing all the needed tools and parts to repaint a exosuit."
	var/removable = null
	new_icon_file = 'icons/mecha/mech_decals.dmi'
	var/current_decal = "cammo2" //По умолчанию
	var/list/mech_decales = list(
		"flames_red",
		"flames_blue",
		"cammo2",
		"cammo1",
	)



/obj/item/device/kit/mech/attack_self(mob/user)//Тыкаем по самому киту дабы вызвать список того, какую декаль хотим на меха
	choose_decal(user)



/obj/item/device/kit/mech/examine(mob/user)
	. = ..()
	to_chat(user, "This kit will add a '[new_name]' decal to a exosuit'.")



/obj/item/device/kit/mech/proc/choose_decal(mob/user)
	set name = "Choose decal"
	set desc = "Choose mech decal."
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return
	var/new_decal = input(usr, "Choose a decal.", name, current_decal) as null|anything in mech_decales
	if (usr.incapacitated())
		return
	change_decal(new_decal, usr)



/obj/item/device/kit/mech/proc/change_decal(new_decal, mob/user)
	current_decal = new_decal
	new_name = new_decal
	to_chat(user, SPAN_NOTICE("You set \the [src] to customize with [new_decal]."))
	playsound(src, 'sound/weapons/flipblade.ogg', 30, 1)



/singleton/hierarchy/supply_pack/nonessent/mech_kit
	num_contained = 1
	name = "mech_castomizator"
	contains = list(/obj/item/device/kit/mech)
	cost = 50
	containername = "heavy exosuit modkit crate"
