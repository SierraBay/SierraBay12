/obj/item/device/kit/mech
	name = "Mod - Mech customization kit"
	desc = "A kit containing all the needed tools and parts to repaint a mech."
	var/removable = null
	var/current_decal = "cammo2" //По умолчанию
	var/list/decals_chooses = list()
	var/list/mech_decales = list(
		"clear_decales",
		"flames_red",
		"flames_blue",
		"cammo2",
		"cammo1"
	)

/obj/item/device/kit/mech/Initialize()
	. = ..()
	for(var/decal in mech_decales)
		decals_chooses[decal] = mutable_appearance('mods/mechs_by_shegar/icons/mech_decals_32.dmi', decal)


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
