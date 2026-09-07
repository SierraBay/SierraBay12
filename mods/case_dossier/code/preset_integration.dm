#define INSTALL_CASE_DOSSIER \
	var/datum/extension/interactive/ntos/os = get_extension(src, /datum/extension/interactive/ntos); \
	if(os) os.create_file(new /datum/computer_file/program/punishment_log());

/obj/machinery/computer/modular/preset/security/Initialize()
	. = ..()
	INSTALL_CASE_DOSSIER

/obj/machinery/computer/modular/preset/cardslot/command_sec/Initialize()
	. = ..()
	INSTALL_CASE_DOSSIER

/obj/machinery/computer/modular/preset/full/ert/Initialize()
	. = ..()
	INSTALL_CASE_DOSSIER

#undef INSTALL_CASE_DOSSIER
