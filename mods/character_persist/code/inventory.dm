/// Odyssey-only worn/carried inventory persist between shifts.

/datum/job/get_unavailable_reasons(client/user)
	. = ..()
	var/locked_job = character_persist_odyssey_locked_job(user)
	if (!locked_job)
		return
	if (title == locked_job || title == CHARACTER_PERSIST_ODYSSEY_CREWMAN_TITLE)
		return
	if (!islist(.))
		. = list()
	.["Odyssey: this character is locked to [locked_job] or Crewman."] = TRUE


/datum/job/is_available(client/user)
	. = ..()
	if (!.)
		return
	var/locked_job = character_persist_odyssey_locked_job(user)
	if (!locked_job)
		return
	if (title != locked_job && title != CHARACTER_PERSIST_ODYSSEY_CREWMAN_TITLE)
		return FALSE


/proc/character_persist_inventory_path_denied(path)
	if (!ispath(path, /obj/item))
		return TRUE
	if (ispath(path, /obj/item/card/id))
		return TRUE
	if (ispath(path, /obj/item/modular_computer))
		return TRUE
	if (ispath(path, /obj/item/device/radio/headset))
		return TRUE
	if (ispath(path, /obj/item/storage/secure/safe/character_persist))
		return TRUE
	if (ispath(path, /obj/item/grab))
		return TRUE
	if (ispath(path, /obj/item/organ))
		return TRUE
	if (ispath(path, /obj/item/disk/nuclear))
		return TRUE
	if (ispath(path, /obj/item/pinpointer))
		return TRUE
	if (ispath(path, /obj/item/blueprints))
		return TRUE
	if (ispath(path, /obj/item/storage/backpack/holding))
		return TRUE
	if (ispath(path, /obj/item/paper/admin))
		return TRUE
	return FALSE


/proc/character_persist_inventory_photos_path(ckey, slot, for_odyssey = FALSE)
	if (!ckey || !slot)
		return null
	var/map_key = GLOB.using_map?.preferences_key()
	if (!map_key)
		return null
	var/suffix = for_odyssey ? "_odyssey" : ""
	return "data/player_saves/[copytext_char(ckey, 1, 2)]/[ckey]/character_persist_[map_key]_[slot][suffix]_inventory_photos.sav"


/proc/character_persist_inventory_denied(obj/item/I)
	if (!istype(I) || QDELETED(I))
		return TRUE
	return character_persist_inventory_path_denied(I.type)


/proc/character_persist_odyssey_locked_job(client/user)
	if (!istype(user) || !character_persist_use_odyssey_lane())
		return null
	var/datum/preferences/prefs = user.prefs
	if (!istype(prefs) || !prefs.character_persist)
		return null
	var/list/snapshot = prefs.character_persist_snapshot
	if (!islist(snapshot) || !odyssey_snapshot_valid(snapshot))
		snapshot = character_persist_read(prefs.client_ckey, prefs.default_slot, TRUE)
	if (!islist(snapshot))
		return null
	var/job_title = snapshot["assigned_job"]
	if (!istext(job_title) || !length(job_title))
		return null
	return job_title


/proc/character_persist_should_restore_inventory(mob/living/carbon/human/H)
	if (!istype(H) || !character_persist_use_odyssey_lane())
		return FALSE
	if (character_persist_is_virtual_body(H) || character_persist_is_offstation_antag(H))
		return FALSE
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	if (!ckey || !slot)
		return FALSE
	var/datum/preferences/prefs = character_persist_prefs_of(ckey)
	if (!prefs || !prefs.character_persist)
		return FALSE
	var/list/snapshot = prefs.character_persist_snapshot
	if (!islist(snapshot) || !odyssey_snapshot_valid(snapshot))
		snapshot = character_persist_read(ckey, slot, TRUE)
	if (!islist(snapshot) || !islist(snapshot["inventory"]))
		return FALSE
	if (!length(snapshot["inventory"]))
		return FALSE
	var/datum/odyssey_state/state = odyssey_ensure_state()
	var/key = odyssey_roster_key(ckey, slot)
	var/list/roster_entry = state.roster?[key]
	// Literal "brig" — Odyssey define loads after this modpack.
	if (islist(roster_entry) && roster_entry["custody"] == "brig")
		return FALSE
	return TRUE


/proc/character_persist_inventory_slot_of(mob/living/carbon/human/H, obj/item/I)
	if (!istype(H) || !istype(I))
		return null
	if (H.back == I)
		return slot_back
	if (H.wear_mask == I)
		return slot_wear_mask
	if (H.belt == I)
		return slot_belt
	if (H.wear_id == I)
		return slot_wear_id
	if (H.l_ear == I)
		return slot_l_ear
	if (H.r_ear == I)
		return slot_r_ear
	if (H.glasses == I)
		return slot_glasses
	if (H.gloves == I)
		return slot_gloves
	if (H.head == I)
		return slot_head
	if (H.shoes == I)
		return slot_shoes
	if (H.wear_suit == I)
		return slot_wear_suit
	if (H.w_uniform == I)
		return slot_w_uniform
	if (H.l_store == I)
		return slot_l_store
	if (H.r_store == I)
		return slot_r_store
	if (H.s_store == I)
		return slot_s_store
	if (H.l_hand == I)
		return slot_l_hand
	if (H.r_hand == I)
		return slot_r_hand
	if (H.handcuffed == I)
		return slot_handcuffed
	return null


/proc/character_persist_next_inventory_id(list/counter)
	if (!islist(counter))
		return "inv-1"
	counter["n"] = (counter["n"] || 0) + 1
	return "inv-[counter["n"]]"


/proc/character_persist_serialize_inventory_item(obj/item/I, storage_id, list/counter, depth, savefile/photos, list/photo_counter)
	if (character_persist_inventory_denied(I))
		return null
	if (depth > CHARACTER_PERSIST_INVENTORY_MAX_DEPTH)
		return null
	var/id = character_persist_next_inventory_id(counter)
	var/list/entry = list(
		"id" = id,
		"type" = "[I.type]"
	)
	if (storage_id)
		entry["storage_id"] = storage_id
	if (I.name != initial(I.name))
		entry["name"] = I.name
	if (I.color)
		entry["color"] = "[I.color]"
	if (istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		var/amount = S.get_amount()
		if (!isnum(amount) || amount < 1)
			return null
		entry["amount"] = amount
	if (istype(I, /obj/item/reagent_containers))
		entry["reagents"] = character_persist_safe_serialize_reagents(I)
	if (istype(I, /obj/item/spacecash))
		var/obj/item/spacecash/cash = I
		entry["worth"] = cash.worth
		if (istype(cash, /obj/item/spacecash/ewallet))
			var/obj/item/spacecash/ewallet/E = cash
			entry["owner_name"] = E.owner_name || ""
	if (istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		var/info_text = P.info || ""
		if (length(info_text) > CHARACTER_PERSIST_INVENTORY_MAX_PAPER_INFO)
			info_text = copytext(info_text, 1, CHARACTER_PERSIST_INVENTORY_MAX_PAPER_INFO + 1)
		entry["info"] = info_text
		entry["title"] = P.name
		if (P.stamps)
			entry["stamps"] = P.stamps
		if (islist(P.stamped))
			var/list/stamped_paths = list()
			for (var/stamp_type in P.stamped)
				stamped_paths += "[stamp_type]"
			entry["stamped"] = stamped_paths
		if (istype(P.language))
			entry["language"] = P.language.name
		else if (istext(P.language))
			entry["language"] = P.language
	if (istype(I, /obj/item/photo))
		var/obj/item/photo/Ph = I
		entry["scribble"] = Ph.scribble || ""
		entry["photo_size"] = Ph.photo_size || 3
		if (Ph.desc)
			entry["desc"] = Ph.desc
		if (photos && islist(photo_counter))
			var/pid = "inv_p[photo_counter[1]++]"
			entry["photo_id"] = pid
			if (isicon(Ph.img))
				character_persist_safe_write_photo(photos, pid, Ph.img)
			if (isicon(Ph.tiny))
				character_persist_safe_write_photo(photos, "[pid]_tiny", Ph.tiny)
	if (istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if (islist(C.accessories) && length(C.accessories))
			var/list/acc = list()
			for (var/obj/item/clothing/accessory/A in C.accessories)
				if (!istype(A) || character_persist_inventory_denied(A))
					continue
				acc += "[A.type]"
			if (length(acc))
				entry["accessories"] = acc
	return entry


/proc/character_persist_collect_inventory_item(obj/item/I, list/entries, list/counter, storage_id, depth, list/item_count, savefile/photos, list/photo_counter)
	if (!istype(I) || character_persist_inventory_denied(I))
		return
	if (item_count["n"] >= CHARACTER_PERSIST_INVENTORY_MAX_ITEMS)
		return
	var/list/entry = character_persist_serialize_inventory_item(I, storage_id, counter, depth, photos, photo_counter)
	if (!islist(entry))
		return
	item_count["n"] = (item_count["n"] || 0) + 1
	entries += list(entry)
	var/pid = entry["id"]
	if (istype(I, /obj/item/storage))
		for (var/obj/item/child in I)
			character_persist_collect_inventory_item(child, entries, counter, pid, depth + 1, item_count, photos, photo_counter)
	if (istype(I, /obj/item/folder))
		for (var/obj/item/child in I)
			character_persist_collect_inventory_item(child, entries, counter, pid, depth + 1, item_count, photos, photo_counter)
	if (istype(I, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = I
		if (islist(B.pages))
			for (var/obj/item/page in B.pages)
				character_persist_collect_inventory_item(page, entries, counter, pid, depth + 1, item_count, photos, photo_counter)
	if (istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if (istype(S.pockets))
			for (var/obj/item/child in S.pockets)
				character_persist_collect_inventory_item(child, entries, counter, pid, depth + 1, item_count, photos, photo_counter)
	if (istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if (islist(C.accessories))
			for (var/obj/item/clothing/accessory/storage/A in C.accessories)
				if (!istype(A.container))
					continue
				for (var/obj/item/child in A.container)
					character_persist_collect_inventory_item(child, entries, counter, pid, depth + 1, item_count, photos, photo_counter)


/proc/character_persist_capture_inventory(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	var/for_odyssey = character_persist_use_odyssey_lane()
	var/list/entries = list()
	var/list/counter = list("n" = 0)
	var/list/item_count = list("n" = 0)
	var/list/photo_counter = list(1)
	var/savefile/photos
	var/photo_path = character_persist_inventory_photos_path(ckey, slot, for_odyssey)
	if (photo_path)
		if (fexists(photo_path))
			fdel(photo_path)
		photos = new /savefile(photo_path)
	for (var/obj/item/I in H.get_equipped_items(TRUE))
		if (character_persist_inventory_denied(I))
			continue
		var/slot_id = character_persist_inventory_slot_of(H, I)
		var/list/before = length(entries)
		character_persist_collect_inventory_item(I, entries, counter, null, 1, item_count, photos, photo_counter)
		if (length(entries) > before && slot_id)
			var/list/root = entries[before + 1]
			if (islist(root) && !root["storage_id"])
				root["slot"] = slot_id
	if (!length(entries))
		if (photo_path && fexists(photo_path))
			fdel(photo_path)
		return null
	return entries


/proc/character_persist_spawn_inventory_item(list/entry, atom/spawn_at, savefile/photos)
	if (!islist(entry) || !spawn_at)
		return null
	var/path = character_persist_safe_resolve_path(entry["type"])
	if (character_persist_inventory_path_denied(path))
		return null
	var/obj/item/I
	if (ispath(path, /obj/item/stack))
		var/amount = entry["amount"]
		if (!isnum(amount))
			amount = text2num(amount)
		if (!isnum(amount) || amount < 1)
			amount = 1
		I = new path(spawn_at, amount)
	else if (ispath(path, /obj/item/spacecash))
		var/worth = text2num(entry["worth"]) || 0
		if (ispath(path, /obj/item/spacecash/ewallet))
			var/obj/item/spacecash/ewallet/E = new path(spawn_at)
			E.worth = worth
			E.owner_name = entry["owner_name"] || ""
			I = E
		else
			var/obj/item/spacecash/bundle/bundle = new /obj/item/spacecash/bundle(spawn_at)
			bundle.worth = max(0, worth)
			bundle.update_icon()
			I = bundle
	else if (ispath(path, /obj/item/paper))
		var/obj/item/paper/P = new path(spawn_at)
		var/title = entry["title"] || entry["name"]
		P.set_content(entry["info"] || "", title, FALSE)
		if (entry["stamps"])
			P.stamps = entry["stamps"]
		if (islist(entry["stamped"]))
			P.stamped = list()
			for (var/stamp_text in entry["stamped"])
				var/stamp_path = character_persist_safe_resolve_path(stamp_text)
				if (stamp_path)
					P.stamped += stamp_path
		if (entry["language"])
			var/datum/language/L = all_languages[entry["language"]]
			if (istype(L))
				P.language = L
		I = P
	else if (ispath(path, /obj/item/photo))
		var/obj/item/photo/Ph = new path(spawn_at)
		Ph.scribble = entry["scribble"] || ""
		Ph.photo_size = text2num(entry["photo_size"]) || 3
		if (entry["desc"])
			Ph.desc = entry["desc"]
		if (entry["name"])
			Ph.SetName(entry["name"])
		var/pid = entry["photo_id"]
		if (pid && photos)
			Ph.img = character_persist_safe_read_photo(photos, pid)
			Ph.tiny = character_persist_safe_read_photo(photos, "[pid]_tiny")
		I = Ph
	else
		I = new path(spawn_at)
	if (QDELETED(I) || !istype(I))
		return null
	if (istype(I, /obj/item/storage))
		odyssey_clear_storage_autofill(I)
	if (istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if (istype(S.pockets))
			odyssey_clear_storage_autofill(S.pockets)
	if (entry["name"] && !istype(I, /obj/item/paper) && !istype(I, /obj/item/photo))
		I.SetName(entry["name"])
	if (entry["color"])
		I.color = entry["color"]
	if (islist(entry["reagents"]) && istype(I, /obj/item/reagent_containers))
		character_persist_safe_apply_reagents(I, entry["reagents"])
	if (islist(entry["accessories"]) && istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		for (var/acc_text in entry["accessories"])
			var/acc_path = character_persist_safe_resolve_path(acc_text)
			if (!ispath(acc_path, /obj/item/clothing/accessory) || character_persist_inventory_path_denied(acc_path))
				continue
			var/obj/item/clothing/accessory/A = new acc_path(C)
			if (!C.attempt_attach_accessory(A))
				qdel(A)
	return I


/proc/character_persist_place_inventory_child(obj/item/I, atom/parent)
	if (!istype(I) || !parent)
		return FALSE
	if (istype(parent, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = parent
		I.forceMove(B)
		if (!islist(B.pages))
			B.pages = list()
		B.pages += I
		return TRUE
	if (istype(parent, /obj/item/folder) || istype(parent, /obj/item/storage))
		I.forceMove(parent)
		return TRUE
	if (istype(parent, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = parent
		if (istype(S.pockets))
			I.forceMove(S.pockets)
			return TRUE
	if (istype(parent, /obj/item/clothing))
		var/obj/item/clothing/C = parent
		if (islist(C.accessories))
			for (var/obj/item/clothing/accessory/storage/A in C.accessories)
				if (!istype(A.container))
					continue
				I.forceMove(A.container)
				return TRUE
	I.forceMove(parent)
	return TRUE


/proc/character_persist_apply_inventory(mob/living/carbon/human/H, list/entries)
	if (!istype(H) || !islist(entries) || !length(entries))
		return 0
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	var/savefile/photos
	var/photo_path = character_persist_inventory_photos_path(ckey, slot, TRUE)
	if (photo_path && fexists(photo_path))
		photos = new /savefile(photo_path)
	var/list/created_by_id = list()
	var/list/deferred = list()
	var/applied = 0
	for (var/list/entry in entries)
		if (!islist(entry))
			continue
		if (entry["storage_id"])
			deferred += list(entry)
			continue
		var/obj/item/I = character_persist_spawn_inventory_item(entry, H.loc, photos)
		if (!istype(I))
			continue
		if (entry["id"])
			created_by_id[entry["id"]] = I
		var/slot_id = entry["slot"]
		if (isnum(slot_id))
			if (!H.equip_to_slot_if_possible(I, slot_id, TRYEQUIP_SILENT | TRYEQUIP_INSTANT | TRYEQUIP_FORCE))
				if (!H.put_in_hands(I))
					I.forceMove(H.loc)
		else if (!H.put_in_hands(I))
			I.forceMove(H.loc)
		applied++
	// Multi-pass: firstaid → pill bottle → pills (same as Odyssey items lane).
	var/list/pending = deferred.Copy()
	var/guard = 0
	while (length(pending) && guard < 16)
		guard++
		var/list/next = list()
		var/progress = 0
		for (var/list/entry in pending)
			if (!islist(entry))
				continue
			var/atom/parent = created_by_id[entry["storage_id"]]
			if (entry["storage_id"] && !istype(parent))
				next += list(entry)
				continue
			var/atom/spawn_at = parent || H.loc
			var/obj/item/I = character_persist_spawn_inventory_item(entry, spawn_at, photos)
			if (!istype(I))
				continue
			if (entry["id"])
				created_by_id[entry["id"]] = I
			if (parent)
				character_persist_place_inventory_child(I, parent)
			else
				I.forceMove(H.loc)
			applied++
			progress++
		if (!progress)
			for (var/list/entry in next)
				if (!islist(entry))
					continue
				var/obj/item/I = character_persist_spawn_inventory_item(entry, H.loc, photos)
				if (!istype(I))
					continue
				if (entry["id"])
					created_by_id[entry["id"]] = I
				I.forceMove(H.loc)
				applied++
			break
		pending = next
	return applied

/proc/character_persist_equip_job_essentials(mob/living/carbon/human/H, datum/job/job, alt_title, datum/mil_branch/branch, datum/mil_rank/grade)
	if (!istype(H) || !istype(job))
		return
	var/singleton/hierarchy/outfit/outfit = job.get_outfit(H, alt_title, branch, grade)
	if (!istype(outfit))
		return
	// Drop any accidental ID/PDA/headset that slipped through older snapshots.
	for (var/obj/item/I in H.get_equipped_items(TRUE))
		if (istype(I, /obj/item/card/id) || istype(I, /obj/item/modular_computer) || istype(I, /obj/item/device/radio/headset))
			H.drop_from_inventory(I)
			qdel(I)
	if (outfit.l_ear)
		H.equip_to_slot_or_del(new outfit.l_ear(H), slot_l_ear)
	if (outfit.r_ear)
		H.equip_to_slot_or_del(new outfit.r_ear(H), slot_r_ear)
	var/rank = outfit.id_pda_assignment || job.title
	var/assignment = outfit.id_pda_assignment || alt_title || job.title
	var/list/id_cards = outfit.equip_ids(H, rank, assignment, 0)
	if (length(id_cards))
		var/obj/item/card/id/W = id_cards[1]
		rank = W.rank
		assignment = W.assignment
	outfit.equip_pda(H, rank, assignment, 0)
	for (var/id_card in id_cards)
		H.set_id_info(id_card)
	if (job.give_psionic_implant_on_join && H.psi)
		var/has_psi_imp = FALSE
		for (var/obj/item/implant/psi_control/existing in H)
			has_psi_imp = TRUE
			break
		if (!has_psi_imp)
			var/obj/item/implant/psi_control/imp = new
			imp.implanted(H)
			imp.forceMove(H)
			imp.imp_in = H
			imp.implanted = TRUE
			var/obj/item/organ/external/affected = H.get_organ(BP_HEAD)
			if (affected)
				affected.implants += imp
				imp.part = affected


/// Full equip_rank path that restores inventory instead of outfit/loadout.
/proc/character_persist_equip_rank_restoring(mob/living/carbon/human/H, rank, joined_late = 0)
	if (!istype(H))
		return
	var/datum/job/job = SSjobs.get_by_title(rank)
	var/ckey = character_persist_ckey_of(H)
	var/slot = character_persist_slot_of(H)
	var/list/snapshot = character_persist_read(ckey, slot, TRUE)
	if (!islist(snapshot))
		snapshot = character_persist_prefs_of(ckey)?.character_persist_snapshot

	if (job)
		if (H.client)
			if (GLOB.using_map.flags & MAP_HAS_BRANCH)
				H.char_branch = GLOB.mil_branches.get_branch(H.client.prefs.branches[rank])
			if (GLOB.using_map.flags & MAP_HAS_RANK)
				H.char_rank = GLOB.mil_branches.get_rank(H.client.prefs.branches[rank], H.client.prefs.ranks[rank])
		H.skillset.obtain_from_client(job, H.client)
		job.setup_account(H)
		if (rank != "Robot" && rank != "AI")
			var/domain
			var/addr = H.real_name
			var/pass
			if (H.char_branch)
				if (H.char_branch.email_domain)
					domain = H.char_branch.email_domain
				if (H.char_branch.allow_custom_email && H.client?.prefs?.email_addr)
					addr = H.client.prefs.email_addr
			else
				domain = "freemail.net"
			if (H.client?.prefs?.email_pass)
				pass = H.client.prefs.email_pass
			if (domain)
				ntnet_global.create_email(H, addr, domain, rank, pass)
		if (job.required_language)
			H.add_language(job.required_language)
			H.set_default_language(all_languages[job.required_language])
		if (!length(H.languages))
			H.add_language(LANGUAGE_SPACER)
			H.set_default_language(all_languages[LANGUAGE_SPACER])
		if (islist(job.psi_faculties))
			for (var/psi in job.psi_faculties)
				H.set_psi_rank(psi, job.psi_faculties[psi], take_larger = TRUE, defer_update = TRUE)
		if (H.psi)
			H.psi.update()
		if (job.faction)
			H.faction = job.faction
			H.last_faction = job.faction
	else
		to_chat(H, "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator.")

	H.job = rank

	if (!joined_late || job?.latejoin_at_spawnpoints)
		var/obj/S = job?.get_roundstart_spawnpoint()
		if (istype(S, /obj/landmark/start) && istype(S.loc, /turf))
			H.forceMove(S.loc)
		else if (job)
			var/datum/spawnpoint/spawnpoint = job.get_spawnpoint(H.client)
			H.forceMove(pick(spawnpoint.turfs))
			spawnpoint.after_join(H)

	if (H.mind && job?.head_position)
		var/remembered_info = ""
		var/datum/money_account/department_account = department_accounts[job.department]
		if (department_account)
			remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
			remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
			remembered_info += "<b>Your department's account funds are:</b> [GLOB.using_map.local_currency_name_short][department_account.money]<br>"
		H.StoreMemory(remembered_info, /singleton/memory_options/system)

	var/alt_title = null
	if (H.mind)
		H.mind.assigned_job = job
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

	var/applied = 0
	if (islist(snapshot))
		applied = character_persist_apply_inventory(H, snapshot["inventory"])
	if (job)
		character_persist_equip_job_essentials(H, job, alt_title, H.char_branch, H.char_rank)
		job.apply_fingerprints(H)
		job.post_equip_rank(H, alt_title || rank)

	if (istype(H))
		var/obj/item/organ/external/l_foot = H.get_organ(BP_L_FOOT)
		var/obj/item/organ/external/r_foot = H.get_organ(BP_R_FOOT)
		if (!l_foot || !r_foot)
			var/obj/structure/bed/chair/wheelchair/W = new /obj/structure/bed/chair/wheelchair(H.loc)
			H.UpdateLyingBuckledAndVerbStatus()
			W.set_dir(H.dir)
			W.buckle_mob(H)
			W.add_fingerprint(H)

	to_chat(H, FONT_LARGE("<B>You are [job?.total_positions == 1 ? "the" : "a"] [alt_title ? alt_title : rank].</B>"))
	if (job?.supervisors)
		to_chat(H, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
	to_chat(H, "<b>To speak on your department's radio channel use :h. For the use of other channels, examine your headset.</b>")
	to_chat(H, SPAN_NOTICE("Экипировка перенесена с прошлой смены Одиссеи ([applied] предм.). Job outfit и loadout не выдавались."))
	if (job?.req_admin_notify)
		to_chat(H, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
	if (H.disabilities & NEARSIGHTED)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/prescription(H), slot_glasses)
	SET_BIT(H.hud_updateflag, ID_HUD)
	SET_BIT(H.hud_updateflag, IMPLOYAL_HUD)
	SET_BIT(H.hud_updateflag, SPECIALROLE_HUD)
	H.client?.show_location_blurb(3 SECONDS)
	log_game("CHARACTER_PERSIST: inventory restore [ckey] slot=[slot] job=[rank] items=[applied]")
	return H
