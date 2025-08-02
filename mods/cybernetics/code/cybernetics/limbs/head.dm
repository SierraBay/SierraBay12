/singleton/cyber_choose/limb/head
	augment_name = "Голова без бренда"
	aug_description = "Это голова."
	avaible_hardpoints = list(BP_HEAD)

/singleton/cyber_choose/limb/head/check_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return FALSE
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return FALSE
	return TRUE

/singleton/cyber_choose/limb/head/get_reason_for_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return SPAN_BAD("Вас нет в вайтлисте ППТ или ИПС. Обратитесь в #sierra-chat к @xeno-moderator")
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return SPAN_BAD("Для установки протеза головы, все остальные части тела должны быть протезом.")

/singleton/cyber_choose/limb/head/bishop
	augment_name = "Голова Bishop"
	aug_description = "Это голова от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/head/bishop_rook
	augment_name = "Голова Bishop Rook"
	aug_description = "Это голова от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

/singleton/cyber_choose/limb/head/bishop_alt
	augment_name = "Голова Bishop Alt"
	aug_description = "Это голова от корпорации Bishop, модель - Alternative"
	robolimb_data = /datum/robolimb/bishop/alt/monitor

/singleton/cyber_choose/limb/head/hephaestus
	augment_name = "Голова Hephaestus Industries"
	aug_description = "Это голова от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/head/hephaestus_alt
	augment_name = "Голова Hephaestus Industries Alt"
	aug_description = "Это голова от корпорации Hephaestus Industries, модель - Alternative"
	robolimb_data = /datum/robolimb/hephaestus/alt/monitor

/singleton/cyber_choose/limb/head/hephaestus_titan
	augment_name = "Голова Hephaestus Industries Titan"
	aug_description = "Это голова от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan


// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/head/zenghu
	augment_name = "Голова Zeng-Hu"
	aug_description = "Это голова от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/head/zenghu_spirit
	augment_name = "Голова Zeng-Hu Spirit"
	aug_description = "Это голова от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/head/xion
	augment_name = "Голова Xion"
	aug_description = "Это голова от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/head/xion_econo
	augment_name = "Голова Xion Econo"
	aug_description = "Это голова от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/head/xion_alt
	augment_name = "Голова Xion Alt"
	aug_description = "Это голова от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

/singleton/cyber_choose/limb/head/xion_alt_monitor
	augment_name = "Голова Xion Alt Monitor"
	aug_description = "Это голова от корпорации Xion, модель - Alternative Monitor"
	robolimb_data = /datum/robolimb/xion/alt/monitor

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/head/nanotrasen
	augment_name = "Голова NanoTrasen"
	aug_description = "Это голова от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/head/wardtakahashi
	augment_name = "Голова Ward-Takahashi"
	aug_description = "Это голова от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/head/wardtakahashi_alt
	augment_name = "Голова Ward-Takahashi Alt"
	aug_description = "Это голова от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

/singleton/cyber_choose/limb/head/wardtakahashi_alt_monitor
	augment_name = "Голова Ward-Takahashi Alt Monitor"
	aug_description = "Это голова от корпорации Ward-Takahashi, модель - Alternative Monitor"
	robolimb_data = /datum/robolimb/wardtakahashi/alt/monitor

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/head/morpheus
	augment_name = "Голова Morpheus"
	aug_description = "Это голова от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/head/morpheus_alt
	augment_name = "Голова Morpheus Alt"
	aug_description = "Это голова от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/head/morpheus_alt_blitz
	augment_name = "Голова Morpheus Alt Blitz"
	aug_description = "Это голова от корпорации Morpheus, модель - Alternative Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/head/morpheus_alt_airborne
	augment_name = "Голова Morpheus Alt Airborne"
	aug_description = "Это голова от корпорации Morpheus, модель - Alternative Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/head/morpheus_alt_prime
	augment_name = "Голова Morpheus Alt Prime"
	aug_description = "Это голова от корпорации Morpheus, модель - Alternative Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

/singleton/cyber_choose/limb/head/morpheus_monitor
	augment_name = "Голова Morpheus Monitor"
	aug_description = "Это голова от корпорации Morpheus, модель - Monitor"
	robolimb_data = /datum/robolimb/morpheus/monitor

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/head/mantis
	augment_name = "Голова Mantis"
	aug_description = "Это голова от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/head/veymed
	augment_name = "Голова Vey-Med"
	aug_description = "Это голова от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/head/shellguard
	augment_name = "Голова Shellguard"
	aug_description = "Это голова от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/head/shellguard_alt
	augment_name = "Голова Shellguard Alt"
	aug_description = "Это голова от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

/singleton/cyber_choose/limb/head/shellguard_alt_monitor
	augment_name = "Голова Shellguard Alt Monitor"
	aug_description = "Это голова от корпорации Shellguard, модель - Alternative Monitor"
	robolimb_data = /datum/robolimb/shellguard/alt/monitor

// =================
// VOX
// =================
/singleton/cyber_choose/limb/head/vox
	augment_name = "Голова Vox"
	aug_description = "Это голова от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/head/vox_crap
	augment_name = "Голова Vox Crap"
	aug_description = "Это голова от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/head/resomi
	augment_name = "Голова Resomi"
	aug_description = "Это голова от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
