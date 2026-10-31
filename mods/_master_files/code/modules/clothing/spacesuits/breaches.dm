/*
	COMBAT_EXTENDED — починка брони скафандра хламом (`mods/combat_extended/code/armor_repair.dm`).

	Кор `use_tool()` скафандра забирает сталь, прутья, сварку и скотч на пробоины, даже когда
	пробоин нет, и до `use_tool()` одежды они не доходят. Поэтому броню скафандра латают здесь,
	раньше кор кода, — но только без пробоин: сначала герметичность, потом броня.
*/

/obj/item/clothing/suit/space/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(!ce_has_breaches() && ce_try_armor_repair(tool, user))
		return TRUE
	return ..()
