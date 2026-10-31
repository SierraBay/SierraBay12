/*
	COMBAT_EXTENDED — тот, кто смотрит в прицел или бинокль, не поворачивается
	(`mods/combat_extended/code/scopes.dm`): ни клавишами, ни щелчком по цели — `face_atom()` зовёт
	`facedir()`, — ни сменой замка направления. Здесь, а не в моде: `facedir()` у живых переписывает
	модпак `vision_cone` без `..()`, а `_master_files` подключается после модов.
*/
/mob/living/facedir(ndir)
	if(ce_scope_item)
		return 0
	return ..()

/mob/living/set_face_dir(newdir)
	if(ce_scope_item)
		return
	return ..()
