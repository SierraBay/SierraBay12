/singleton/modpack/russian_names
	name = "Руссификация"
	desc = @{"Руссификация переменных name и desc"}

/atom
	var/name_rus
	var/desc_rus

/atom/Initialize(mapload, ...)
	. = ..()
	if(!name_rus) name_rus = name
	if(!desc_rus) desc_rus = desc
