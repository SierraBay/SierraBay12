/obj/item/artefact
	name = "Что-то."
	desc = "Какой-то камень."
	icon = 'mods/anomaly/icons/artifacts.dmi'
	///Текущее количество энергии, которое хранит артефакт
	var/stored_energy = 1000
	///Максимальное количество ЭНЕРГИИ, которое хранит артефакт
	var/max_stored_energy = 1000
	var/cargo_price = 100
	var/rnd_points = 2000

//Жар
/obj/item/artefact/zjar
	name = "Something"
	desc = "При поднятии вы чувствуете, словно по вашему телу распростаняется приятное тепло."
	icon_state = "fire_ball"

//Грави
/obj/item/artefact/gravi
	name = "Something"
	desc = "При поднятии вы чувствуете, словно сам воздух вокруг вас становится плотнее."
	icon_state = "gravi"

//Светлячок
/obj/item/artefact/svetlyak
	name = "Something"
	desc = "Невероятно яркий, вы с трудом смотрите на него даже с зажмуренными глазами."
	icon_state = "svetlyak"
