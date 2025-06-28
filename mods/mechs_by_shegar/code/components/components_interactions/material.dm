/obj/item/mech_component/proc/material_interaction(obj/item/stack/material/input_material, mob/user)
	if(current_hp > max_repair)
		to_chat(user, "Ремонт не требуется.")
		return
	var/user_undertand = FALSE // <-Персонаж пытающийся провернуть ремонт что-то смыслит в мехах для ремонта.
	if(user.skill_check(SKILL_DEVICES , SKILL_TRAINED) && user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
		user_undertand = TRUE // <- Мы даём пользователю больше информации, разрешаем проводить ремонт
	if(req_material != input_material.default_type)
		if(user_undertand)
			to_chat(user, "Данный материал не подойдёт, потребуется: [req_material]")
			return
		else
			to_chat(user, "Понятия не имею что делать дальше.")
			return
	material_repair(null, input_material, user, user_undertand, src)
