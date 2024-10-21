/obj/item/mech_component
	///
	///Отвечает за минимальное возможное ХП части меха, ОБЯЗАТЕЛЬНО прописывайте этот пункт. При ремонте повреждений
	///листом материала максимальное ХП части меха уменьшается, min_damage является минимальным пределом до куда будет
	///снижаться макс ХП меха.
	///
	var/min_damage = 5


	///
	///Отвечает за ТЕКУЩУЮ структурную целостность части, вычисляется по max_damage - ( brute_damage + burn_damage)
	///
	var/current_hp





													///РЕМОНТ И ОБСЛУЖИВАНИЕ///

	///
	/// Отвечает за то на сколько снижается максимальное хп части после ремонта. Обратите внимание, что макс хп падает
	///лишь при ремонте листами материала.
	///
	var/repair_damage = 5



	///
	///Отвечает за максимальное число урона, при котором не потребуется ремонт листами матеиала, можно обойтись сваркой.
	///Если количество ХП ниже этого значения - ремонт лишь листами.
	///
	var/max_repair = 5


	///
	///Отвечает за то какой материал требуется для ремонта данной части листами. Проверяется переменная при клику листами по
	///меху.
	///
	var/req_material = MATERIAL_STEEL


	///Содержит в себе значение НЕЧИНИБЕЛЬНОГО урона что скопился в части.
	var/unrepairable_damage = 0

	///Обозначает вес компонента в КИЛОГРАММАХ
	var/weight = 100

													///КОНЕЦ///





													///МОДИФИКАТОРЫ УРОНОВ///

	///
	///Модификатор урона по части, когда она принимает урон лицевой стороной
	///
	var/front_modificator_damage = 1

	///
	///Модификатор урона по части, когда она принимает урон задней стороной
	///
	var/back_modificator_damage = 1



	///
	///Гарантированный дополнительный урон, когда часть принимает урон лицевой стороной
	///
	var/front_additional_damage = 0

	///
	///Гарантированный дополнительный урон, когда часть принимает урон задней стороной
	///
	var/back_additional_damage = 0

													///КОНЕЦ///






													///ТЕПЛО///

	///
	///Максимальное тепло, которое может хранить в себе часть меха.
	///
	var/max_heat = 100
	///
	///Количество тепла, которое сбрасывает данная часть
	///
	var/heat_cooling = 5
	///
	///Количество тепла, которое вырабатывает данная часть при использовании
	///
	var/heat_generation = 5
	///
	///Количество тепла, выделяемое при ЭМИ ударе
	///
	var/emp_heat_generation = 50
													///КОНЕЦ///




/obj/item/mech_component/Initialize()
	current_hp = max_damage
	. = ..()

/obj/item/mech_component/proc/emp_heat(severity, emp_armor, mob/living/exosuit/mech) //Накидываем тепло учитывая армор меха
	if(emp_armor > 0.8)
		emp_armor = 0.8
	mech.add_heat(emp_heat_generation * (1 - emp_armor))

/obj/item/mech_component/use_tool(obj/item/tool, mob/user, list/click_params)
	//Ткнули сваркой
	if (isWelder(tool))
		if(current_hp == max_repair || current_hp < max_repair)
			USE_FEEDBACK_FAILURE("\The [src]'s [name] is too damaged and requires repair with material.")
			return TRUE
	//Ткнули листом материала
	else if(istype(tool, /obj/item/stack/material))
		if(current_hp > max_repair)
			to_chat(user, "This part does not require repair.")
			return
		var/obj/item/stack/material/material_sheet = tool
		var/user_undertand = FALSE // <-Персонаж пытающийся провернуть ремонт что-то смыслит в мехах для ремонта.
		if(user.skill_check(SKILL_DEVICES , SKILL_TRAINED) && user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
			user_undertand = TRUE // <- Мы даём пользователю больше информации, разрешаем проводить ремонт
		if(req_material != material_sheet.default_type)
			if(user_undertand)
				to_chat(user, "My experience tells me that this material is not suitable for repairs this part. I need [req_material]")
				return
			else
				to_chat(user, "I don’t know anything about bellows repair, I stand there and look at him like an idiot.")
				return
		material_repair(null, material_sheet, user, user_undertand, src)
	.=..()
