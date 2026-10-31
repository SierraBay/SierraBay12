/*
	COMBAT_EXTENDED — подкожная броня (`code/modules/augment/passive/armor.dm`).

	В Bay это не броня, а множитель `brute_mult` в `get_brute_mod()` каждой конечности. Он гасит
	долю любого физического урона уже после брони, от ножа и от винтовки поровну, не тратит
	пробитие и не бережёт органы. Мод делает сетку слоем брони, как импланты в CE — прибавкой к
	естественной броне на всё тело:

	- слой закрывает всё тело, протезы тоже — как `brute_mult` в Bay;
	- слой самый внутренний: под одеждой, корпусом протеза и естественной бронёй вида;
	- `brute_mult` снят (`code/items/armor/augments.dm`), чтобы защита не считалась дважды;
	- сетка уплотняет ткани (`ce_density_rha`): прошедшее слой хуже достаёт до органов. Это взамен
	  той части множителя, что гасила падения и взрывы, — их слой не видит.

	Жёсткость — по носителю: обычная сетка мягкая, хитин генокрада — в `ce_hard_armor_holders`.
	Орган не изнашивается (`ce_can_wear()`), чинить сетку не нужно.

	Касание — тычок дубинкой без урона — сетка не держит (`ce_armor_stops_contact()`): оно
	приходится на кожу, а сетка под ней. Иначе сетка на всё тело делала бы носителя неуязвимым
	для тычков в любую зону. Удар с уроном она гасит, как любая броня, и боль с оглушением — по
	доле прошедшего урона.
*/

/obj/item/organ/internal/augment/armor
	/// Острая плотность, которую броня добавляет к тканям всего тела, мм RHA.
	var/ce_density_rha = 0


/// Лежит ли броня под кожей: касание до неё не доходит.
/datum/extension/armor/proc/ce_is_under_skin()
	return istype(holder, /obj/item/organ/internal/augment/armor)


/// Слои подкожной брони. Закрывают любую зону.
/mob/living/carbon/human/proc/ce_get_subdermal_armors()
	. = list()
	for(var/obj/item/organ/internal/augment/armor/mesh in internal_organs)
		var/datum/extension/armor/mesh_armor = get_extension(mesh, /datum/extension/armor)
		if(mesh_armor)
			. += mesh_armor


/// Плотность, которую подкожная броня добавляет к тканям любой части тела, мм RHA.
/mob/living/carbon/human/proc/ce_get_subdermal_density()
	. = 0
	for(var/obj/item/organ/internal/augment/armor/mesh in internal_organs)
		. += mesh.ce_density_rha
