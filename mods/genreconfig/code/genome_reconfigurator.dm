/obj/item/reagent_containers/syringe/genome_reconfigurator
	name = "genome reconfigurator"
	desc = "Маленькое устройство с тонким шприцем, тремя лампочками и пространством для жидкости внутри."
	icon = 'mods/genreconfig/icons/obj/genomereconfigurator.dmi'
	icon_state = "GR1"
	item_state = "" // невидимое в руках
	volume = 1
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = "1"
	mode = SYRINGE_DRAW
	time = 90
	visible_name = "a genome reconfigurator"
	origin_tech = list(TECH_BIO = 5, TECH_ENGINEERING = 5, TECH_ILLEGAL = 5)
	matter = list(MATERIAL_GLASS = 100, MATERIAL_STEEL = 50, MATERIAL_PLASTIC = 75, MATERIAL_GOLD = 25)

	var/donor_name = null
	var/donor_species = null
	var/donor_gender = null
	var/datum/dna/donor_dna = null
	var/datum/pronouns/donor_pronouns
	var/list/donor_flavor_texts
	var/list/donor_icon_render_keys
	var/list/donor_descriptors
	var/has_donor_data = FALSE
	var/used_for_transformation = FALSE
	var/is_storing_data = FALSE
	var/is_analyzing = FALSE
	var/is_injecting = FALSE
	var/blink_state = FALSE
	var/suit_injection_time = 120

/obj/item/reagent_containers/syringe/genome_reconfigurator/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/genome_reconfigurator/Destroy()
	return ..()

/obj/item/reagent_containers/syringe/genome_reconfigurator/drawReagents(atom/target, mob/user)
	if(used_for_transformation)
		to_chat(user, SPAN_WARNING("Этот реконфигуратор генома уже использовался для трансформации и опустошил свой запас."))
		return

	if(!reagents.get_free_space())
		to_chat(user, SPAN_WARNING("В реконфигураторе генома уже есть материал."))
		mode = SYRINGE_INJECT
		return

	if(ismob(target))
		if(reagents.has_reagent(/datum/reagent/blood))
			to_chat(user, SPAN_WARNING("В реконфигураторе генома уже есть материал."))
			return
		if(istype(target, /mob/living/carbon))
			if(istype(target, /mob/living/carbon/slime))
				to_chat(user, SPAN_WARNING("Реконфигуратор генома не смог получить генетический материал."))
				return
			var/amount = min(reagents.get_free_space(), amount_per_transfer_from_this)
			var/mob/living/carbon/T = target
			if(!T.dna)
				to_chat(user, SPAN_WARNING("Реконфигуратор генома не смог получить генетический материал."))
				if(istype(target, /mob/living/carbon/human))
					error("[T] \[[T.type]\] отсутствует dna datum")
				return

			var/allow = T.can_inject(user, check_zone(user.zone_sel.selecting))
			if(!allow)
				to_chat(user, SPAN_WARNING("Не удалось воткнуть шприц, он отскочил от чего-то."))
				return

			if(allow == INJECTION_PORT)
				if(target != user)
					user.visible_message(SPAN_DANGER("\The [user] begins hunting for an injection port on \the [target]'s suit!"))
				else
					to_chat(user, SPAN_NOTICE("You begin hunting for an injection port on your suit."))
				if(!user.do_skilled(INJECTION_PORT_DELAY, SKILL_MEDICAL, target, do_flags = DO_MEDICAL))
					return

				if (!reagents)
					return

			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)

			// Поддерживаемые расы
			var/list/supported_species = list(
				SPECIES_HUMAN,
				SPECIES_UNATHI,
				SPECIES_SKRELL,
				SPECIES_TAJARA,
				SPECIES_RESOMI,
				SPECIES_MONKEY,
				SPECIES_FARWA,
				SPECIES_YEOSA,
				SPECIES_VATGROWN,
				SPECIES_SPACER,
				SPECIES_GRAVWORLDER,
				SPECIES_MULE,
				SPECIES_TRITONIAN
			)

			if(!(T.species.name in supported_species))
				to_chat(user, SPAN_WARNING("Реконфигуратор генома не может работать с этим видом. Попробуйте с другим донором."))
				return

			reagents.clear_reagents()
			is_storing_data = TRUE
			clear_donor_data()

			if (!reagents)
				return

			T.take_blood(src, amount)
			to_chat(user, SPAN_NOTICE("Вы незаметно извлекаете генетический образец из [target]."))

			store_donor_data(T)

			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.custom_pain(SPAN_WARNING("You feel a tiny prick!"), 1, TRUE, H.get_organ(user.zone_sel.selecting))

			addtimer(new Callback(src, PROC_REF(set_storing_data_false)), 5)

	else
		to_chat(user, SPAN_WARNING("Реконфигуратор генома предназначен только для сбора генетического материала у живых существ."))
		return

	if(!reagents.get_free_space())
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/store_donor_data(mob/living/carbon/donor)
	if(!donor || !donor.dna)
		return

	is_storing_data = TRUE
	is_analyzing = TRUE

	donor_name = donor.real_name
	donor_species = donor.species.name
	donor_gender = donor.gender
	donor_dna = donor.dna.Clone()
	donor_pronouns = donor.pronouns

	if(ishuman(donor))
		var/mob/living/carbon/human/H = donor
		donor_flavor_texts = H.flavor_texts ? H.flavor_texts.Copy() : null
		donor_icon_render_keys = H.icon_render_keys ? H.icon_render_keys.Copy() : null
		donor_descriptors = H.descriptors ? H.descriptors.Copy() : null

	var/mob/user = get_holder_of_type(src, /mob)
	if(user)
		to_chat(user, SPAN_NOTICE("Генетический образец собран. Анализ последовательности ДНК..."))

	start_blinking()
	addtimer(new Callback(src, PROC_REF(finish_analysis)), 320)

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/finish_analysis()
	is_analyzing = FALSE
	has_donor_data = TRUE
	blink_state = FALSE

	var/mob/living/carbon/human/user = get_holder_of_type(src, /mob/living/carbon/human)
	if(user)
		var/list/user_contents = user.get_contents()
		var/list/user_held = user.GetAllHeld()
		if((user_contents && (src in user_contents)) || (user_held && (src in user_held)))
			to_chat(user, SPAN_NOTICE("Анализ последовательности ДНК завершен. Материал готов к инъекции."))

	update_icon()

	addtimer(new Callback(src, PROC_REF(finish_storage)), 5)

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/finish_storage()
	is_storing_data = FALSE

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/set_storing_data_false()
	is_storing_data = FALSE

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/check_and_clear_donor_data()
	if(reagents.get_reagent_amount(/datum/reagent/blood) <= 0 && has_donor_data && !used_for_transformation && !is_storing_data && !is_analyzing)
		clear_donor_data()

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/clear_donor_data()
	donor_name = null
	donor_species = null
	donor_gender = null
	donor_dna = null
	donor_pronouns = null
	donor_flavor_texts = null
	donor_icon_render_keys = null
	donor_descriptors = null
	has_donor_data = FALSE
	is_storing_data = FALSE
	is_analyzing = FALSE
	is_injecting = FALSE
	blink_state = FALSE

/obj/item/reagent_containers/syringe/genome_reconfigurator/on_reagent_change()
	. = ..()

	if(reagents.get_reagent_amount(/datum/reagent/blood) <= 0 && has_donor_data && !used_for_transformation && !is_storing_data && !is_analyzing)
		addtimer(new Callback(src, PROC_REF(check_and_clear_donor_data)), 3)

	// Я сделал спрайт слишком большим и на полу он выглядит нелепо, поэтому я таким образом уменьшаю спрайт когда он лежит где-то.
/obj/item/reagent_containers/syringe/genome_reconfigurator/on_update_icon()
	ClearOverlays()
	underlays.Cut()
	alpha = 255
	transform = matrix()

	if(isturf(loc))
		transform = matrix(0.66, 0.66, MATRIX_SCALE)
		return


	if(mode == SYRINGE_BROKEN || used_for_transformation)
		icon_state = "GR4"
		return

	if(is_analyzing)
		icon_state = blink_state ? "GR5" : "GR2"
		return

	if(has_donor_data && !is_analyzing)
		icon_state = "GR3"
		return

	icon_state = "GR1"

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/start_blinking()
	if(!is_analyzing)
		return

	blink_state = !blink_state
	update_icon()

	if(is_analyzing)
		addtimer(new Callback(src, PROC_REF(start_blinking)), 5)

/obj/item/reagent_containers/syringe/genome_reconfigurator/injectReagents(atom/target, mob/user)
	if(used_for_transformation)
		to_chat(user, SPAN_WARNING("Этот реконфигуратор генома уже использовался для трансформации и больше не функционирует."))
		return

	if(is_injecting)
		to_chat(user, SPAN_WARNING("Инъекция уже в процессе."))
		return

	if(ismob(target))
		if(is_analyzing)
			to_chat(user, SPAN_WARNING("Анализ последовательности ДНК в процессе. Пожалуйста, дождитесь завершения анализа."))
			return

		if(!has_donor_data)
			to_chat(user, SPAN_WARNING("Геномный реконфигуратор пустой, переключите режим."))
			return

		var/mob/living/carbon/human/T = target
		if(!istype(T))
			to_chat(user, SPAN_WARNING("Это устройство может трансформировать только гуманоидных существ."))
			return

		if(T.isSynthetic())
			to_chat(user, SPAN_WARNING("Это устройство не может трансформировать синтетических существ."))
			return

		if(MUTATION_HUSK in T.mutations)
			to_chat(user, SPAN_WARNING("ДНК этого существа испорчена до такой степени, что его невозможно использовать!"))
			return

		is_injecting = TRUE
		injectMob(T, user)
		return

	return ..()

/obj/item/reagent_containers/syringe/genome_reconfigurator/injectMob(mob/living/carbon/target, mob/living/carbon/user, atom/trackTarget)
	if(!trackTarget)
		trackTarget = target

	var/allow = target.can_inject(user, check_zone(user.zone_sel.selecting))
	if(!allow)
		is_injecting = FALSE
		return

	if(allow == INJECTION_PORT)
		if(target != user)
			user.visible_message(SPAN_DANGER("\The [user] begins hunting for an injection port on \the [target]'s suit!"))
		else
			to_chat(user, SPAN_NOTICE("You begin hunting for an injection port on your suit."))
		if(!user.do_skilled(INJECTION_PORT_DELAY, SKILL_MEDICAL, trackTarget, do_flags = DO_MEDICAL))
			is_injecting = FALSE
			return

	if(target != user)
		user.visible_message(SPAN_DANGER("\The [user] is trying to inject \the [target] with [visible_name]!"))
	else
		to_chat(user, SPAN_NOTICE("You begin injecting yourself with [visible_name]."))

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(trackTarget)

	var/injection_time = (allow == INJECTION_PORT) ? suit_injection_time : time

	if(!user.do_skilled(injection_time, SKILL_MEDICAL, trackTarget, do_flags = DO_MEDICAL))
		is_injecting = FALSE
		return

	if(target != user && target != trackTarget && target.loc != trackTarget)
		is_injecting = FALSE
		return


	perform_transformation(target, user)

	used_for_transformation = TRUE
	reagents.clear_reagents()
	mode = SYRINGE_DRAW
	update_icon()

	if(target != user)
		user.visible_message(SPAN_DANGER("\the [user] injects \the [target] with [visible_name]!"), SPAN_NOTICE("You inject \the [target] with [visible_name]."))
	else
		to_chat(user, SPAN_NOTICE("You inject yourself with [visible_name]."))

	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		T.custom_pain(SPAN_WARNING("The needle stings a bit."), 2, TRUE, T.get_organ(user.zone_sel.selecting))

	is_injecting = FALSE

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/perform_transformation(mob/living/carbon/target, mob/user)
	if(!has_donor_data || !donor_dna)
		return

	if(!target || !istype(target, /mob/living/carbon/human))
		return

	target.visible_message(SPAN_WARNING("[target] начинает меняться, а тело обретает другие черты!"))
	to_chat(target, SPAN_DANGER("Ты чувствуешь боль по всему телу, а каждая твоя клеточка видоизменяется!"))

	if(ishuman(target))
		var/mob/living/carbon/human/H = target

		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		if(chest && !chest.is_stump())
			chest.add_pain(50)
			to_chat(H, SPAN_DANGER("Твоя грудь горит от невыносимой боли!"))

		H.sleeping = 20

	addtimer(new Callback(src, PROC_REF(complete_transformation), target, user), 150)

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/get_pain_message(body_part, pain_level)
	switch(body_part)
		if("head")
			return SPAN_DANGER("Твоя голова пульсирует от невыносимой боли!")
		if("chest")
			return SPAN_DANGER("Ты чувствуешь невыносимую боль в груди!")
		if("groin")
			return SPAN_DANGER("Боль пронзает твою нижнюю часть тела!")
		if("l_arm")
			return SPAN_DANGER("Твоя левая рука дрожит от боли!")
		if("r_arm")
			return SPAN_DANGER("Твоя правая рука дрожит от боли!")
		if("l_leg")
			return SPAN_DANGER("Твоя левая нога пронзена болью!")
		if("r_leg")
			return SPAN_DANGER("Твоя правая нога пронзена болью!")
		else
			return SPAN_DANGER("Ты чувствуешь сильную боль!")

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/complete_transformation(mob/living/carbon/target, mob/user)
	if(!has_donor_data || !donor_dna)
		return

	if(!target || !istype(target, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = target

	if(!H || H.stat == DEAD)
		return

	var/singleton/species/old_species = H.species
	var/singleton/species/new_species = GLOB.species_by_name[donor_species]
	if(new_species && H.species != new_species)
		// Здесь пытаюсь изменить расу, при этом оставляя протезы, языки и т.д на местах
		H.species.remove_base_auras(H)
		H.species.remove_inherent_verbs(H)
		LAZYINITLIST(H.traits)
		H.traits -= H.species.traits
		H.species = new_species
		H.species.handle_pre_spawn(H)
		H.traits |= H.species.traits
		H.species.handle_post_spawn(H)
		H.holder_type = H.species.holder_type
		H.current_grab_type = all_grabobjects[H.species.grab_type]
		H.icon_state = lowertext(H.species.name)
		H.mob_size = H.species.mob_size
		H.maxHealth = H.species.total_health
		H.available_maneuvers = H.species.maneuvers.Copy()
		remove_extension(H, /datum/extension/armor)
		if(H.species.natural_armour_values)
			set_extension(H, /datum/extension/armor, H.species.natural_armour_values)

		H.default_pixel_x = initial(H.pixel_x) + H.species.pixel_offset_x
		H.default_pixel_y = initial(H.pixel_y) + H.species.pixel_offset_y
		H.default_pixel_z = initial(H.pixel_z) + H.species.pixel_offset_z
		H.pixel_x = H.default_pixel_x
		H.pixel_y = H.default_pixel_y
		H.pixel_z = H.default_pixel_z
		H.meat_type = H.species.meat_type
		H.meat_amount = H.species.meat_amount
		H.skin_material = H.species.skin_material
		H.skin_amount = H.species.skin_amount
		H.bone_material = H.species.bone_material
		H.bone_amount = H.species.bone_amount

		H.default_walk_intent = null
		H.default_run_intent = null
		H.move_intent = null
		H.move_intents = H.species.move_intents.Copy()
		H.set_move_intent(GET_SINGLETON(H.move_intents[1]))
		if(!istype(H.move_intent))
			H.set_next_usable_move_intent()
		H.vessel.maximum_volume = H.species.blood_volume
		for(var/datum/reagent/blood/B in H.vessel.reagent_list)
			B.volume *= H.species.blood_volume / max(old_species.blood_volume, 1)
		H.vessel.update_total()
		if(H.client)
			H.Login()
		H.update_emotes()

	if(donor_dna)
		H.dna = donor_dna.Clone()
		H.b_type = H.dna.b_type
		H.base_skin = H.dna.base_skin
		for(var/datum/reagent/blood/B in H.vessel.reagent_list)
			if(B.type == /datum/reagent/blood)
				B.data["species"] = H.species.name
				B.data["blood_DNA"] = H.dna.unique_enzymes
				B.data["blood_type"] = H.dna.b_type
				B.data["blood_colour"] = H.species.get_blood_colour(H)
				B.color = B.data["blood_colour"]

	H.gender = donor_gender
	H.pronouns = donor_pronouns

	if(donor_flavor_texts && islist(donor_flavor_texts))
		H.flavor_texts = donor_flavor_texts.Copy()
	if(donor_descriptors && islist(donor_descriptors))
		H.descriptors = donor_descriptors.Copy()
	if(donor_icon_render_keys && islist(donor_icon_render_keys))
		H.icon_render_keys = donor_icon_render_keys.Copy()

	if(H.species != old_species)
		update_organs(H, old_species)
	H.sync_organ_dna()

	H.real_name = donor_name

	domutcheck(H, null)

	H.UpdateAppearance()

	var/list/pain_levels = list(
		BP_HEAD = 15,
		BP_CHEST = 15,
		BP_GROIN = 15,
		BP_L_ARM = 15,
		BP_R_ARM = 15,
		BP_L_LEG = 15,
		BP_R_LEG = 15
	)

	for(var/body_part in pain_levels)
		var/obj/item/organ/external/limb = H.get_organ(body_part)
		if(limb && !limb.is_stump())
			var/pain_level = pain_levels[body_part]
			var/pain_message = get_pain_message(limb.organ_tag, pain_level)

			limb.add_pain(pain_level)

			to_chat(H, pain_message)

	switch(donor_species)
		if(SPECIES_HUMAN)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком. Твоё тело ощущается знакомым и естественным, как будто ты всегда был таким."))
		if(SPECIES_UNATHI)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... прохладу. Твоё тело покрылось чешуйчатой кожей."))
		if(SPECIES_SKRELL)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... влажность и склизкость твоей кожи."))
		if(SPECIES_TAJARA)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... мягкость меха на коже."))
		if(SPECIES_RESOMI)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... лёгкость своего маленького тела. Твои конечности стали более гибкими."))
		if(SPECIES_MONKEY)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... грубость шерсти на своём маленьком теле."))
		if(SPECIES_FARWA)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... мягкость меха и остроту когтей. Твои чувства обострились."))
		if(SPECIES_YEOSA)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь... изящество стройного тела. Твоя чешуя тонкая и гладкая."))
		if(SPECIES_VATGROWN)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком, но странное ощущение искусственности как холодок прошло по тебе."))
		if(SPECIES_SPACER)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком, но твоя кожа бледная и полупрозрачная."))
		if(SPECIES_GRAVWORLDER)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком, но твоё тело будто стало тяжелее и прочнее."))
		if(SPECIES_MULE)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком, но ощущаешь хлипкость своего тела."))
		if(SPECIES_TRITONIAN)
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... человеком, но ощущаешь влажность кожи. Подводная среда кажется естественной."))
		else
			to_chat(target, SPAN_NOTICE("Ты чувствуешь себя... странно, тебе потребуется время чтобы привыкнуть к этому телу"))

	clear_donor_data()

/obj/item/reagent_containers/syringe/genome_reconfigurator/proc/update_organs(mob/living/carbon/human/H, singleton/species/old_species)
	for(var/organ_tag in (old_species.has_organ | H.species.has_organ))
		var/obj/item/organ/internal/old_organ = H.internal_organs_by_name[organ_tag]
		// Оставляю протезы и аугменты
		if(old_organ && (BP_IS_ROBOTIC(old_organ) || BP_IS_ASSISTED(old_organ) || istype(old_organ, /obj/item/organ/internal/augment)))
			continue
		if(!old_organ && (organ_tag in old_species.has_organ))
			continue
		var/obj/item/organ/internal/organ_type = H.species.has_organ[organ_tag]
		if(!organ_type)
			qdel(old_organ)
			continue
		if(!H.get_organ(initial(organ_type.parent_organ)))
			continue

		if(istype(old_organ, /obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/brain = old_organ
			var/health_scale = H.species.total_health / old_species.total_health
			brain.set_max_damage(brain.max_damage * health_scale)
			brain.damage *= health_scale
		if(istype(old_organ, /obj/item/organ/internal/lungs))
			var/obj/item/organ/internal/lungs/lungs = old_organ
			lungs.oxygen_deprivation *= H.species.total_health / old_species.total_health
		if(istype(old_organ, /obj/item/organ/internal/eyes))
			var/obj/item/organ/internal/eyes/eyes = old_organ
			eyes.flash_mod = H.species.flash_mod
			eyes.darksight_range = H.species.darksight_range
			eyes.darksight_tint = H.species.darksight_tint
		if(old_organ && old_organ.type == organ_type)
			continue

		var/obj/item/organ/internal/new_organ = new organ_type(H)
		if(old_organ)
			new_organ.damage = old_organ.damage
			new_organ.status = old_organ.status
			new_organ.germ_level = old_organ.germ_level
			new_organ.death_time = old_organ.death_time
			new_organ.rejecting = old_organ.rejecting
			if(istype(old_organ, /obj/item/organ/internal/lungs) && istype(new_organ, /obj/item/organ/internal/lungs))
				var/obj/item/organ/internal/lungs/old_lungs = old_organ
				var/obj/item/organ/internal/lungs/new_lungs = new_organ
				new_lungs.oxygen_deprivation = old_lungs.oxygen_deprivation
				new_lungs.active_breathing = old_lungs.active_breathing
			if(istype(old_organ, /obj/item/organ/internal/brain) && istype(new_organ, /obj/item/organ/internal/brain))
				var/obj/item/organ/internal/brain/old_brain = old_organ
				var/obj/item/organ/internal/brain/new_brain = new_organ
				new_brain.set_max_damage(old_brain.max_damage)
				new_brain.oxygen_reserve = old_brain.oxygen_reserve
				new_brain.healed_threshold = old_brain.healed_threshold
				new_brain.fake_brain = old_brain.fake_brain
				new_brain.brainmob = old_brain.brainmob
				old_brain.brainmob = null
			for(var/atom/movable/contained in old_organ.contents)
				contained.forceMove(new_organ)
			qdel(old_organ)
		new_organ.organ_tag = organ_tag
		H.internal_organs_by_name[organ_tag] = new_organ

/obj/item/reagent_containers/syringe/genome_reconfigurator/syringestab(mob/living/carbon/target, mob/living/carbon/user)
	if(used_for_transformation)
		to_chat(user, SPAN_WARNING("Этот реконфигуратор генома уже использовался для трансформации и опустошил свой запас."))
		return

	if(is_injecting)
		to_chat(user, SPAN_WARNING("Инъекция уже в процессе."))
		return

	if(is_analyzing)
		to_chat(user, SPAN_WARNING("Анализ последовательности ДНК в процессе."))
		return

	if(!target.can_inject(user, check_zone(user.zone_sel.selecting)))
		to_chat(user, SPAN_WARNING("Не удается получить доступ к генетическому материалу."))
		return

	if(!target || !target.dna)
		to_chat(user, SPAN_WARNING("Не удается получить генетический материал."))
		return

	if(has_donor_data && !is_analyzing)
		is_injecting = TRUE
		injectMob(target, user)
		return

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/target_zone = check_zone(user.zone_sel.selecting)
		var/obj/item/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting || affecting.is_stump())
			to_chat(user, SPAN_DANGER("They are missing that limb!"))
			return

		var/hit_area = affecting.name

		if((user != target) && H.check_shields(7, src, user, "\the [src]"))
			return

		if (target != user && H.get_blocked_ratio(target_zone, DAMAGE_BRUTE, damage_flags=DAMAGE_FLAG_SHARP) > 0.1 && prob(50))
			for(var/mob/O in viewers(world.view, user))
				O.show_message(SPAN_DANGER("[user] tries to stab [target] in \the [hit_area] with [src.name], but the attack is deflected by armor!"), 1)
			return

	var/syringestab_amount_transferred = 1
	var/trans = reagents.trans_to_mob(target, syringestab_amount_transferred, CHEM_BLOOD)
	if(isnull(trans)) trans = 0

	if(trans > 0 && target && target.dna)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			var/target_zone = check_zone(user.zone_sel.selecting)
			H.apply_damage(1, DAMAGE_BRUTE, target_zone, damage_flags=DAMAGE_FLAG_SHARP)
		else
			target.apply_damage(1, DAMAGE_BRUTE)

		store_donor_data(target)

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			to_chat(H, "<small><span class='warning'>You feel a tiny prick.</span></small>")

	update_icon()

/obj/item/reagent_containers/syringe/genome_reconfigurator/update_mod_identification()
	mod_skill_identification = list(
		"device_info" = list(
			"success" = SPAN_GOOD("Ваших знаний в области науки, медицины и сложных устройств достаточно, чтобы определить: это устройство для сбора, анализа и внедрения чужого генетического материала при помощи некого мутагенного вещества."),
			"failure" = SPAN_BAD("Необычное маленькое устройство, с тонким шприцем, лампочками и отсеком для жидкости. Назначение неясно без специальных знаний."),
			"skillcheck" = list(
				SKILL_MEDICAL = SKILL_EXPERIENCED,
				SKILL_DEVICES = SKILL_EXPERIENCED,
				SKILL_SCIENCE = SKILL_TRAINED
			),
			"LOGIC" = "AND"
		)
	)
