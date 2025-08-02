#include "_UI_output.dm"
#include "_UI_process.dm" //Здесь мы обрабатываем ввод пользователя
#include "bug_ui.dm" 	//Здесь мы выводим ошибочное сообщение
#include "cyber_join.dm"
#include "main_buttons_ui.dm" //Это подфункция которая рисует 3 верхние кнопки

#include "AUGS\augments_output.dm"
#include "IMPLANTS\implants_output.dm"
#include "LIMBS\limbs_output.dm"
#include "ORGANS\organs_output.dm"

/datum/category_group/player_setup_category/cybernetics
	name = "Cybernetics"
	sort_order = 10
	category_item_type = /datum/category_item/player_setup_item/cybernetics


/datum/category_item/player_setup_item/cybernetics
	name = "Cybernetics"
	sort_order = 1
	var/current_tab = "Протезирование"
	//Все выбранные конечности
	var/choosed_limb_slot = BP_HEAD
	var/choosed_organ_slot = BP_EYES
	var/choosed_augment_slot = BP_HEAD
	var/list/corps_list = list()

/datum/category_item/player_setup_item/cybernetics/New()
	. = ..()
	for(var/robolimb_type in subtypesof(/datum/robolimb))
		var/datum/robolimb/temp = new robolimb_type()
		var/corp_name = temp.company
		corps_list[corp_name] = robolimb_type
		qdel(temp)

/datum/preferences
	///Все те протезы, что выбрал пользователь
	var/list/limb_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	var/singleton/cyber_choose/limb/choosed_limb_prototype
	///Все те органы, что выбрал пользователь
	var/list/organ_list = list(
		BP_EYES = "Пусто",
		BP_HEART = "Пусто",
		BP_LUNGS = "Пусто",
		BP_LIVER = "Пусто",
		BP_KIDNEYS = "Пусто",
		BP_STOMACH = "Пусто"
	)
	var/singleton/cyber_choose/organ/choosed_organ_prototype
	///Все те аугменты, что выбрал пользователь. Не трогать, значения подсосутся сами.
	var/list/augments_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	//Кастомные названия аугментов
	var/list/augments_names = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	//Кастомные описания аугментов
	var/list/augments_descs = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	var/singleton/cyber_choose/augment/choosed_augment_prototype
	///Все те импланты, что выбрал пользователь. В отличии от всех трёх выше листов, у нас пишется
	///Путь импланта и после всё остальное, а не место установки и путь импланта. Тобишь, у импланта нет места установки
	var/list/implants_list = list()
	var/singleton/cyber_choose/implant/choosed_implant_prototype


//Сохранение выбранной кибернетики
/datum/category_item/player_setup_item/cybernetics/save_character(datum/pref_record_writer/W)
	. = ..()
	W.write("limbs_list", pref.limb_list)
	W.write("organs_list", pref.organ_list)
	W.write("augments_list", pref.augments_list)
	// W.write("implants_list", pref.implants_list)Задел на будущее

//Подгрузка выбранной кибернетики
/datum/category_item/player_setup_item/cybernetics/load_character(datum/pref_record_reader/R)
	pref.limb_list = R.read("limbs_list")
	pref.organ_list = R.read("organs_list")
	pref.augments_list = R.read("augments_list")
	// pref.implants_list = R.read("implants_list") Задел на будущее
	//Исправление ошибок
	if(!LAZYLEN(pref.organ_list) || LAZYLEN(pref.organ_list) > 6)
		if(pref.client)
			to_chat(pref.client, SPAN_BAD("Произошла ошибка загрузки органов, мы установили вам стандартные."))
		pref.organ_list = list(
			BP_EYES = "Пусто",
			BP_HEART = "Пусто",
			BP_LUNGS = "Пусто",
			BP_LIVER = "Пусто",
			BP_KIDNEYS = "Пусто",
			BP_STOMACH = "Пусто"
		)

	if(!LAZYLEN(pref.augments_list) || LAZYLEN(pref.limb_list) > 11 )
		if(pref.client)
			to_chat(pref.client, SPAN_BAD("Произошла ошибка загрузки аугментаций, мы обнулили вам список аугментаций."))
		pref.augments_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	if(!LAZYLEN(pref.limb_list) || LAZYLEN(pref.limb_list) > 11)
		if(pref.client)
			to_chat(pref.client, SPAN_BAD("Произошла ошибка загрузки конечностей, мы установили вам стандартные."))
		pref.limb_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)


	//Очистка старых списков
	if(LAZYLEN(pref.organ_data))
		pref.organ_data = null
		if(pref.client)
			to_chat(pref.client, SPAN_BAD("В вашем сохранении обнаружены устаревшие данные с киберорганами. Теперь они неактуальны, собирайтесь по новой."))
	if(LAZYLEN(pref.rlimb_data))
		pref.rlimb_data = null
		if(pref.client)
			to_chat(pref.client, SPAN_BAD("В вашем сохранении обнаружены устаревшие данные с киберконечностями. Теперь они неактуальны, собирайтесь по новой."))

/datum/category_item/player_setup_item/cybernetics/proc/wipe_all()
	pref.limb_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	to_chat(pref.client, SPAN_GOOD("Конечности сброшены до стандартных."))
	pref.organ_list = list(
			BP_EYES = "Пусто",
			BP_HEART = "Пусто",
			BP_LUNGS = "Пусто",
			BP_LIVER = "Пусто",
			BP_KIDNEYS = "Пусто",
			BP_STOMACH = "Пусто"
		)
	to_chat(pref.client, SPAN_GOOD("Органы сброшены до стандартных."))
	pref.augments_list = list(
		BP_HEAD = "Пусто",
		BP_CHEST = "Пусто",
		BP_GROIN = "Пусто",
		BP_R_ARM = "Пусто",
		BP_R_HAND = "Пусто",
		BP_L_ARM = "Пусто",
		BP_L_HAND = "Пусто",
		BP_R_LEG = "Пусто",
		BP_R_FOOT = "Пусто",
		BP_L_LEG = "Пусто",
		BP_L_FOOT = "Пусто"
	)
	to_chat(pref.client, SPAN_GOOD("Аугменты сброшены до стандартных."))
	pref.implants_list = list()
	to_chat(pref.client, SPAN_GOOD("Импланты сброшены до стандартных."))
	to_chat(pref.client, SPAN_GOOD("Сброс закончен, но не сохранён. Сохраните или откатите отброс путём загрузки сохранения."))
