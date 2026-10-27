/// Hooks RnD lab actions into Odyssey science briefs.
/// Defines are duplicated with ifndef guards because RnD compiles before Odyssey.

#ifndef ODYSSEY_SCI_BRIEF_SPECTRUM
#define ODYSSEY_SCI_BRIEF_SPECTRUM "spectrum"
#define ODYSSEY_SCI_BRIEF_CATALOG "catalog"
#define ODYSSEY_SCI_BRIEF_FLORA "flora"
#define ODYSSEY_SCI_BRIEF_SLIME "slime"
#endif

/// Set TRUE by Odyssey while a campaign round is active (avoids hard type dep on /datum/odyssey_state).
var/global/odyssey_science_enabled = FALSE


/proc/odyssey_rnd_active()
	return odyssey_science_enabled


/proc/odyssey_rnd_on_spectral_complete(obj/machinery/computer/rdconsole/console, mob/user, obj/item/sample, perfect)
	if (!odyssey_rnd_active() || !perfect)
		return
	var/evidence = sample ? "[sample.type]" : "spectral"
	odyssey_science_note_sample(evidence)
	odyssey_science_progress(ODYSSEY_SCI_BRIEF_SPECTRUM, 1, evidence, console, user)


/proc/odyssey_rnd_on_catalog_complete(obj/machinery/computer/rdconsole/console, mob/user, artifact_id, correct_count)
	if (!odyssey_rnd_active() || correct_count < 2)
		return
	odyssey_science_note_anomaly(artifact_id || "catalog")
	odyssey_science_progress(ODYSSEY_SCI_BRIEF_CATALOG, 1, artifact_id || "catalog", console, user)


/proc/odyssey_rnd_on_deconstruct(obj/machinery/computer/rdconsole/console, mob/user, obj/item/I)
	if (!odyssey_rnd_active() || !istype(I))
		return
	if (istype(I, /obj/item/slime_extract))
		odyssey_rnd_on_slime_extract_used(I, user, console)


/proc/odyssey_rnd_flora_gene_qualifies(datum/seed/S, genetype)
	if (!istype(S) || !genetype)
		return FALSE
	switch (genetype)
		if (GENE_SPECIAL)
			return !!S.get_trait(TRAIT_TELEPORTING)
		if (GENE_OUTPUT)
			return S.get_trait(TRAIT_BIOLUM) || S.get_trait(TRAIT_PRODUCES_POWER)
		if (GENE_FRUIT)
			return S.get_trait(TRAIT_STINGS) || S.get_trait(TRAIT_EXPLOSIVE)
		if (GENE_DIET)
			return S.get_trait(TRAIT_CARNIVOROUS) || S.get_trait(TRAIT_PARASITE)
	return FALSE


/proc/odyssey_rnd_on_flora_gene(mob/user, datum/seed/S, genetype, atom/source)
	if (!odyssey_rnd_active() || !genetype)
		return
	if (!odyssey_rnd_flora_gene_qualifies(S, genetype))
		return
	odyssey_science_note_sample("flora:[genetype]")
	odyssey_science_progress(ODYSSEY_SCI_BRIEF_FLORA, 1, genetype, source, user)


/proc/odyssey_rnd_on_slime_extract_used(obj/item/slime_extract/extract, mob/user = null, atom/source = null)
	if (!odyssey_rnd_active() || !istype(extract))
		return
	var/evidence = "[extract.type]"
	odyssey_science_note_sample(evidence)
	odyssey_science_progress(ODYSSEY_SCI_BRIEF_SLIME, 1, evidence, source || extract, user)


/// Replaces core slime reaction finish to also notify Odyssey science briefs.
/singleton/reaction/slime/on_reaction(datum/reagents/holder)
	..()
	var/obj/item/slime_extract/T = holder.my_atom
	if (!istype(T))
		return
	T.Uses--
	if (T.Uses <= 0)
		T.visible_message("[icon2html(T, viewers(get_turf(T)))][SPAN_NOTICE("\The [T]'s power is consumed in the reaction.")]")
		T.SetName("used slime extract")
		T.desc = "This extract has been used up."
	if (odyssey_science_enabled)
		odyssey_rnd_on_slime_extract_used(T)
