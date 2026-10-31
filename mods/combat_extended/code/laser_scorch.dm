/*
	COMBAT_EXTENDED — прожоги от лучей на броне (`laser_heat.dm`).

	Каждый луч, попавший в броню, которая греется, оставляет на её вещи прожог там, куда пришёлся:
	у точки части тела со случайным сдвигом (`ce_laser_scorch_points`). Прожог светится по жару своей
	брони: на раскалённой добела — ярче всего, остывая, тускнеет по тем же ступеням и остаётся чёрным
	следом. Свежий прожог на миг вспыхивает добела, даже если броня холодная. Прожогов на вещи не
	больше `ce_laser_scorch_max`: новый вытесняет самый старый.

	Прожог видно с той стороны, куда пришёлся луч: спереди, со спины или сбоку. Каждая иконка
	прожога нарисована только в кадре одного направления, поэтому, когда носитель поворачивается,
	BYOND сам показывает прожог или прячет его — без событий поворота.

	Прожог живёт на вещи с бронёй: на пластине, наручах, каске, скафандре. Пластину без своего
	спрайта видно через плитоноску, поэтому плитоноска рисует и прожоги своих нагрудных пластин.
	Иконка — `icons/laser_scorch.dmi`: состояние `<ступень>_<направление>`.
*/

/// Прожог от луча на вещи.
/datum/ce_scorch_mark
	/// Сдвиг от середины спрайта, px.
	var/pixel_x = 0
	var/pixel_y = 0
	/// Куда смотрит носитель, когда прожог видно: SOUTH — прожог спереди, NORTH — на спине.
	var/visible_dir = SOUTH
	/// Группа зон зональной брони, по жару которой светится прожог. null — у незональной.
	var/group
	/// До какого `world.time` прожог вспыхивает добела, свежий.
	var/fresh_until = 0

/obj/item/clothing
	/// Прожоги от лучей на этой вещи, старые первыми.
	var/list/ce_scorch_marks


/**
 * Прожог от луча `projectile`, попавшего в `def_zone` носителя, на этой вещи. `group` — группа зон
 * зональной брони, по жару которой прожог светится.
 */
/obj/item/clothing/proc/ce_add_scorch_mark(mob/living/carbon/human/wearer, def_zone, group, obj/item/projectile/projectile)
	if(!ce_laser_scorch_enabled || !istype(wearer))
		return
	var/list/point = ce_laser_scorch_points[check_zone(def_zone)]
	if(!point)
		return
	var/shooter_dir = projectile?.starting ? get_dir(wearer, projectile.starting) : 0
	var/datum/ce_scorch_mark/mark = new
	mark.visible_dir = ce_get_scorch_visible_dir(wearer.dir, shooter_dir || SOUTH)
	var/list/offset = ce_get_scorch_offset(point, mark.visible_dir)
	mark.pixel_x = offset[1]
	mark.pixel_y = offset[2]
	mark.group = group
	mark.fresh_until = world.time + ce_laser_scorch_fresh_time
	LAZYADD(ce_scorch_marks, mark)
	if(length(ce_scorch_marks) > ce_laser_scorch_max)
		ce_scorch_marks.Cut(1, 2)
	update_clothing_icon()
	// Вспышка гаснет сама: вещь перерисуется, когда свежий прожог остынет до жара своей брони.
	addtimer(new Callback(src, TYPE_PROC_REF(/obj/item/clothing, update_clothing_icon)), ce_laser_scorch_fresh_time, TIMER_UNIQUE | TIMER_OVERRIDE)


/// Главное из направлений: SOUTH и NORTH важнее EAST и WEST, как у диагоналей спрайта моба.
/proc/ce_get_cardinal_dir(dir)
	if(dir & SOUTH)
		return SOUTH
	if(dir & NORTH)
		return NORTH
	if(dir & EAST)
		return EAST
	return WEST


/**
 * Куда должен смотреть носитель, чтобы прожог было видно. Луч прожигает бок носителя, обращённый к
 * стрелку, а видно этот бок, когда он смотрит на юг, к зрителю. `mob_dir` — куда смотрел носитель,
 * `shooter_dir` — где был стрелок.
 */
/proc/ce_get_scorch_visible_dir(mob_dir, shooter_dir)
	var/static/list/turn_by_side = list("[SOUTH]" = 0, "[NORTH]" = 180, "[EAST]" = -90, "[WEST]" = 90)
	return turn(ce_get_cardinal_dir(mob_dir), turn_by_side["[ce_get_cardinal_dir(shooter_dir)]"])


/**
 * Сдвиг прожога от середины спрайта у точки части тела `point`: анфас — как есть, со спины —
 * зеркально, сбоку — к середине тела. Со случайным сдвигом до разброса точки.
 */
/proc/ce_get_scorch_offset(list/point, visible_dir)
	var/x = point[1]
	switch(visible_dir)
		if(NORTH)
			x = 32 - x
		if(EAST, WEST)
			x = 16
	var/spread = point[3]
	return list(x - 16 + rand(-spread, spread), point[2] - 16 + rand(-spread, spread))


/**
 * Прожоги на картинке вещи на носителе: свои и нагрудных пластин, у которых своего спрайта нет. У
 * вещи в руках прожогов не видно.
 */
/obj/item/clothing/proc/ce_draw_scorch_marks(image/worn_image, slot)
	if(!ce_laser_scorch_enabled || !istype(worn_image) || slot == slot_l_hand_str || slot == slot_r_hand_str)
		return
	var/list/sources = list(src)
	for(var/obj/item/clothing/accessory/accessory as anything in accessories)
		if(accessory.slot == ACCESSORY_SLOT_ARMOR_CHEST)
			sources += accessory
	var/list/scorch_overlays = list()
	for(var/obj/item/clothing/source as anything in sources)
		for(var/datum/ce_scorch_mark/mark as anything in source.ce_scorch_marks)
			scorch_overlays += source.ce_get_scorch_overlays(mark)
	if(length(scorch_overlays))
		worn_image.AddOverlays(scorch_overlays)


/**
 * Картинки прожога: сам прожог по ступени накала его брони (свежий — добела) и, пока броня горячая,
 * эмиссив, чтобы прожог светился и в темноте.
 */
/obj/item/clothing/proc/ce_get_scorch_overlays(datum/ce_scorch_mark/mark)
	RETURN_TYPE(/list)
	var/datum/extension/armor/armor = ce_get_heated_armor(src)
	var/heat_stage = armor ? ce_get_heat_stage(armor.ce_get_temperature(mark.group)) : 0
	var/stage = world.time < mark.fresh_until ? length(ce_laser_heat_stage_temperatures) : heat_stage
	var/state = "[stage]_[mark.visible_dir]"
	var/image/scorch = overlay_image('mods/combat_extended/icons/laser_scorch.dmi', state, null, RESET_COLOR | RESET_ALPHA)
	scorch.pixel_x = mark.pixel_x
	scorch.pixel_y = mark.pixel_y
	. = list(scorch)
	// Эмиссив — только по настоящему жару: вспышку свежего прожога на холодной броне Z-Mimic не ждёт.
	var/emissive_alpha = heat_stage ? ce_laser_scorch_emissive_alpha[heat_stage] : 0
	if(emissive_alpha > 0)
		var/mutable_appearance/emissive = emissive_appearance(scorch.icon, state, CE_LASER_EMISSIVE_LAYER, emissive_alpha)
		emissive.pixel_x = mark.pixel_x
		emissive.pixel_y = mark.pixel_y
		. += emissive
