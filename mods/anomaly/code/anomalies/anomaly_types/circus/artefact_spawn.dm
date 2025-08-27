//Цирк всегда ставит артефакт в своём центре
/obj/anomaly/circus/born_artefact()
	var/obj/artefact = pickweight(artefacts)
	if(artefact)
		born_artefact_in_center(artefact)

/obj/anomaly/circus/proc/born_artefact_in_center(artefact)
	//Размещает артефакт в центре
	var/obj/item/artefact/spawned_artefact =  new artefact(get_turf(src))
	spawned_artefact.connected_to_anomaly = TRUE
	SSanom.artefacts_spawned_by_game++

	time_between_effects = 0.5 SECOND
