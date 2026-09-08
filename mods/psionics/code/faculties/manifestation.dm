/singleton/psionic_faculty/manifestation
	id = PSI_MANIFESTATION
	name = "Manifestation"
	associated_intent = I_GRAB
	armour_types = list("bullet", "melee")

/singleton/psionic_power/manifestation
	faculty = PSI_MANIFESTATION
	use_manifest = TRUE
	use_sound = null
	abstract_type = /singleton/psionic_power/manifestation

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

/singleton/psionic_power/manifestation/tinker
	name =            "Manifest tool"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на зелёном интенте, чтобы создать ряд полезных инструментов."
	admin_log = FALSE
	var/list/images = list()

	var/list/items_medical = list()
	var/list/paths_medical = list(/obj/item/bonesetter/psi,
		/obj/item/circular_saw/psi,
		/obj/item/hemostat/psi,
		/obj/item/retractor/psi,
		/obj/item/scalpel/psi,
		/obj/item/surgicaldrill/psi)

	var/list/items_engineering = list()
	var/list/paths_engineering = list(/obj/item/crowbar/psi,
		/obj/item/screwdriver/psi,
		/obj/item/wirecutters/psi,
		/obj/item/wrench/psi)

/singleton/psionic_power/manifestation/tinker/invoke(mob/living/user, mob/living/target)
	if((target && user != target) || user.a_intent != I_HELP)
		return FALSE

	var/fire_rank = user.psi.get_rank(PSI_METAKINESIS)
	var/demi_rank = user.psi.get_rank(PSI_MANIFESTATION)

	if(demi_rank >= PSI_RANK_MASTER)
		paths_medical += /obj/item/clothing/gloves/latex/psi
		paths_engineering += /obj/item/clothing/gloves/insulated/psi

	if(fire_rank >= PSI_RANK_LATENT && demi_rank >= PSI_RANK_OPERANT && user.skill_check(SKILL_CONSTRUCTION, SKILL_TRAINED))
		paths_engineering += /obj/item/weldingtool/experimental/psi

	if(demi_rank >= PSI_RANK_MASTER && user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC) && user.skill_check(SKILL_DEVICES, SKILL_TRAINED))
		paths_engineering += /obj/item/device/multitool/psi

	. = ..()
	if(.)

		var/option = alert(target, "What toolkit you need?", "Choose something!", "Medical", "Engineering")
		if (!option)
			return

		if(user.psi.suppressed)
			return

		if(option == "Engineering")
			for(var/engietool in paths_engineering)
				var/obj/item/I = new engietool (src)
				items_engineering += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		if(option == "Medical")
			for(var/medtool in paths_medical)
				var/obj/item/I = new medtool (src)
				items_medical += I
				var/image/img = image(icon = I.icon, icon_state = I.item_state)
				img.name = I.name
				images[I] = img

		var/obj/item = show_radial_menu(user, user, images, radius = 30, require_near = TRUE)
		if(item && !user.psi.suppressed)
			var/item_type = item.type
			. = new item_type(user)

		for(item in items_medical + items_engineering)
			qdel(item)

		images.Cut()
		items_medical.Cut()
		items_engineering.Cut()

		paths_medical -= /obj/item/clothing/gloves/latex/psi

		paths_engineering -= /obj/item/device/multitool/psi
		paths_engineering -= /obj/item/weldingtool/experimental/psi
		paths_engineering -= /obj/item/clothing/gloves/insulated/psi
