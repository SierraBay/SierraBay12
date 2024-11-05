
/proc/examinate(mob/user, atom/A)
	if ((is_blind(user) || user.stat) && !isobserver(user))
		to_chat(user, SPAN_NOTICE("Something is there but you can't see it."))
		return
	user.face_atom(A)
	if (user.simulated)
		if (A.loc != user || user.IsHolding(A))
			for (var/mob/M in viewers(4, user))
				if (M == user)
					continue
				if (M.client && M.client.get_preference_value(/datum/client_preference/examine_messages) == GLOB.PREF_SHOW)
					if (M.is_blind() || user.is_invisible_to(M))
						continue
					to_chat(M, SPAN_SUBTLE("<b>\The [user]</b> looks at \the [A]."))
	var/distance = INFINITY
	var/is_adjacent = FALSE
	if (isghost(user) || user.stat == DEAD)
		distance = 0
		is_adjacent = TRUE
	else
		var/turf/source_turf = get_turf(user)
		var/turf/target_turf = get_turf(A)
		if (source_turf && source_turf.z == target_turf?.z)
			distance = get_dist(source_turf, target_turf)
		is_adjacent = user.Adjacent(A)
	if (!A.examine(user, distance, is_adjacent))
		crash_with("Improper /examine() override: [log_info_line(A)]")
	if (!A.LateExamine(user, distance, is_adjacent))
		crash_with("Improper /LateExamine() override: [log_info_line(A)]")
//[SIERRA-ADD]
	if(user.is_species(SPECIES_IPC))
		ecscamera(user, A)


/proc/ecscamera(mob/living/carbon/human/user, atom/A)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = user
		if(M.internal_organs_by_name[BP_EXONET])
			var/obj/item/organ/internal/ecs/ecs = M.internal_organs_by_name[BP_EXONET]
			if(ecs.computer.in_camera_mode)
				ecs.computer.hard_drive.create_file(ecs.computer.camera.captureimagecomputer(A, usr))
				to_chat(usr, SPAN_NOTICE("You took a photo of \the [A]."))
//[/SIERRA-ADD]

/mob/proc/ForensicsExamination(atom/A, distance, is_adjacent)
	if (!(get_skill_value(SKILL_FORENSICS) >= SKILL_EXPERIENCED && distance <= (get_skill_value(SKILL_FORENSICS) - SKILL_TRAINED)))
		return

	var/clue = FALSE
	if (LAZYLEN(A.suit_fibers))
		to_chat(src, SPAN_NOTICE("You notice some fibers embedded in \the [A]."))
		clue = TRUE
	if (LAZYLEN(A.fingerprints))
		to_chat(src, SPAN_NOTICE("You notice a partial print on \the [A]."))
		clue = TRUE
	if (LAZYLEN(A.gunshot_residue))
		GunshotResidueExamination(A)
		clue = TRUE
	// Noticing wiped blood is a bit harder
	if ((get_skill_value(SKILL_FORENSICS) >= SKILL_MASTER) && LAZYLEN(A.blood_DNA))
		to_chat(src, SPAN_WARNING("You notice faint blood traces on \the [A]."))
		clue = TRUE
	if (clue && has_client_color(/datum/client_color/noir))
		playsound_local(null, pick('sound/effects/clue1.ogg','sound/effects/clue2.ogg'), 60, is_global = TRUE)


/mob/proc/GunshotResidueExamination(atom/A)
	to_chat(src, SPAN_NOTICE("You notice a faint acrid smell coming from \the [A]."))

/mob/living/GunshotResidueExamination(atom/A)
	if (isSynthetic())
		to_chat(src, SPAN_NOTICE("You notice faint black residue on \the [A]."))
	else
		to_chat(src, SPAN_NOTICE("You notice a faint acrid smell coming from \the [A]."))

/mob/living/silicon/GunshotResidueExamination(atom/A)
	to_chat(src, SPAN_NOTICE("You notice faint black residue on \the [A]."))
