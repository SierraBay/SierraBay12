/singleton/cyber_choose/limb/groin
	augment_name = "Брюхо без бренда"
	aug_description = "Это брюхо."
	avaible_hardpoints = list(BP_GROIN)

/singleton/cyber_choose/limb/groin/check_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return FALSE
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return FALSE
	return TRUE

/singleton/cyber_choose/limb/groin/get_reason_for_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return SPAN_BAD("Вас нет в вайтлисте ППТ или ИПС. Обратитесь в #sierra-chat к @xeno-moderator")
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return SPAN_BAD("Для установки протеза брюха, все остальные части тела должны быть протезом.")

// =================
// BISHOP CYBERNETICS
// =================
/singleton/cyber_choose/limb/groin/bishop
	augment_name = "Брюхо Bishop"
	aug_description = "Это брюшная часть от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/groin/bishop_rook
	augment_name = "Брюхо Bishop Rook"
	aug_description = "Это брюшная часть от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

// =================
// HEPHAESTUS INDUSTRIES
// =================
/singleton/cyber_choose/limb/groin/hephaestus
	augment_name = "Брюхо Hephaestus"
	aug_description = "Это брюшная часть от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/groin/hephaestus_titan
	augment_name = "Брюхо Hephaestus Titan"
	aug_description = "Это брюшная часть от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan

// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/groin/zenghu
	augment_name = "Брюхо Zeng-Hu"
	aug_description = "Это брюшная часть от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/groin/zenghu_spirit
	augment_name = "Брюхо Zeng-Hu Spirit"
	aug_description = "Это брюшная часть от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/groin/xion
	augment_name = "Брюхо Xion"
	aug_description = "Это брюшная часть от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/groin/xion_econo
	augment_name = "Брюхо Xion Econo"
	aug_description = "Это брюшная часть от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/groin/xion_alt
	augment_name = "Брюхо Xion Alt"
	aug_description = "Это брюшная часть от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/groin/nanotrasen
	augment_name = "Брюхо NanoTrasen"
	aug_description = "Это брюшная часть от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/groin/wardtakahashi
	augment_name = "Брюхо Ward-Takahashi"
	aug_description = "Это брюшная часть от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/groin/wardtakahashi_alt
	augment_name = "Брюхо Ward-Takahashi Alt"
	aug_description = "Это брюшная часть от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/groin/morpheus
	augment_name = "Брюхо Morpheus"
	aug_description = "Это брюшная часть от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/groin/morpheus_alt
	augment_name = "Брюхо Morpheus Alt"
	aug_description = "Это брюшная часть от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/groin/morpheus_alt_blitz
	augment_name = "Брюхо Morpheus Blitz"
	aug_description = "Это брюшная часть от корпорации Morpheus, модель - Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/groin/morpheus_alt_airborne
	augment_name = "Брюхо Morpheus Airborne"
	aug_description = "Это брюшная часть от корпорации Morpheus, модель - Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/groin/morpheus_alt_prime
	augment_name = "Брюхо Morpheus Prime"
	aug_description = "Это брюшная часть от корпорации Morpheus, модель - Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/groin/mantis
	augment_name = "Брюхо Mantis"
	aug_description = "Это брюшная часть от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/groin/veymed
	augment_name = "Брюхо Vey-Med"
	aug_description = "Это брюшная часть от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/groin/shellguard
	augment_name = "Брюхо Shellguard"
	aug_description = "Это брюшная часть от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/groin/shellguard_alt
	augment_name = "Брюхо Shellguard Alt"
	aug_description = "Это брюшная часть от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

// =================
// VOX
// =================
/singleton/cyber_choose/limb/groin/vox
	augment_name = "Брюхо Vox"
	aug_description = "Это брюшная часть от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/groin/vox_crap
	augment_name = "Брюхо Vox Crap"
	aug_description = "Это брюшная часть от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/groin/resomi
	augment_name = "Брюхо Resomi"
	aug_description = "Это брюшная часть от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
