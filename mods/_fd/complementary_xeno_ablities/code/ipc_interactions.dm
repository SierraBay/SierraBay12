/datum/species/machine/get_facial_hair_styles(gender)
	return list()

/atom/proc/open_mirror_ui(obj/item/mirror, mob/living/carbon/human/user, list/ui_cache)
	if (!istype(user))
		return

	if (user.get_species() == SPECIES_IPC)
		to_chat(user, SPAN_WARNING("Как ты планируешь прихорашивать свой металлический корпус?"))
		return

	var/W = weakref(user)
	var/datum/nano_module/appearance_changer/changer = LAZYACCESS(ui_cache, W)

	if (!changer)
		changer = new(user, APPEARANCE_HEAD|APPEARANCE_FACE)
		changer.name = "SalonPro Nano-Mirror"
		LAZYSET(ui_cache, W, changer)

	changer.ui_interact(user)
