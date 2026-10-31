/*
	COMBAT_EXTENDED — прицел и бинокль.

	Кнопка. Прицел оружия включался только глаголом `Use Scope`: его надо набрать в чате или найти в
	меню правого щелчка. Теперь у оружия с прицелом (`scope_zoom`) и у бинокля есть кнопка, как уже
	была у линз-аугмента. Кнопка показывает спрайт самой вещи, как у всех кнопок вещей. Нажатие у
	оружия — то же, что глагол: `toggle_scope()` с увеличением прицела. Глагол остаётся. Кнопку, как
	у любой вещи, дают руки, спина, пояс и карманы, а смотреть в прицел или бинокль можно только из
	активной руки — иначе об этом скажет кор `zoom()`.

	Стойка прицела. Кор `zoom()` снимает прицел с любым перемещением и поворотом держащего. Теперь,
	пока он смотрит в вещь (`ce_start_scope_stance()`):
	- направление заперто замком Face Direction (`facing_dir`, `face_dir_click` модпака
	  `vision_cone`): шаг его не меняет, и держащий ходит боком и спиной вперёд;
	- свой шаг прицел не снимает (`ce_is_own_scope_step()`), а любое другое перемещение — тянут,
	  толкают, бросили, несёт в невесомости, лестница, телепорт — снимает, как в Бэй;
	- повернуться нельзя: ни клавишами, ни щелчком по цели, ни боевым режимом, ни сменой замка
	  (оверрайды `facedir()` и `set_face_dir()`, проверка в `combat_face_mouse()`). Повернуло всё же
	  чем-то ещё — прицел снимет кор, по `dir_set_event`;
	- шаг не быстрее крадущегося и ещё на `ce_scope_step_delay` медленнее, а бегать нельзя;
	- оружие держит точность прицела (`scoped_accuracy`) только у того, кто простоял на месте
	  `ce_scope_settle_time`, а иначе стреляет с точностью без прицела.
	Стойка — у любой вещи с `zoom()`: прицела, бинокля, линз-аугмента. Без неё — у моба, который не
	`/mob/living`, — прицел работает как в Бэй.
*/

/// Название кнопки прицела у оружия — как у глагола.
#define CE_SCOPE_ACTION_NAME "Use Scope"

// Бинокль смотрит через `attack_self()`, а его кнопка по умолчанию зовёт его же. Название — как у
// линз-аугмента (`/obj/item/clothing/glasses/augment_binoculars`).
/obj/item/device/binoculars
	action_button_name = "Toggle zoom"

/obj/item
	/// Тот, кто смотрит в эту вещь, пока смотрит (`ce_start_scope_stance()`).
	var/mob/living/ce_scope_holder

/obj/item/gun
	/// Точность, которую дал оружию прицел (`toggle_scope()`), пока в него смотрят. Запоминается к
	/// первому выстрелу в прицел (`ce_settle_scope_accuracy()`); null — ещё не запомнена.
	var/ce_scope_accuracy

/mob/living
	/// Вещь, в которую он сейчас смотрит. Пока она есть, он не поворачивается.
	var/obj/item/ce_scope_item
	/// Направление, запертое прицелом.
	var/ce_scope_dir
	/// `facing_dir` до прицела: снятый прицел его вернёт.
	var/ce_scope_saved_facing_dir
	/// `face_dir_click` до прицела: снятый прицел его вернёт.
	var/ce_scope_saved_face_dir_click


// --- Кнопка ---

/// Даёт кнопку прицела оружию, у которого он есть. Своя кнопка у оружия, если она есть, остаётся.
/// Зовёт `Initialize()` (`mods/_master_files/code/modules/projectiles/gun.dm`).
/obj/item/gun/proc/ce_add_scope_action()
	if(scope_zoom && !action_button_name)
		action_button_name = CE_SCOPE_ACTION_NAME


/// Кнопка этого оружия — кнопка прицела.
/obj/item/gun/proc/ce_has_scope_action()
	return scope_zoom && action_button_name == CE_SCOPE_ACTION_NAME


// --- Стойка прицела ---

/**
 * Держащий начал смотреть в вещь. Зовёт оверрайд `zoom()` (`mods/_master_files/code/game/objects/items.dm`),
 * когда кор `zoom()` удался: тот снимает прицел с любым перемещением держащего, а здесь свой шаг его
 * не снимает.
 */
/obj/item/proc/ce_start_scope_stance(mob/living/holder)
	ce_scope_holder = holder
	holder.ce_scope_item = src
	GLOB.moved_event.unregister(holder, src, TYPE_PROC_REF(/obj/item, unzoom))
	GLOB.moved_event.register(holder, src, PROC_REF(ce_on_scope_holder_moved))
	holder.ce_lock_scope_facing()
	if(MOVING_QUICKLY(holder))
		holder.set_moving_slowly()


/// Держащий перестал смотреть в вещь. Зовёт оверрайд `unzoom()`, когда прицел снят.
/obj/item/proc/ce_end_scope_stance()
	var/mob/living/holder = ce_scope_holder
	ce_scope_holder = null
	GLOB.moved_event.unregister(holder, src, PROC_REF(ce_on_scope_holder_moved))
	if(holder.ce_scope_item == src)
		holder.ce_scope_item = null
		holder.ce_unlock_scope_facing()


/obj/item/gun/ce_end_scope_stance()
	..()
	ce_scope_accuracy = null


/// Держащий переместился: свой шаг прицел не снимает, всё остальное — снимает.
/obj/item/proc/ce_on_scope_holder_moved(atom/movable/mover, atom/old_loc, atom/new_loc)
	if(!ce_scope_holder.ce_is_own_scope_step(mover, old_loc, new_loc))
		unzoom(ce_scope_holder)


/**
 * Шаг, который прицел не снимает: моб сам шагнул в соседнюю клетку на том же уровне. `moving` ставит
 * его собственный шаг на всё время шага (`/datum/movement_handler/mob/movement/DoMove()`). Кого
 * тянут, толкают, бросили или несёт в невесомости, тот сам не шагает, а лестница и телепорт уводят
 * дальше соседней клетки или на другой уровень.
 */
/mob/living/proc/ce_is_own_scope_step(atom/movable/mover, atom/old_loc, atom/new_loc)
	if(mover != src || !moving || loc != new_loc)
		return FALSE
	if(!isturf(old_loc) || !isturf(new_loc) || old_loc.z != new_loc.z)
		return FALSE
	return get_dist(old_loc, new_loc) <= 1


/**
 * Запирает направление замком Face Direction: шаг его не меняет (`/mob/set_dir()` модпака
 * `vision_cone`). Замок, который был до прицела, запоминается.
 */
/mob/living/proc/ce_lock_scope_facing()
	ce_scope_saved_facing_dir = facing_dir
	ce_scope_saved_face_dir_click = face_dir_click
	ce_scope_dir = dir
	facing_dir = dir
	face_dir_click = dir
	ce_refresh_facing_button()


/**
 * Снимает замок прицела и возвращает тот, что был до прицела. Если замок за это время сменил кто-то
 * другой — выключили боевой режим, моб упал, — его не трогаем.
 */
/mob/living/proc/ce_unlock_scope_facing()
	if(facing_dir == ce_scope_dir && face_dir_click == ce_scope_dir)
		facing_dir = ce_scope_saved_facing_dir
		face_dir_click = ce_scope_saved_face_dir_click
	ce_scope_dir = null
	ce_scope_saved_facing_dir = null
	ce_scope_saved_face_dir_click = null
	ce_refresh_facing_button()


/**
 * Кнопка шага показывает замок направления. Её `on_update_icon()` читает замок у `usr`, а прицел
 * снимают и чужие действия — толчок, рывок за руку, — поэтому она перерисовывается от имени самого
 * моба.
 */
/mob/living/proc/ce_refresh_facing_button()
	var/obj/screen/movement/button = hud_used?.move_intent
	if(!istype(button))
		return
	usr = src
	button.update_icon()


/**
 * Сколько децисекунд прибавляет к шагу прицел: шаг не быстрее крадущегося и ещё на
 * `ce_scope_step_delay` медленнее. Ноль, пока моб не смотрит в прицел.
 */
/mob/living/proc/ce_get_scope_step_delay(singleton/move_intent/using_intent)
	if(!ce_scope_item)
		return 0
	if(!using_intent)
		using_intent = move_intent
	if(ispath(using_intent))
		using_intent = GET_SINGLETON(using_intent)
	var/singleton/move_intent/creep = GET_SINGLETON(/singleton/move_intent/creep)
	return max(creep.move_delay - using_intent.move_delay, 0) + ce_scope_step_delay


// Здесь, а не в `mods/_master_files/code/modules/mob/living/carbon/human/human_movement.dm`: тот
// файл в сборку не подключён, а подключить его — значит включить всем и прибавку Сьерры к шагу с
// замком направления.
/mob/living/carbon/human/movement_delay(singleton/move_intent/using_intent = move_intent)
	. = ..()
	. += ce_get_scope_step_delay(using_intent)


// --- Точность прицела ---

/**
 * Прицел даёт оружию свою точность только тому, кто простоял `ce_scope_settle_time` без шага, а
 * шагнувший стреляет с точностью оружия без прицела, как после `unzoom()`. Зовёт оверрайд
 * `process_accuracy()` до кор версии: та читает `accuracy`.
 *
 * Точность прицела ставит оружию кор `toggle_scope()`, сразу после `zoom()`, и до выстрела её никто
 * не меняет: к первому выстрелу она запоминается.
 */
/obj/item/gun/proc/ce_settle_scope_accuracy(mob/living/user)
	if(!ce_scope_holder)
		return
	if(isnull(ce_scope_accuracy))
		ce_scope_accuracy = accuracy
	accuracy = user.ce_moved_within(ce_scope_settle_time) ? initial(accuracy) : ce_scope_accuracy

#undef CE_SCOPE_ACTION_NAME
