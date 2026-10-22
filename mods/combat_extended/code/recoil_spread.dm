/*
	COMBAT_EXTENDED — разброс от отдачи: под долгим огнём стрелок теряет кучность.

	В Бэй разброс очереди записан в оружии списком (`dispersion`), по выстрелам очереди. Автоматический
	огонь — одиночные выстрелы подряд: каждый берёт первое число списка, и сколько бы стрелок ни держал
	спуск, разброс не растёт.

	Здесь, по образцу CEV Eris (`/mob/living/var/recoil`):
	- каждый выстрел с отдачей даёт стрелку стаки: сила отдачи оружия (`ce_get_recoil_strength()`, та
	  же, что толкает вид) на множитель навыка оружия (`ce_get_recoil_skill_mult()`);
	- стаки убывают сами, по одному за `ce_recoil_spread_decay_time`, стреляет стрелок или нет. Счёт
	  идёт по часам при чтении (`ce_get_recoil_stacks()`), без таймеров;
	- стак — `ce_recoil_spread_arc_per_stack` градусов дуги разброса сверх разброса оружия и навыка
	  (`ce_get_spread_arc()`). Больше `ce_recoil_spread_max_stacks` стаков не копится;
	- дугу снаряд запоминает в момент выстрела (`ce_recoil_arc`, оверрайд `process_accuracy()`): вектор
	  нацеливается тиком позже, когда стаки этого же выстрела уже начислены.

	Оружие без `screen_shake` — лучевое — и орудия мехов стаков не дают. Работает вместе с
	попиксельной стрельбой: дугу читает её прицел.
*/

/mob/living
	/// Стаки отдачи на момент `ce_recoil_stacks_time`. Сколько их сейчас — `ce_get_recoil_stacks()`.
	var/ce_recoil_stacks = 0
	/// Время, с которого идёт отсчёт до снятия следующего стака отдачи.
	var/ce_recoil_stacks_time = 0

/obj/item/projectile
	/// Дуга разброса от отдачи стрелка на момент выстрела, градусы.
	var/ce_recoil_arc = 0


/// Стаки отдачи стрелка на момент `now`: с начисленных снято по одному за каждый прошедший
/// `ce_recoil_spread_decay_time`. Больше начисленного их не бывает, каким бы ни было время отсчёта.
/mob/living/proc/ce_get_recoil_stacks(now = world.time)
	if(ce_recoil_spread_decay_time <= 0)
		return 0
	var/shed = floor((now - ce_recoil_stacks_time) / ce_recoil_spread_decay_time)
	return clamp(ce_recoil_stacks - shed, 0, ce_recoil_stacks)


/// Когда со стрелка сойдёт следующий стак отдачи после `now`: стаки сходят через каждые
/// `ce_recoil_spread_decay_time` от `ce_recoil_stacks_time`. Спрашивать, пока стаки есть.
/mob/living/proc/ce_get_next_recoil_shed_time(now = world.time)
	var/shed = floor((now - ce_recoil_stacks_time) / ce_recoil_spread_decay_time)
	return ce_recoil_stacks_time + (shed + 1) * ce_recoil_spread_decay_time


/// Дуга разброса от стаков отдачи стрелка на момент `now`, градусы.
/mob/living/proc/ce_get_recoil_arc(now = world.time)
	return ce_get_recoil_stacks(now) * ce_recoil_spread_arc_per_stack



/**
 * Начисляет стрелку `amount` стаков отдачи, не выше `ce_recoil_spread_max_stacks`. Отсчёт до снятия
 * следующего стака от выстрела не сбивается: стак снимается раз в срок, стреляет стрелок или нет. У
 * стрелка без стаков отсчёт начинается с этого выстрела.
 */
/mob/living/proc/ce_add_recoil_stacks(amount, now = world.time)
	var/kept = ce_get_recoil_stacks(now)
	if(kept)
		ce_recoil_stacks_time += (ce_recoil_stacks - kept) * ce_recoil_spread_decay_time
	else
		ce_recoil_stacks_time = now
	ce_recoil_stacks = min(kept + amount, ce_recoil_spread_max_stacks)


/// Множитель стаков отдачи по навыку оружия: за каждый уровень ниже обученного — больше на
/// `ce_recoil_spread_gain_per_skill`, выше — меньше. null — навыка у стрелка нет, множитель — единица.
/proc/ce_get_recoil_skill_mult(skill_level)
	if(isnull(skill_level))
		return 1
	return max(0, 1 + (SKILL_TRAINED - skill_level) * ce_recoil_spread_gain_per_skill)


/// Сколько стаков отдачи выстрел даёт стрелку: сила отдачи оружия на множитель его навыка.
/obj/item/gun/proc/ce_get_recoil_stack_gain(mob/user)
	return ce_get_recoil_strength(user) * ce_get_recoil_skill_mult(user.ce_get_shooter_skill())


/// Выстрел сделан: стрелок получает за него стаки отдачи.
/obj/item/gun/proc/ce_build_recoil(mob/living/user)
	var/gain = ce_get_recoil_stack_gain(user)
	if(gain)
		user.ce_add_recoil_stacks(gain)
