/singleton/psionic_power/redaction/retribute
	name =            "Retribute"
	cost =            1
	cooldown =        5 SECONDS
	use_grab =        TRUE
	min_rank =        PSI_RANK_MASTER
	use_description = "Выберите любую конечность тела на зелёном интенте и нажмите по цели, чтобы отрастить или удалить конечность жертвы."
	var/perevod = list(
		BP_HEAD = "голову",
		BP_CHEST = "грудь",
		BP_L_ARM = "левую руку",
		BP_R_ARM = "правую руку",
		BP_L_LEG = "левую ногу",
		BP_R_LEG = "правую ногу",
		BP_GROIN = "паховую область",
		BP_L_HAND = "левую кисть",
		BP_R_HAND = "правую кисть",
		BP_L_FOOT = "левую стопу",
		BP_R_FOOT = "правую стопу")

//UPDATED

/singleton/psionic_power/redaction/retribute/invoke(mob/living/user, mob/living/carbon/human/target)
	if(!isliving(target) || user.zone_sel.selecting == BP_CHEST)
		return
	var/obj/item/organ/external/E = target.get_organ(user.zone_sel.selecting)
	if(!istype(user) || !istype(target))
		return FALSE
	. = ..()
	if(.)
		if(!E)
			var/o_type = user.zone_sel.selecting
			var/what =  alert(user, "Вы уверены, что хотите поделится частью своей плоти?", "Жертвуй", "Да!", "Нет...")
			switch(what)
				if("Да!")
					if(do_after(user, 12 SECONDS))
						// new /obj/temporary(get_turf(target),8, 'icons/effects/effects.dmi', "pink_sparkles") -- Надо чёнить придумать
						var/list/missing_limbs = target.species.has_limbs - target.organs_by_name
						missing_limbs -= o_type
						var/limb_type = target.species.has_limbs[o_type]["path"]
						var/obj/item/organ/external/new_limb = new limb_type(target)
						new_limb.update_icon()
						E = target.get_organ(o_type)
						if(!user.skill_check(SKILL_ANATOMY, SKILL_TRAINED) || !user.skill_check(SKILL_MEDICAL, SKILL_BASIC))
							if(prob(50))
								to_chat(user, SPAN_WARNING("Я не знаю как правильно сформировать, [perevod[E.organ_tag]] мутировала!"))
								E.mutate()
						else
							if(prob(25))
								to_chat(user, SPAN_WARNING("Случилось невозможное, [perevod[E.organ_tag]] мутировала!"))
								E.mutate()
						user.apply_damage(20, DAMAGE_BRUTE, o_type)
						user.psi.spend_power(50)
						target.visible_message(SPAN_GOOD("Тело [target] отрастило новую [perevod[E.organ_tag]]!"), SPAN_GOOD("Вы снова ощущаете свою [perevod[E.organ_tag]]"))
						target.regenerate_icons()
					return TRUE
				else
					return TRUE
		else
			if(E.is_stump())
				if(do_after(user, 3 SECONDS))
					E.droplimb(0,DROPLIMB_BLUNT)
					target.agony_scream()
				return TRUE
			var/what =  alert(user, "Вы уверены, что хотите избавить жертву от конечности?", "Разделяй", "Да...", "Нет!")
			switch(what)
				if("Да...")
					for(var/obj/item/clothing/C in list(target.head, target.wear_mask, target.wear_suit, target.w_uniform, target.gloves, target.shoes))
						if(C && (C.body_parts_covered & E.body_part) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
							to_chat(user, SPAN_WARNING("Трудно ухватится за плоть, пока она закрыта толстой одеждой."))
							return TRUE
					target.visible_message(SPAN_DANGER("[user] тянет [perevod[E.organ_tag]] [target]."), SPAN_DANGER("Вы чувствуете как [user] тянет вашу [perevod[E.organ_tag]]!"))
					if(do_after(user, 15 SECONDS))
						E.droplimb(0,DROPLIMB_BLUNT)
						user.psi.spend_power(50)
					return TRUE
				else
					return TRUE
