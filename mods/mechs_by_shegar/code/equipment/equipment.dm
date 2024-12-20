/obj/item/mech_equipment
	/// Отвечает за то, мешает ли модуль посадке пассажира в занятый хардпоинт.
	var/disturb_passengers = FALSE
	icon = 'mods/mechs_by_shegar/icons/mech_equipment.dmi'
	///Сколько тепла выделяется за каждое использование этого модуля
	var/heat_generation = 0
	///Генерация тепла от модуля при активном состоянии оного
	var/active_heat_generation = 0

/obj/item/mech_equipment/proc/need_combat_skill()
	return FALSE

//Задача функции - проверить, может ли использоваться модуль. Код идентичен /obj/item/mech_equipment/afterattck
// Но данная функция написана для возможности модовых мехов
/obj/item/mech_equipment/proc/module_can_be_used(atom/target, mob/living/user, inrange)
	if(require_adjacent)
		if(!inrange)
			return FALSE
	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		if(target in owner.contents)
			return FALSE

		if(!(owner.get_cell()?.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return FALSE
		return TRUE
	else
		return FALSE
