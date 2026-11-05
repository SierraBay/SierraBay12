/singleton/psionic_power/manifestation/psiblade
	name =            "Manifest weapon"
	cost =            5
	cooldown =        50
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на красном интенте, чтобы создать оружие из чистой псионической энергии."
	admin_log = FALSE

	var/list/images = list()

	var/list/items_lvl1 = list()
	var/list/paths_lvl1 = list(
								/obj/item/psychic_power/psiclub,
								/obj/item/psychic_power/psiblade)

	var/list/items_lvl2 = list()
	var/list/paths_lvl2 = list(
								/obj/item/psychic_power/psiclub/master,
								/obj/item/psychic_power/psiblade/master,
								/obj/item/psychic_power/psiaxe,
								/obj/item/psychic_power/psispear)

	var/list/items_lvl3 = list()
	var/list/paths_lvl3 = list(
								/obj/item/psychic_power/psiclub/master/grand,
								/obj/item/psychic_power/psiblade/master/grand,
								/obj/item/psychic_power/psiaxe/master,
								/obj/item/psychic_power/psispear/master,
								/obj/item/gun/launcher/crossbow/psibow/master)

	var/list/items_lvl4 = list()
	var/list/paths_lvl4 = list(
								/obj/item/psychic_power/psiclub/master/grand/paramount,
								/obj/item/psychic_power/psiblade/master/grand/paramount,
								/obj/item/psychic_power/psiaxe/master/grand/paramount,
								/obj/item/psychic_power/psispear/master/grand/paramount,
								/obj/item/gun/launcher/crossbow/psibow/master/grand/paramount)

/singleton/psionic_power/manifestation/psiblade/invoke(mob/living/user, mob/living/target)
	if((target && user != target) || user.a_intent != I_HURT)
		return FALSE

	var/demi_rank = user.psi.get_rank(PSI_MANIFESTATION)

	. = ..()
	if(.)

		if(demi_rank <= PSI_RANK_APPRENTICE)
			for(var/weapon1 in paths_lvl1)
				var/obj/item/I = new weapon1 (src)
				items_lvl1 += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		if(demi_rank == PSI_RANK_OPERANT)
			for(var/weapon2 in paths_lvl2)
				var/obj/item/I = new weapon2 (src)
				items_lvl2 += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		if(demi_rank == PSI_RANK_MASTER)
			for(var/weapon3 in paths_lvl3)
				var/obj/item/I = new weapon3 (src)
				items_lvl3 += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		if(demi_rank >= PSI_RANK_GRANDMASTER)
			for(var/weapon4 in paths_lvl4)
				var/obj/item/I = new weapon4 (src)
				items_lvl4 += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		var/obj/item = show_radial_menu(user, user, images, radius = 30, require_near = TRUE)
		if(item && !user.psi.suppressed)
			var/item_type = item.type
			. = new item_type(user)

		for(item in items_lvl1 + items_lvl2 + items_lvl3 + items_lvl4)
			qdel(item)

		images.Cut()
		items_lvl1.Cut()
		items_lvl2.Cut()
		items_lvl3.Cut()
		items_lvl4.Cut()
