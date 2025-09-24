/singleton/psionic_faculty/metakinesis
	id = PSI_METAKINESIS
	name = "Metakinesis"
	associated_intent = I_GRAB
	armour_types = list("laser", "melee")

/singleton/psionic_power/metakinesis
	faculty = PSI_METAKINESIS
	use_manifest = TRUE
	abstract_type = /singleton/psionic_power/metakinesis

/singleton/psionic_power/metakinesis/element
	name =            "Manifest element"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на жёлтом интенте, чтобы воспользоваться одним из трёх стихийных элементов."
	admin_log = FALSE

	var/list/images = list()

	var/list/items_elements = list()
	var/list/paths_elements = list(/obj/item/psychic_power/psielectro,
		/obj/item/psychic_power/psifire,
		/obj/item/psychic_power/psiice)

/singleton/psionic_power/metakinesis/element/invoke(mob/living/user, mob/living/target)
	if((target && user != target) || user.a_intent != I_GRAB)
		return FALSE
	. = ..()
	if(.)

		for(var/element in paths_elements)
			var/obj/item/I = new element (src)
			items_elements += I
			var/image/img = image(icon = I.icon, icon_state = I.item_state)
			img.name = I.name
			images[I] = img

		var/obj/item = show_radial_menu(user, user, images, radius = 30, require_near = TRUE)
		if(item && !user.psi.suppressed)
			var/item_type = item.type
			. = new item_type(user)

		for(item in items_elements)
			qdel(item)

		images.Cut()
		items_elements.Cut()
