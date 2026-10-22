/*
	COMBAT_EXTENDED — кольцо разброса: курсор с кольцом, ближе которого к точке под мышью пройдёт
	следующий выстрел.

	На карте ничто не идёт за мышью без сервера: точку под мышью сервер узнаёт с опозданием на пинг.
	Без опоздания за мышью идёт только сам курсор, но он — одна картинка: не поворачивается и не
	растёт с картой. Поэтому здесь кольцо, а не края дуги: кольцу направление не нужно.

	Здесь:
	- линия выстрела из середины клетки стрелка, отклонённая на угол φ, проходит от точки прицела на
	  расстоянии `d · |sin φ|`, где `d` — расстояние до неё; при отклонении до половины дуги — не
	  дальше `d · sin(дуга / 2)` (`ce_get_spread_ring_world_radius()`). Это радиус кольца: края дуги
	  его касаются;
	- точка прицела — та же, что взял бы выстрел по тому, над чем мышь (`ce_get_aim_point()` по
	  пикселю, на котором мышь в это вошла). Где мышь, сервер узнаёт, когда она входит в новый атом
	  (оверрайд `/client/MouseEntered()`) и когда её ведут с зажатой кнопкой — автоматический огонь
	  (`/client/MouseDrag()`). Само кольцо стоит на курсоре всегда, а его радиус меняется с
	  опозданием на пинг;
	- дуга — та, что получит следующий выстрел: разброс оружия и навыка считает сам
	  `process_accuracy()` на снаряде-образце (`ce_get_next_spread_arcs()`), отдачу — стаки стрелка.
v	  Пока стаки сходят, кольцо сужается, когда сходит стак (`on_recoil_tick()`). Считает дугу
	  `refresh()`, а мышь и шаг берут посчитанную: так на движение мыши уходят микросекунды;
	- курсор BYOND не растёт вместе с картой, и радиус переводится в экранные пиксели: масштаб —
	  размер карты на экране (`view-size`) на число клеток вида (`ce_get_screen_scale()`). Его
	  читают с клиента, когда кольцо появилось, когда сменился вид и когда карта сменила размер
	  (команда `on-size` карты, которую ставит мод);
	- курсор — перекрестие апстрима (`get_mouse_pointer()`) с кольцом вокруг горячей точки
	  (`ce_get_spread_ring_cursor()`). Проба в игре: курсор до 512 пикселей рисуется целиком,
	  горячая точка — посередине;
	- разброса нет — кольца нет, и над тем, что рядом, тоже: щелчок по нему `ClickOn()` отдаёт
	  `use_before()`, и оружие бьёт в упор, без разброса, или не стреляет вовсе.

	Кольцо пересчитывается при наведении, выстреле, шаге стрелка, смене режима огня и на всём, на
	чём кор зовёт `update_mouse_pointer()`: взял, бросил, сменил руку, щёлкнул предохранителем,
	поменял настройку, вошёл в моба. Показывается, как перекрестие апстрима, пока в активной руке
	огнестрельное оружие, а поставленного предохранителя на нём стрелок не видит; и только с
	попиксельной стрельбой и если игрок не выключил его в настройках
	(`/datum/client_preference/ce_spread_ring`). Метательное оружие (`/obj/item/gun/launcher`)
	снарядов не пускает, и кольца у него нет.
*/

/// Наибольший радиус кольца на экране, пиксели: шире 512 пикселей курсор в игре не проверялся.
#define CE_SPREAD_RING_MAX_RADIUS 253
#define CE_SPREAD_RING_COLOR "#ffffff"
#define CE_SPREAD_RING_OUTLINE_COLOR "#000000"
/// Через сколько децисекунд после того, как карта сменила размер, читать масштаб: окно, которое
/// тянут за край, присылает такие события подряд.
#define CE_SPREAD_RING_RESIZE_DELAY 5

/datum/client_preference/ce_spread_ring
	description = "Gun spread ring"
	key = "CE_SPREAD_RING"

/datum/client_preference/ce_spread_ring/changed(mob/preference_mob, new_value)
	preference_mob.update_mouse_pointer()


/// Карта на экране игрока сменила размер (команда `on-size` карты): кольцу нужен новый масштаб.
/client/verb/ce_on_map_resized()
	set name = "ce_on_map_resized"
	set hidden = TRUE
	var/mob/living/carbon/shooter = mob
	if(!istype(shooter))
		return
	var/datum/extension/ce_spread_ring/ring = get_extension(shooter, /datum/extension/ce_spread_ring)
	ring?.request_screen_scale(CE_SPREAD_RING_RESIZE_DELAY)


// ============================================================================================
// Дуга следующего выстрела
// ============================================================================================

/**
 * Дуги разброса следующего выстрела стрелка `user` из этого оружия, `list(сейчас, без отдачи)`,
 * градусы. Их считает тот же `process_accuracy()`, что и у выстрела, — разброс режима огня, хват
 * одной рукой, — на снаряде-образце, который никуда не летит; навык и отдачу добавляет
 * `ce_get_spread_arc()` снаряда.
 */
/obj/item/gun/proc/ce_get_next_spread_arcs(mob/living/user)
	RETURN_TYPE(/list)
	var/static/obj/item/projectile/probe
	if(QDELETED(probe))
		probe = new
	probe.firer = user
	// Хват двумя руками — как его считает `Fire()`.
	process_accuracy(probe, user, null, 1, user.can_wield_item(src) && is_held_twohanded(user))
	var/arc_now = probe.ce_get_spread_arc()
	probe.ce_recoil_arc = 0
	var/arc_settled = probe.ce_get_spread_arc()
	probe.firer = null
	return list(arc_now, arc_settled)


/// Оружие показывает кольцо разброса тому, кто его держит: как перекрестия апстрима, его нет, пока
/// стрелок видит поставленный предохранитель.
/obj/item/gun/proc/ce_shows_spread_ring(mob/user)
	return !(safety() && shows_safety_to(user))


/// Метательное оружие бросает предмет, а не пускает снаряд: разброса у броска нет.
/obj/item/gun/launcher/ce_shows_spread_ring(mob/user)
	return FALSE


// ============================================================================================
// Радиус и курсор
// ============================================================================================

/**
 * Радиус кольца разброса в мире, пиксели: дальше этого от точки прицела `aim` линия выстрела из
 * `apex` с дугой `arc` не пройдёт — `d · sin(arc / 2)`. Края дуги касаются кольца. Дуга шире
 * полукруга не уводит линию дальше `d`.
 */
/proc/ce_get_spread_ring_world_radius(list/apex, list/aim, arc)
	if(arc <= 0)
		return 0
	var/distance = sqrt((aim[1] - apex[1]) ** 2 + (aim[2] - apex[2]) ** 2)
	return distance * sin(min(arc, 180) / 2)


/**
 * Масштаб карты на экране игрока, экранных пикселей на пиксель мира: размер карты на экране
 * `view_size` (`"ШxВ"`, без полос по краям) на клетки его вида `view`. null — размера нет.
 */
/proc/ce_get_screen_scale(view_size, view)
	var/list/pixels = splittext(view_size, "x")
	if(length(pixels) != 2)
		return null
	var/width = text2num(pixels[1])
	var/height = text2num(pixels[2])
	var/list/tiles = getviewsize(view)
	if(!width || !height || !tiles[1] || !tiles[2])
		return null
	return min(width / (tiles[1] * world.icon_size), height / (tiles[2] * world.icon_size))


/**
 * Курсор с кольцом радиуса `radius` экранных пикселей вокруг горячей точки и перекрестием
 * `crosshair` (файл курсора апстрима) посередине; без перекрестия — точка. Картинка — наименьший
 * квадрат из 32, 64, 128, 256 и 512 пикселей, в который кольцо входит с обводкой. Курсор рисуется
 * один раз на радиус и перекрестие и потом берётся готовым — файлом кэша, сжатым: картинкой
 * (`/icon`) курсор в 512 пикселей держал бы в памяти сервера мегабайт, а файлом — пару килобайт.
 */
/proc/ce_get_spread_ring_cursor(radius, crosshair)
	var/static/list/cursors = list()
	var/key = "[radius]:[crosshair]"
	if(cursors[key])
		return cursors[key]
	var/size = world.icon_size
	while(size < 2 * radius + 6)
		size *= 2
	var/icon/canvas = icon('icons/blanks/32x32.dmi', "nothing")
	canvas.Scale(size, size)
	var/center = size / 2
	if(crosshair)
		// Середина перекрестия — между его 16-м и 17-м пикселями, как и середина курсора.
		canvas.Blend(icon(crosshair), ICON_OVERLAY, center - world.icon_size / 2 + 1, center - world.icon_size / 2 + 1)
	else
		canvas.DrawBox(CE_SPREAD_RING_COLOR, center, center, center + 1, center + 1)
	ce_draw_spread_ring(canvas, center, radius + 1, CE_SPREAD_RING_OUTLINE_COLOR)
	ce_draw_spread_ring(canvas, center, radius, CE_SPREAD_RING_COLOR)
	// Курсор берёт состояние "", а у вырезанной из файла картинки оно может зваться по-своему.
	var/list/states = icon_states(canvas)
	if(states[1] != "")
		canvas.Insert(icon(canvas, states[1]), "")
	var/cursor = fcopy_rsc(canvas)
	cursors[key] = cursor
	return cursor


/// Окружность радиуса `radius` с серединой `center` (пиксели картинки от её угла) цветом `color`.
/proc/ce_draw_spread_ring(icon/canvas, center, radius, color)
	// По две точки на пиксель окружности: 2 * 2 * pi — около 13.
	var/steps = ceil(radius * 13)
	for(var/step_index in 1 to steps)
		var/angle = 360 * step_index / steps
		canvas.DrawBox(color, floor(center + radius * cos(angle)) + 1, floor(center + radius * sin(angle)) + 1)


// ============================================================================================
// Кольцо на стрелке
// ============================================================================================

/datum/extension/ce_spread_ring
	base_type = /datum/extension/ce_spread_ring
	expected_type = /mob/living/carbon
	flags = EXTENSION_FLAG_IMMEDIATE
	/// Радиус кольца на экране, пиксели. Ноль — кольца нет: разброса нет, целиться не во что, или
	/// масштаб ещё не прочитан.
	var/radius = 0
	/// Дуга следующего выстрела, градусы, на последний `refresh()`. Мышь и шаг её не меняют, и
	/// между пересчётами она берётся отсюда.
	var/arc = 0
	/// Экранных пикселей на пиксель мира у клиента стрелка. null — не прочитан или не прочитался.
	var/screen_scale
	/// `view` клиента, при котором читали масштаб: сменился вид — масштаб читается заново.
	var/scale_view
	/// То, над чем мышь, и пиксель, на котором она в это вошла (`icon-x`, `icon-y`). Без пикселя
	/// прицел — середина того, над чем мышь.
	var/weakref/hovered
	var/hover_icon_x
	var/hover_icon_y
	/// Когда сработает таймер, который сузит кольцо, пока со стрелка сходит отдача. Не позже
	/// нынешнего мгновения — таймера нет.
	var/recoil_tick_time = 0
	/// Чтение масштаба с клиента назначено и ещё не прошло.
	var/scale_read_pending = FALSE


/datum/extension/ce_spread_ring/New(datum/holder)
	..()
	var/mob/living/carbon/shooter = holder
	RegisterSignal(shooter, COMSIG_MOVABLE_MOVED, PROC_REF(on_shooter_moved))
	GLOB.logged_out_event.register(shooter, src, PROC_REF(on_shooter_logged_out))
	// Мышь могла войти во что-то раньше, чем кольцо появилось: оно целится туда, без пикселя.
	var/datum/click_handler/handler = shooter.GetClickHandler()
	note_hover(handler?.hovered_atom)


/datum/extension/ce_spread_ring/Destroy()
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	GLOB.logged_out_event.unregister(holder, src, PROC_REF(on_shooter_logged_out))
	// Таймеры кольца снимать не нужно: таймер удалённого кольца не срабатывает.
	hovered = null
	return ..()


/**
 * Мышь вошла в `object` на пикселе из `params` — строкой или списком, как их отдаёт BYOND. FALSE —
 * в это не целятся: панель интерфейса, предмет в инвентаре; кольцо остаётся, каким было. Сетка под
 * картой (`click_catcher`), куда мышь попадает над невидимой клеткой, — клетка под ней.
 */
/datum/extension/ce_spread_ring/proc/note_hover(atom/object, params)
	if(!istype(object))
		return FALSE
	if(!istype(object, /obj/screen/click_catcher) && !isturf(object) && !isturf(object.loc))
		return FALSE
	var/list/mouse = islist(params) ? params : params2list(params)
	hovered = weakref(object)
	hover_icon_x = text2num(mouse[MOUSE_ICON_X])
	hover_icon_y = text2num(mouse[MOUSE_ICON_Y])
	return TRUE


/// То, во что целится кольцо: то, над чем мышь, а за сеткой под картой — клетка под ней. null —
/// целиться не во что: мыши не было, или то, над чем она, ушло с карты.
/datum/extension/ce_spread_ring/proc/get_aim_target()
	RETURN_TYPE(/atom)
	var/atom/target = hovered?.resolve()
	if(istype(target, /obj/screen/click_catcher))
		var/obj/screen/click_catcher/catcher = target
		return catcher.get_covered_turf(holder)
	if(isturf(target) || isturf(target?.loc))
		return target
	return null


/**
 * Радиус кольца на экране с дугой `arc` по тому, над чем мышь, пиксели. Ноль — кольца нет: масштаба
 * нет, целиться не во что, это рядом или разброса нет.
 */
/datum/extension/ce_spread_ring/proc/get_screen_radius()
	var/mob/living/carbon/shooter = holder
	var/turf/apex_turf = shooter.loc
	var/atom/target = get_aim_target()
	if(!arc || !screen_scale || !isturf(apex_turf) || !target || target.z != shooter.z || target.Adjacent(shooter))
		return 0
	var/list/aim = target.ce_get_aim_point(hover_icon_x, hover_icon_y)
	if(!aim)
		return 0
	var/world_radius = ce_get_spread_ring_world_radius(apex_turf.ce_get_tile_center(), aim, arc)
	return min(round(world_radius * screen_scale), CE_SPREAD_RING_MAX_RADIUS)


/**
 * Пересчитывает дугу следующего выстрела из `gun` и по ней радиус кольца. Сменился у клиента вид —
 * просит масштаб заново; на стрелке ещё есть отдача — ставит таймер, который сузит кольцо, когда
 * сойдёт следующий стак. Возвращает, изменился ли радиус.
 *
 * Дугу считает `process_accuracy()` со всеми проверками навыков — это почти вся цена пересчёта,
 * — и поэтому только здесь: на выстреле, сходе стака и всём, на чём кор зовёт
 * `update_mouse_pointer()`. Мышь и шаг дугу не меняют, им хватает `update_radius()`.
 *
 * Таймер на кольцо один, и его держит само кольцо: `TIMER_UNIQUE` в Бэй таймеры не сливает
 * (`_addtimer()` не записывает новый таймер в `timers_by_hash`), и каждый пересчёт под отдачей
 * заводил бы ещё одну цепочку таймеров.
 */
/datum/extension/ce_spread_ring/proc/refresh(obj/item/gun/gun)
	var/mob/living/carbon/shooter = holder
	if(shooter.client && scale_view != shooter.client.view)
		request_screen_scale()
	var/list/arcs = gun.ce_get_next_spread_arcs(shooter)
	arc = arcs[1]
	if(shooter.ce_get_recoil_stacks() && recoil_tick_time <= world.time)
		recoil_tick_time = shooter.ce_get_next_recoil_shed_time()
		addtimer(new Callback(src, PROC_REF(on_recoil_tick)), recoil_tick_time - world.time)
	return update_radius()


/// Пересчитывает радиус кольца с дугой прошлого `refresh()`: мышь и шаг меняют расстояние до точки
/// прицела, а не дугу. Возвращает, изменился ли радиус.
/datum/extension/ce_spread_ring/proc/update_radius()
	var/old_radius = radius
	radius = get_screen_radius()
	return radius != old_radius


/**
 * Ставит клиенту стрелка курсор с нынешним радиусом. Не через `update_mouse_pointer()`: тот позвал бы
 * `refresh()` и заново посчитал дугу, которая не менялась.
 */
/datum/extension/ce_spread_ring/proc/show()
	var/mob/living/carbon/shooter = holder
	if(shooter.client)
		shooter.client.mouse_pointer_icon = shooter.get_mouse_pointer()


/// Читает масштаб с клиента не раньше чем через `delay`. Запросы, пришедшие до чтения, сливаются в
/// одно — само кольцо, не `TIMER_UNIQUE` (см. `refresh()`): окно, которое тянут за край, присылает
/// события размера подряд, и каждое ждало бы ответа клиента.
/datum/extension/ce_spread_ring/proc/request_screen_scale(delay = 0)
	if(scale_read_pending)
		return
	scale_read_pending = TRUE
	addtimer(new Callback(src, PROC_REF(read_screen_scale)), delay)


/**
 * Читает с клиента размер карты на экране и считает масштаб. Ждёт ответа клиента. Заодно ставит
 * карте команду `on-size`: сменит карта размер — масштаб прочитается снова. Не прочитался — кольца
 * нет до следующего вида, размера карты или кольца.
 */
/datum/extension/ce_spread_ring/proc/read_screen_scale()
	scale_read_pending = FALSE
	var/mob/living/carbon/shooter = holder
	var/client/viewer = shooter?.client
	if(!viewer)
		return
	winset(viewer, "mapwindow.map", "on-size=ce_on_map_resized")
	var/view = viewer.view
	var/view_size = winget(viewer, "mapwindow.map", "view-size")
	if(QDELETED(src) || shooter.client != viewer)
		return
	screen_scale = ce_get_screen_scale(view_size, view)
	scale_view = view
	shooter.update_mouse_pointer()


/// Срок стака вышел: отдача сошла на стак, кольцо сужается.
/datum/extension/ce_spread_ring/proc/on_recoil_tick()
	recoil_tick_time = 0
	var/mob/living/carbon/shooter = holder
	shooter.ce_refresh_spread_ring()


/// Стрелок шагнул: вершина дуги ушла вместе с ним.
/datum/extension/ce_spread_ring/proc/on_shooter_moved()
	SIGNAL_HANDLER
	if(update_radius())
		show()


/// Игрок вышел из моба: масштаб был его экрана. Войдёт — прочитается заново.
/datum/extension/ce_spread_ring/proc/on_shooter_logged_out()
	screen_scale = null
	scale_view = null


// ============================================================================================
// Стрелок
// ============================================================================================

/// Кольцо разброса есть кому показать: в моба вошёл игрок.
/mob/living/carbon/proc/ce_has_spread_ring_viewer()
	return !!client


/// Оружие в активной руке, по которому показывается кольцо разброса, или null — кольца нет.
/mob/living/carbon/proc/ce_get_spread_ring_gun()
	RETURN_TYPE(/obj/item/gun)
	if(!ce_has_spread_ring_viewer() || !ce_pixel_aim_enabled)
		return null
	if(get_preference_value(/datum/client_preference/ce_spread_ring) != GLOB.PREF_YES)
		return null
	var/obj/item/gun/gun = get_active_hand()
	if(!istype(gun) || !gun.ce_shows_spread_ring(src))
		return null
	return gun


/// Заводит, пересчитывает или убирает кольцо разброса. Курсор по нему ставит кор
/// `update_mouse_pointer()`, который это и зовёт.
/mob/living/carbon/proc/ce_sync_spread_ring()
	var/obj/item/gun/gun = ce_get_spread_ring_gun()
	if(!gun)
		remove_extension(src, /datum/extension/ce_spread_ring)
		return
	var/datum/extension/ce_spread_ring/ring = get_or_create_extension(src, /datum/extension/ce_spread_ring)
	ring.refresh(gun)


/// Пересчитывает кольцо с дугой, если оно есть, и меняет курсор, только если радиус изменился.
/mob/living/carbon/proc/ce_refresh_spread_ring()
	var/datum/extension/ce_spread_ring/ring = get_extension(src, /datum/extension/ce_spread_ring)
	var/obj/item/gun/gun = ce_get_spread_ring_gun()
	if(ring && gun && ring.refresh(gun))
		ring.show()


/**
 * Мышь вошла в `object` или её провели над ним с зажатой кнопкой: кольцо целится туда. Зовётся на
 * каждое движение мыши каждого игрока, и дуга здесь не считается: её держит кольцо.
 */
/mob/living/carbon/proc/ce_note_spread_hover(atom/object, params)
	var/datum/extension/ce_spread_ring/ring = get_extension(src, /datum/extension/ce_spread_ring)
	if(ring?.note_hover(object, params) && ring.update_radius())
		ring.show()


/// Курсор оружия с кольцом разброса держащего, если кольцо есть: `crosshair` — курсор апстрима.
/obj/item/gun/proc/ce_get_spread_ring_pointer(mob/user, crosshair)
	var/datum/extension/ce_spread_ring/ring = get_extension(user, /datum/extension/ce_spread_ring)
	if(!ring?.radius)
		return crosshair
	return ce_get_spread_ring_cursor(ring.radius, crosshair)

#undef CE_SPREAD_RING_MAX_RADIUS
#undef CE_SPREAD_RING_COLOR
#undef CE_SPREAD_RING_OUTLINE_COLOR
#undef CE_SPREAD_RING_RESIZE_DELAY
