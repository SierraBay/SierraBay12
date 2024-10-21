//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

/datum/objective
	//Who owns the objective.
	var/datum/mind/owner = null
	//What that person is supposed to do.
	var/explanation_text = "Nothing"
	//If they are focused on a particular person.
	var/datum/mind/target = null
	//If they are focused on a particular number. Steal objectives have their own counter.
	var/target_amount = 0

/datum/objective/New(text)
	all_objectives |= src
	if(text)
		explanation_text = text
	..()

/datum/objective/Destroy()
	all_objectives -= src
	..()

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD))
			possible_targets += possible_target
	if(length(possible_targets) > 0)
		target = pick(possible_targets)


/datum/objective/proc/find_target_by_role(role, role_type = 0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in SSticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
			target = possible_target
			break


// Assassinate //

/datum/objective/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Ликвидируйте [target.current.real_name], [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinate/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Ликвидируйте [target.current.real_name], [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

// Execute //

/datum/objective/anti_revolution/execute/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], [target.assigned_role] неавторизовано извлек конфиденциальную информацию. Ликвидируйте данную цель."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/execute/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], [!role_type ? target.assigned_role : target.special_role] неавторизовано извлек конфиденциальную информацию. Ликвидируйте данную цель."
	else
		explanation_text = "Free Objective"
	return target

// Brig //

/datum/objective/anti_revolution/brig
	var/already_completed = 0

/datum/objective/anti_revolution/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Посадите [target.current.real_name], [target.assigned_role] в камеру заключения на 20 минут или больше, чтобы преподать урок."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/brig/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Посадите [target.current.real_name], [!role_type ? target.assigned_role : target.special_role] в камеру заключения на 20 минут или больше, чтобы преподать урок."
	else
		explanation_text = "Free Objective"
	return target

// Demote //

/datum/objective/anti_revolution/demote/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], [target.assigned_role] был классифицирован как вредный для выполнения целей [GLOB.using_map.company_name]. Понизьте его до низшей должности"
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], [!role_type ? target.assigned_role : target.special_role] был классифицирован как вредный для выполнения целей [GLOB.using_map.company_name] Понизьте его до низшей должномти"
	else
		explanation_text = "Free Objective"
	return target

// Debrain //

/datum/objective/debrain/find_target()
	..()
	if(target && target.current)
		explanation_text = "Украдите мозг [target.current.real_name]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/debrain/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Украдите мозг [target.current.real_name], [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

// Protection, The opposite of killing a dude. //

/datum/objective/protect/find_target()
	..()
	if(target && target.current)
		explanation_text = "Защитите [target.current.real_name], [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/protect/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Защитите [target.current.real_name], [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

// Hijack //

/datum/objective/hijack
	explanation_text = "Угоните шаттл."

// Shuttle Escape //

/datum/objective/escape
	explanation_text = "Сбегите на шаттле или эвакуационном поде живым и несвязанным."

// Survive //

/datum/objective/survive
	explanation_text = "Выживите до окончания смены."

// Brig, similar to the anti-rev objective, but for traitors //

/datum/objective/brig
	var/already_completed = 0

/datum/objective/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Посадите [target.current.real_name], [target.assigned_role] в камеру заключения на 10 минут."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/brig/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Посадите [target.current.real_name], [!role_type ? target.assigned_role : target.special_role] в камеру заключения на 10 минут."
	else
		explanation_text = "Free Objective"
	return target

// Harm a crew member, making an example of them //

/datum/objective/harm
	var/already_completed = 0

/datum/objective/harm/find_target()
	..()
	if(target && target.current)
		explanation_text = "Преподайте урок [target.current.real_name], [target.assigned_role].Сломайте кость, отрубите конечность или изуродуйте лицо. Убедитесь, что цель переживет это."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/harm/find_target_by_role(role, role_type = 0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Преподайте урок [target.current.real_name], [!role_type ? target.assigned_role : target.special_role]. Сломайте кость, отрубите конечность или изуродуйте лицо. Убедитесь, что цель переживет это."
	else
		explanation_text = "Free Objective"
	return target

// Nuclear Explosion //

/datum/objective/nuclear
	explanation_text = "Уничтожьте судно с помощью устройства самоуничтожения"


// Steal //

/datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/static/possible_items[] = list(
		"капитанский лазерный револьвер" = /obj/item/gun/energy/captain,
		"генератор блюспейс разлома" = /obj/item/integrated_circuit/manipulation/bluespace_rift,
		"устройство RCD" = /obj/item/rcd,
		"реактивный ранец" = /obj/item/tank/jetpack,
		"форму капитана" = /obj/item/clothing/under/rank/captain,
		"функционирующий ИИ" = /obj/item/aicard,
		"пару магнитных ботинок" = /obj/item/clothing/shoes/magboots,
		"чертежи [station_name()]" = /obj/item/blueprints,
		"a nasa voidsuit" = /obj/item/clothing/suit/space/void,
		"28 молей форона (полный баллон)" = /obj/item/tank,
		"образец экстракта слизня" = /obj/item/slime_extract,
		"кусок мяса корги" = /obj/item/reagent_containers/food/snacks/meat/corgi,
		"форму Директора Исследований" = /obj/item/clothing/under/rank/research_director,
		"Форму Главного Инженера" = /obj/item/clothing/under/rank/chief_engineer,
		"форму Главного Врача" = /obj/item/clothing/under/rank/chief_medical_officer,
		"форму Главы Службы Безопасности" = /obj/item/clothing/under/rank/head_of_security,
		"форму Главы Персонала" = /obj/item/clothing/under/rank/head_of_personnel,
		"гипоспрей" = /obj/item/reagent_containers/hypospray,
		"капитанский целеуказатель" = /obj/item/pinpointer,
		"абляционный бронежилет" = /obj/item/clothing/suit/armor/laserproof,
	)

	var/static/possible_items_special[] = list(
		/*"nuclear authentication disk" = /obj/item/disk/nuclear,*///Broken with the change to nuke disk making it respawn on z level change.
		"nuclear gun" = /obj/item/gun/energy/gun/nuclear,
		"diamond drill" = /obj/item/pickaxe/diamonddrill,
		"bag of holding" = /obj/item/storage/backpack/holding,
		"hyper-capacity cell" = /obj/item/cell/hyper,
		"10 diamonds" = /obj/item/stack/material/diamond,
		"50 gold bars" = /obj/item/stack/material/gold,
		"25 refined uranium bars" = /obj/item/stack/material/uranium,
	)

/datum/objective/steal/proc/set_target(item_name)
	target_name = item_name
	steal_target = possible_items[target_name]
	if (!steal_target )
		steal_target = possible_items_special[target_name]
	explanation_text = "Украдите [target_name]."
	return steal_target


/datum/objective/steal/find_target()
	return set_target(pick(possible_items))


/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = possible_items+possible_items_special+"custom"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if (!new_target) return
	if (new_target == "custom")
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target) return
		var/tmp_obj = new custom_target
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		custom_name = sanitize(input("Enter target name:", "Objective target", custom_name) as text|null)
		if (!custom_name) return
		target_name = custom_name
		steal_target = custom_target
		explanation_text = "Украдитеl [target_name]."
	else
		set_target(new_target)
	return steal_target

// RnD progress download //

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Скачайте [target_amount] научных уровней."
	return target_amount

// Capture //

/datum/objective/capture

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount

// Changeling Absorb //

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	if (GAME_STATE == RUNLEVEL_SETUP)
		for(var/mob/new_player/P in GLOB.player_list)
			if(P.client && P.ready && P.mind!=owner)
				n_p ++
	else if (GAME_STATE == RUNLEVEL_GAME)
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(P.client && !(P.mind.changeling) && P.mind!=owner)
				n_p ++
	target_amount = min(target_amount, n_p)

	explanation_text = "Поглотите [target_amount] совместимых геномов."
	return target_amount

// Heist objectives.
/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap
	var/list/roles = list(/datum/job/chief_engineer, /datum/job/rd, /datum/job/roboticist, /datum/job/chemist, /datum/job/engineer)

/datum/objective/heist/kidnap/choose_target()
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (!possible_target.special_role))
			possible_targets += possible_target
			for (var/path in roles)
				var/datum/job/role = SSjobs.get_by_path(path)
				if(possible_target.assigned_role == role.title)
					priority_targets += possible_target
					continue

	if(length(priority_targets) > 0)
		target = pick(priority_targets)
	else if(length(possible_targets) > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "Мы можем получить хорошую цену за [target.current.real_name], [target.assigned_role]. Необходимо забрать цель живой."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1,8))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "полноценный ускоритель частиц"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "гравитационный генератор"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "четыре эмиттера"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "ядерную бомбу"
		if(5)
			target = /obj/item/gun
			target_amount = 6
			loot = "шесть пушек"
		if(6)
			target = /obj/item/gun/energy
			target_amount = 4
			loot = "четыре энергооружия"
		if(7)
			target = /obj/item/gun/energy/laser
			target_amount = 2
			loot = "два энергетических ружья"
		if(8)
			target = /obj/item/gun/energy/ionrifle
			target_amount = 1
			loot = "ионную винтовку"

	explanation_text = "В этой системе есть торговый хаб. Украсть [loot] для перепродажи."

/datum/objective/heist/salvage/choose_target()
	switch(rand(1,8))
		if(1)
			target = MATERIAL_STEEL
			target_amount = 300
		if(2)
			target = MATERIAL_GLASS
			target_amount = 200
		if(3)
			target = MATERIAL_PLASTEEL
			target_amount = 100
		if(4)
			target = MATERIAL_PHORON
			target_amount = 100
		if(5)
			target = MATERIAL_SILVER
			target_amount = 50
		if(6)
			target = MATERIAL_GOLD
			target_amount = 20
		if(7)
			target = MATERIAL_URANIUM
			target_amount = 20
		if(8)
			target = MATERIAL_DIAMOND
			target_amount = 20

	explanation_text = "Обворуйте [station_name()] и сбегите с [target_amount] [target]."

/datum/objective/heist/preserve_crew
	explanation_text = "Мы не бросаем своих. Ни живыми, ни мертвыми"

//Borer objective(s).
/datum/objective/borer_survive
	explanation_text = "Продержаться в хозяине до конца раунда"

/datum/objective/borer_reproduce
	explanation_text = "Репродуцироваться хотя бы раз."

/datum/objective/ninja_highlander
   explanation_text = "Ты стремишься стать великим мастером Клана Пауков. Убей всех своих товарищей-послушников."

/datum/objective/cult/survive
	explanation_text = "Наши знания должны жить"
	target_amount = 5

/datum/objective/cult/survive/New()
	..()
	explanation_text = "Наши знания должны жить. Убедитесь, что хотя бы [target_amount] аколитов сбежало, чтобы распространять нашу веру"

/datum/objective/cult/eldergod
	explanation_text = "Призовите Нар-Си, используя соответствующую руну (Hell join self). Это сработает, только если девять культистов встанут на нее и вокруг нее."

/datum/objective/cult/sacrifice
	explanation_text = "Совершите ритуал жертвоприношения во славу Нар-Си."

/datum/objective/cult/sacrifice/find_target()
	var/list/possible_targets = list()
	if(!length(possible_targets))
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !(player.mind in GLOB.cult.current_antagonists))
				possible_targets += player.mind
	if(length(possible_targets) > 0)
		target = pick(possible_targets)
	if(target) explanation_text = "Принесите жертву [target.name], [target.assigned_role]. Для этого вам понадобится руна жертвоприношения (Hell blood join) и три аколита."

/datum/objective/rev/find_target()
	..()
	if(target && target.current)
		explanation_text = "Ликвидировать, захватить или завербовать [target.current.real_name], [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/rev/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Ликвидировать, захватить или завербовать [target.current.real_name], [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target
