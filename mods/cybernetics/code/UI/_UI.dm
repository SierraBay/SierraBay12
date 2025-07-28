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

/datum/preferences
	///Все те протезы, что выбрал пользователь (Почему rlimb? Да мнеж откуда знать, это название пендосов, оставил для совместимости)
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
	var/singleton/cyber_choose/choosed_limb_prototype
	///Все те органы, что выбрал пользователь
	var/list/organ_list = list(
			BP_EYES = "Пусто",
			BP_HEART = "Пусто",
			BP_LUNGS = "Пусто",
			BP_LIVER = "Пусто",
			BP_KIDNEYS = "Пусто",
			BP_STOMACH = "Пусто"
		)
	var/singleton/cyber_choose/choosed_organ_prototype
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
	var/singleton/cyber_choose/choosed_augment_prototype
	///Все те импланты, что выбрал пользователь. В отличии от всех трёх выше листов, у нас пишется
	///Путь импланта и после всё остальное, а не место установки и путь импланта. Тобишь, у импланта нет места установки
	var/list/implants_list = list()
	var/singleton/cyber_choose/choosed_implant_prototype


//Сохранение выбранных настроек
/datum/category_item/player_setup_item/cybernetics/save_preferences(datum/pref_record_writer/W)
	W.write("limbs_list", pref.limb_list)
	W.write("organs_list", pref.organ_list)
	W.write("augments_list", pref.augments_list)
	W.write("implants_list", pref.implants_list)

/datum/category_item/player_setup_item/cybernetics/load_preferences(datum/pref_record_reader/R)
	pref.limb_list = R.read("limbs_list")
	pref.organ_list = R.read("organs_list")
	pref.augments_list = R.read("augments_list")
	pref.implants_list = R.read("implants_list")
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
