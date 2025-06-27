/obj/item/device/kit/mech
	name = "Mod - Mech customization kit"
	desc = "A kit containing all the needed tools and parts to repaint a mech."
	var/removable = null
	new_icon_file = 'icons/mecha/mech_decals.dmi'
	var/current_decal = "cammo2" //По умолчанию
	var/list/decals_chooses = list()
	var/list/mech_decales = list(
		"flames_red",
		"flames_blue",
		"cammo2",
		"cammo1",
		"clear decales"
	)

/obj/item/device/kit/mech/Initialize()
	. = ..()
	for(var/decal in mech_decales)
		LAZYADD(decals_chooses, mech_decales = mutable_appearance(new_icon_file, mech_decales))


/obj/item/device/kit/mech/attack_self(mob/user)//Тыкаем по самому киту дабы вызвать список того, какую декаль хотим на меха
	choose_decal(user)

/obj/item/device/kit/mech/proc/choose_decal(user)
	var/choice = show_radial_menu(user, src, decals_chooses, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choice)
		return
	change_decal(choice, usr)



/obj/item/device/kit/mech/proc/change_decal(new_decal, mob/user)
	current_decal = new_decal
	new_name = new_decal
	to_chat(user, SPAN_NOTICE("You set \the [src] to customize with [new_decal]."))
	playsound(src, 'sound/weapons/flipblade.ogg', 30, 1)



/singleton/hierarchy/supply_pack/nonessent/mech_kit
	num_contained = 1
	name = "Mech castomisation kit"
	contains = list(/obj/item/device/kit/mech)
	cost = 50
	containername = "heavy mech modkit crate"
