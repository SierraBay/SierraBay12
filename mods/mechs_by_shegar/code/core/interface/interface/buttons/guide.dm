#define MECH_GUIDE_STYLE(X) "<span style=\"font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: 15px;\">" + X + "</span>"

/obj/screen/movable/exosuit/guide
	name = "ПОМОЩЬ"
	icon_state = "mech_guide"

/obj/screen/movable/exosuit/guide/Click()
	var/choice = alert("Хотите пройти обучение по меху?", "MECH GUIDE", "Обучение по UI меха", "Обучение по меху в целом", "Я ничего не хочу")
	if(choice == "Обучение по UI меха")
		owner.start_ui_guide(usr)
	else if(choice == "Обучение по меху в целом")
		to_chat(usr, SPAN_NOTICE("А гайда то нет!"))
		return
	else if(choice == "Я ничего не хочу")
		return

// ГАЙД
/mob/living/exosuit
	var/datum/mech_guide_data/mech_guide_data
	var/mech_ui_guide_status = FALSE

/obj/screen/fullscreen/mech_guide
	name = "Гайд"
	icon = 'mods/mechs_by_shegar/icons/guide.dmi'
	layer = EMISSIVE_PLANE
	scale_to_view = TRUE

/obj/screen/fullscreen/mech_guide/main
	icon_state = "background_main"

/obj/screen/fullscreen/mech_guide/weaponary
	icon_state = "background_weaponary"

/obj/screen/fullscreen/mech_guide/downside
	icon_state = "background_downside"

/obj/screen/fullscreen/mech_guide/menu_first
	icon_state = "background_menu_first"

/obj/screen/fullscreen/mech_guide/menu_second
	icon_state = "background_menu_second"

// Байда на которой и отображается весь текст гайда
/obj/screen/exosuit/guide_teller
	name = "ГАЙД"
	maptext = MECH_UI_STYLE("ТЕКСТ")
	icon_state = "guide_button"
	maptext_x = 40
	maptext_y = -70
	screen_loc = "CENTER, CENTER"
	maptext_height = 200
	maptext_width = 200

/obj/screen/exosuit/guide_teller/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, "alt"))  // Проверяем, нажат ли Alt
		owner.prev_step(usr)  // Переход на предыдущий шаг
	else
		owner.next_step(usr)  // Переход на следующий шаг

/datum/mech_guide_data
	var/current_step = 1
	var/list/guide_steps = list(
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/main,
			text = "Добро пожаловать в обучение по UI меха! Для перехода на следующий шаг, вам потребуется нажать на зелёную кнопку GO над текстом, а для перехода на предыдущий шаг - Alt + ЛКМ. Угу? <br> Нажмите на GO, чтобы продолжить.",
			callbacks = null,
			teller_loc = "CENTER, CENTER"
		),
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/weaponary,
			text = "Здесь находится всё оборудование меха, от фонарей до орудий. Дополнительные параметры экипировки пишется так же рядом. Чтоб выбрать данный модуль, нажмите на квадрат в котором он расположен. <br> Нажмите на GO, чтобы продолжить.",
			callbacks = null,
			teller_loc = "CENTER-7, CENTER+5"
		),
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/downside,
			text = "Здесь основные кнопки меха - Power, Eject, Hatch, Air. Чтоб узнать что каждая из них делает - наведитесь и прочитайте! <br> Нажмите на GO, чтобы продолжить.",
			callbacks = null,
			teller_loc = "CENTER-7, CENTER-1"
		),
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/menu_first,
			text = "А здесь состояние меха. Чем краснее часть, тем меху хуже. Вы можете открыть полноценное меню меха, если нажмёте на этот квадрат с помощью ЛКМ, но мы откроем его за вас. <br> Нажмите на GO, чтобы продолжить.",
			callbacks = null,
			teller_loc = "CENTER, CENTER-1"
		),
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/menu_second,
			text = "Здесь распологаются второстепенные кнопки меха, а по середине меню - отдельные компоненты меха. Наведитесь на них чтоб посмотреть их состояние и характеристики. <br> Нажмите на GO, чтобы продолжить.",
			callbacks = list("open_big_menu"),
			teller_loc = "CENTER-2, CENTER+6"
		),
		list(
			guide_type = /obj/screen/fullscreen/mech_guide/main,
			text = "А ещё можно закреплять кнопки в меню меха на главном экране, нажимая по ним СКМ. В целом, это всё. Заводи меха, пилот! <br> Обучение закончено,Нажмите на GO для окончания обучения",
			callbacks = list("open_big_menu", "toggle_power"),
			teller_loc = "CENTER, CENTER"
		)
	)
	var/obj/screen/exosuit/guide_teller/teller

/mob/living/exosuit/proc/start_ui_guide(mob/user)
	if(!mech_guide_data)
		mech_guide_data = new /datum/mech_guide_data(src)
	mech_ui_guide_status = TRUE
	mech_guide_data.current_step = 1
	mech_guide_data.teller = new /obj/screen/exosuit/guide_teller(src)
	user.client.screen |= mech_guide_data.teller
	update_guide(user)

/mob/living/exosuit/proc/stop_ui_guide(mob/user)
	mech_ui_guide_status = FALSE
	mech_guide_data.current_step = 1
	user.client.screen -= mech_guide_data.teller
	qdel(mech_guide_data)
	mech_guide_data = null
	to_chat(user, SPAN_INFO("Гайд окончен."))
	user.clear_fullscreen("mech_guide")

/mob/living/exosuit/proc/next_step(mob/user)
	if(!mech_guide_data)
		return
	mech_guide_data.current_step++
	update_guide(user)

/mob/living/exosuit/proc/prev_step(mob/user)
	if(!mech_guide_data)
		return

	if(mech_guide_data.current_step > 1)
		mech_guide_data.current_step--
		update_guide(user)

/mob/living/exosuit/proc/update_guide(mob/user)
	if(!mech_guide_data || mech_guide_data.current_step > length(mech_guide_data.guide_steps))
		stop_ui_guide(user)
		return

	var/list/current_step_data = mech_guide_data.guide_steps[mech_guide_data.current_step]
	var/guide_type = current_step_data["guide_type"]

	user.clear_fullscreen("mech_guide")  // Очищаем предыдущий фулскрин
	user.overlay_fullscreen("mech_guide", guide_type)  // Накладываем новый фулскрин

	if(mech_guide_data.teller)
		mech_guide_data.teller.maptext = MECH_GUIDE_STYLE(current_step_data["text"])
		mech_guide_data.teller.screen_loc = current_step_data["teller_loc"]  // Обновляем screen_loc

	// Вызов callback, если он есть
	var/list/callbacks = current_step_data["callbacks"]
	for(var/callback in callbacks)
		call(src, callback)(user)  // Вызываем функцию по имени
