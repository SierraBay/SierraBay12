/*
	COMBAT_EXTENDED — толчок вида от выстрела: порт отдачи OnyxBay (`directional_recoil()`).

	В Бэй выстрел трясёт камеру (`shake_camera()`): глаз клиента на пару тиков переставляется на
	случайную соседнюю клетку. Слабее целой клетки тряски не бывает, у пистолета и у пулемёта она одна
	и та же, а вызов, пришедший во время тряски, пропадает: очередь трясёт не сильнее одного выстрела.

	Здесь:
	- вид стрелка толкает от цели, на пиксели: `ce_view_kick_px_per_point` на очко силы, сила —
	  `screen_shake` оружия плюс единица, как в OnyxBay. Оружие без `screen_shake` вид не толкает;
	- толчок растёт со штрафом оружия за одну руку, `one_hand_penalty`: это единственное число Бэй,
	  которое отличает пистолет от винтовки и пулемёта. Без хвата двумя руками штраф считается
	  несколько раз (`ce_get_recoil_strength()`). В OnyxBay пистолет и пулемёт толкают одинаково;
	- толчок — одна цепочка анимации из относительных шагов: туда, пауза, обратно
	  (`ce_play_view_kick()`). Вид возвращается туда, где был, — и на сдвиг прицела, если стрелок
	  смотрит в него, — а толчки очереди складываются. В OnyxBay возврат шёл в ноль и сдвиг вида
	  сбрасывал;
	- орудия мехов вид не толкают и камеру не трясут.

	Зовётся из кор `handle_post_fire()`, правка `[SIERRA-EDIT]`: толчок встаёт на место тряски.
	Тряска от попаданий и взрывов остаётся прежней.
*/

/// Орудие стоит на мехе, в его модуле.
/obj/item/gun/proc/ce_is_mech_mounted()
	return istype(loc, /obj/item/mech_equipment)


/// Оружие держат двумя руками, и стрелку оно по силам, — то же условие, по которому кор `Fire()`
/// снимает штраф точности за одну руку.
/obj/item/gun/proc/ce_is_braced(mob/living/user)
	return istype(user) && user.can_wield_item(src) && is_held_twohanded(user)


/**
 * Сила отдачи выстрела, очки: `screen_shake` плюс единица — и больше на долю `one_hand_penalty` от
 * `ce_view_kick_penalty_divisor`: чем тяжелее оружие в руках, тем сильнее оно толкает. Без хвата
 * двумя руками штраф считается `ce_view_kick_one_hand_penalty_mult` раз. Ноль — отдачи нет: у
 * оружия нет `screen_shake` либо оно стоит на мехе. Силой меряется и толчок вида, и стаки отдачи
 * стрелка (`recoil_spread.dm`).
 */
/obj/item/gun/proc/ce_get_recoil_strength(mob/user)
	if(!screen_shake || ce_is_mech_mounted())
		return 0
	var/penalty = one_hand_penalty
	if(!ce_is_braced(user))
		penalty *= ce_view_kick_one_hand_penalty_mult
	return (screen_shake + 1) * (1 + penalty / ce_view_kick_penalty_divisor)


/// Длина толчка вида от выстрела, пиксели: `ce_view_kick_px_per_point` на очко силы отдачи
/// (`ce_get_recoil_strength()`). Ноль — оружие вид не толкает.
/obj/item/gun/proc/ce_get_view_kick_reach(mob/user)
	return ce_get_recoil_strength(user) * ce_view_kick_px_per_point


/**
 * Толчок вида от выстрела по `target` без случайного сдвига, пиксели: `list(x, y)`, от цели. null —
 * оружие вид не толкает. У выстрела в свою клетку направления нет: толчок нулевой, от него остаётся
 * один случайный сдвиг.
 */
/obj/item/gun/proc/ce_get_view_kick(mob/user, atom/target)
	RETURN_TYPE(/list)
	var/reach = ce_get_view_kick_reach(user)
	if(!reach)
		return null
	var/turf/from_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!from_turf || !target_turf || from_turf == target_turf)
		return list(0, 0)
	var/angle = Get_Angle(from_turf, target_turf)
	return list(-sin(angle) * reach, -cos(angle) * reach)


/**
 * Толкает вид стрелка от цели. Возвращает TRUE: толчок встал на место тряски камеры Бэй, — и у
 * орудия меха, которое вид не толкает вовсе, и у стрелка без клиента.
 */
/obj/item/gun/proc/ce_kick_view(mob/user, atom/target)
	var/list/kick = ce_get_view_kick(user, target)
	if(!kick || !user.client)
		return TRUE
	var/jitter = ce_get_view_kick_reach(user) * ce_view_kick_jitter_share
	ce_play_view_kick(user.client, kick[1] + (rand() * 2 - 1) * jitter, kick[2] + (rand() * 2 - 1) * jitter)
	return TRUE


/**
 * Проигрывает толчок на клиенте `viewer`: вид уходит на `kick_x`, `kick_y` пикселей, держится и
 * возвращается.
 *
 * Все три шага относительные и ставятся разом, параллельно тому, что уже играет. Своего места вид
 * не запоминает: толчок прибавляется к сдвигу, какой есть, и вычитается из него же. Поэтому вид в
 * прицел остаётся в прицеле, а толчки очереди складываются. С запомненным местом второй выстрел
 * очереди запомнил бы вид, уже сдвинутый первым, и вернул бы его туда.
 */
/proc/ce_play_view_kick(viewer, kick_x, kick_y)
	animate(viewer, pixel_x = kick_x, pixel_y = kick_y, time = ce_view_kick_out_time, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	animate(pixel_x = 0, pixel_y = 0, time = ce_view_kick_hold_time, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -kick_x, pixel_y = -kick_y, time = ce_view_kick_back_time, easing = SINE_EASING | EASE_IN, flags = ANIMATION_RELATIVE)
