/*
	COMBAT_EXTENDED — состояние и жар брони при осмотре, её починка хламом и свечение раскалённой
	брони на носителе.

	Броня плитоноски живёт на пластинах и наручах, а осматривают обычно саму плитоноску, поэтому
	она показывает состояние и жар каждого видимого аксессуара. Латают её так же — кликом по
	плитоноске: `ce_try_armor_repair()` (`mods/combat_extended/code/armor_repair.dm`) выбирает
	аксессуар по зоне прицела.

	Горячую броню так же поливают хладагентом или водой: `ce_try_pour_coolant()`
	(`mods/combat_extended/code/laser_coolant.dm`).

	Свечение накладывает `ce_glow_worn_image()` (`mods/combat_extended/code/laser_heat.dm`), прожоги от
	лучей — `ce_draw_scorch_marks()` (`mods/combat_extended/code/laser_scorch.dm`).
	Пристёгнутые аксессуары рисуются своим оверрайдом, мимо этого, и светятся в
	`under/accessories/_accessory.dm`.
*/

/// Раньше подсумков плитоноски: хлам, которым латают изношенную броню, и хладагент для горячей брони
/// в подсумок не уходят.
/obj/item/clothing/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(ce_try_pour_coolant(tool, user))
		return TRUE
	if(ce_try_armor_repair(tool, user))
		return TRUE
	return ..()


/obj/item/clothing/examine(mob/user)
	. = ..()
	var/datum/extension/armor/armor = get_extension(src, /datum/extension/armor)
	for(var/line in armor?.ce_get_condition_lines())
		to_chat(user, SPAN_WARNING(line))
	for(var/line in armor?.ce_get_heat_lines())
		to_chat(user, SPAN_WARNING(line))

	// Аксессуар под верхней одеждой постороннему не виден, и состояние его брони — тоже
	// (`mods/combat_extended/code/concealed_accessories.dm`).
	for(var/line in ce_get_accessory_armor_lines(user))
		to_chat(user, SPAN_WARNING(line))


/obj/item/clothing/get_mob_overlay(mob/user_mob, slot)
	. = ..()
	ce_glow_worn_image(., slot)
	ce_draw_scorch_marks(., slot)
