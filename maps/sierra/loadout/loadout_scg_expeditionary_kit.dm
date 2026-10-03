/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit
	/// Metadata written by the lobby loadout tweaks before setup_kit() consumes it.
	var/chosen_rank_label
	var/chosen_patch_label
	var/chosen_scarf_label

/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit/proc/setup_kit(mob/living/carbon/human/user)
	if (!istype(user))
		return

	var/static/list/rank_type_by_label = list(
		"E-3 (Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e3,
		"E-5 (Senior Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e5,
		"E-7 (Chief Explorer)" = /obj/item/clothing/accessory/solgov/rank/ec/enlisted/e7,
		"O-1 (Ensign)" = /obj/item/clothing/accessory/solgov/rank/ec/officer
	)
	var/static/list/patch_type_by_label = list(
		"Observatory patch" = /obj/item/clothing/accessory/solgov/ec_patch,
		"Field Operations patch" = /obj/item/clothing/accessory/solgov/ec_patch/fieldops,
		"Cultural Exchange patch" = /obj/item/clothing/accessory/solgov/cultex_patch
	)
	var/static/list/scarf_type_by_label = list(
		"Observatory scarf" = /obj/item/clothing/accessory/solgov/ec_scarf/observatory,
		"Field Operations scarf" = /obj/item/clothing/accessory/solgov/ec_scarf/fieldops
	)
	var/static/list/department_insignia_by_word = list(
		"command" = /obj/item/clothing/accessory/solgov/department/command,
		"engineering" = /obj/item/clothing/accessory/solgov/department/engineering,
		"security" = /obj/item/clothing/accessory/solgov/department/security,
		"medical" = /obj/item/clothing/accessory/solgov/department/medical,
		"research" = /obj/item/clothing/accessory/solgov/department/research,
		"supply" = /obj/item/clothing/accessory/solgov/department/supply,
		"exploration" = /obj/item/clothing/accessory/solgov/department/exploration,
		"service" = /obj/item/clothing/accessory/solgov/department/service
	)
	var/static/list/gloves_by_department = list(
		"command" = /obj/item/clothing/gloves/thick/duty/solgov/cmd,
		"engineering" = /obj/item/clothing/gloves/thick/duty/solgov/eng,
		"security" = /obj/item/clothing/gloves/thick/duty/solgov/sec,
		"medical" = /obj/item/clothing/gloves/thick/duty/solgov/med,
		"research" = /obj/item/clothing/gloves/thick/duty/solgov/sci,
		"supply" = /obj/item/clothing/gloves/thick/duty/solgov/sup,
		"exploration" = /obj/item/clothing/gloves/thick/duty/solgov/exp,
		"service" = /obj/item/clothing/gloves/thick/duty/solgov/svc
	)

	// Sensible defaults for anyone who never touched the loadout tweaks.
	var/rank_type = rank_type_by_label[chosen_rank_label] || rank_type_by_label["E-3 (Explorer)"]
	var/patch_type = patch_type_by_label[chosen_patch_label] || patch_type_by_label["Observatory patch"]
	var/scarf_type = scarf_type_by_label[chosen_scarf_label] || scarf_type_by_label["Observatory scarf"]
	var/is_officer = (chosen_rank_label == "O-1 (Ensign)")

	if (is_officer)
		icon_state = "ecservice_officer"
		item_state = "ecservice_officer"

	var/dept_word = get_department_word(user)
	var/insignia_type = department_insignia_by_word[dept_word]

	attach_accessory(null, new insignia_type(src))
	attach_accessory(null, new patch_type(src))
	attach_accessory(null, new rank_type(src))
	attach_accessory(null, new scarf_type(src))

	// The undersuit also gets its own copy of the department insignia - it's the piece players
	// actually see worn day to day, and other SolGov uniform families tag it the same way.
	var/uniform_type = is_officer ? /obj/item/clothing/under/scg_expeditonary/officer : /obj/item/clothing/under/scg_expeditonary
	var/obj/item/clothing/under/uniform = new uniform_type(user)
	uniform.attach_accessory(null, new insignia_type(uniform))
	user.equip_to_slot_if_possible(uniform, slot_w_uniform, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

	var/glove_type = gloves_by_department[dept_word]
	user.equip_to_slot_if_possible(new glove_type(user), slot_gloves, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

	user.equip_to_slot_if_possible(new /obj/item/clothing/head/soft/solgov/expedition(user), slot_head, TRYEQUIP_REDRAW | TRYEQUIP_DESTROY | TRYEQUIP_FORCE | TRYEQUIP_INSTANT)

/obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit/proc/get_department_word(mob/user)
	var/dept_flag = 0
	if (user.mind && user.mind.assigned_role)
		var/datum/job/job = SSjobs.get_by_title(user.mind.assigned_role)
		if (job)
			dept_flag = job.department_flag

	if (dept_flag & (COM|SPT))
		return "command"
	if (dept_flag & ENG)
		return "engineering"
	if (dept_flag & SEC)
		return "security"
	if (dept_flag & MED)
		return "medical"
	if (dept_flag & SCI)
		return "research"
	if (dept_flag & SUP)
		return "supply"
	if (dept_flag & EXP)
		return "exploration"
	return "service" // Civilian/misc/unassigned roles default to the service department's cut.

/datum/gear_tweak/custom_var/scg_kit_rank
	var_to_tweak = "chosen_rank_label"
	content_text = "Rank"
	input_message = "Choose your rank."

/datum/gear_tweak/custom_var/scg_kit_patch
	var_to_tweak = "chosen_patch_label"
	content_text = "Patch"
	input_message = "Choose your patch."

/datum/gear_tweak/custom_var/scg_kit_scarf
	var_to_tweak = "chosen_scarf_label"
	content_text = "Scarf"
	input_message = "Choose your scarf."

/datum/gear/scg_expeditionary_kit
	display_name = "SCG Expeditionary Corps uniform"
	description = "A complete SCG Expeditionary Corps uniform, tailored to your assignment."
	path = /obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit
	slot = slot_wear_suit
	allowed_branches = list(/datum/mil_branch/contractor)
	allowed_factions = list(FACTION_EXPEDITIONARY, FACTION_CORPORATE)
	custom_setup_proc = /obj/item/clothing/suit/storage/solgov/service/expeditionary/scg_kit/proc/setup_kit

/datum/gear/scg_expeditionary_kit/New()
	gear_tweaks += new /datum/gear_tweak/custom_var/scg_kit_rank(list("E-3 (Explorer)", "E-5 (Senior Explorer)", "E-7 (Chief Explorer)", "O-1 (Ensign)"))
	gear_tweaks += new /datum/gear_tweak/custom_var/scg_kit_patch(list("Observatory patch", "Field Operations patch", "Cultural Exchange patch"))
	gear_tweaks += new /datum/gear_tweak/custom_var/scg_kit_scarf(list("Observatory scarf", "Field Operations scarf"))
	..()
