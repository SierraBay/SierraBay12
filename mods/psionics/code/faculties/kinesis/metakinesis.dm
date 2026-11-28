/singleton/psionic_power/kinesis/metakinesis/cryokinesis
	name =            "Криокинез"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на жёлтом интенте, чтобы воспользоваться одним из трёх элементов."
	admin_log = FALSE

/singleton/psionic_power/kinesis/metakinesis/electrokinesis
	name =            "Электрокинез"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на жёлтом интенте, чтобы воспользоваться одним из трёх элементов."
	admin_log = FALSE

/singleton/psionic_power/kinesis/metakinesis/pyrokinesis
	name =            "Пирокинез"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_APPRENTICE
	use_description = "Нажмите по пустой руке на жёлтом интенте, чтобы воспользоваться одним из трёх элементов."
	admin_log = FALSE

/singleton/psionic_power/kinesis/metakinesis
	var/list/images = list()

	var/list/items_elements = list()
	var/list/abilities = list(
		/singleton/psionic_power/kinesis/metakinesis/pyrokinesis = /obj/item/psychic_power/psifire,
		/singleton/psionic_power/kinesis/metakinesis/cryokinesis = /obj/item/psychic_power/psiice,
		/singleton/psionic_power/kinesis/metakinesis/electrokinesis = /obj/item/psychic_power/psielectro
		)

/singleton/psionic_power/kinesis/metakinesis/invoke(mob/living/user, mob/living/target)
	if((target && user != target) || user.a_intent != I_GRAB)
		return FALSE
	. = ..()
	if(.)
		for(var/element in abilities)
			if(user.psi.has_power(element))
				var/result = abilities[element]
				var/obj/item/I = new result(src)
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
