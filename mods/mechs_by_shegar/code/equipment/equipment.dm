/obj/item/mech_equipment
	/// Отвечает за то, мешает ли модуль посадке пассажира в занятый хардпоинт.
	var/disturb_passengers = FALSE
	icon = 'mods/mechs_by_shegar/icons/mech_equipment.dmi'
	///Сколько тепла выделяется за каждое использование этого модуля
	var/heat_generation = 0
	///Генерация тепла от модуля при активном состоянии оного
	var/active_heat_generation = 0
