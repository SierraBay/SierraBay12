/singleton/cyber_choose/limb/right_leg
	augment_name = "Правая нога без бренда"
	aug_description = "Это правая нога."
	avaible_hardpoints = list(BP_R_LEG)

/singleton/cyber_choose/limb/right_leg/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_R_FOOT] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/limb/right_leg/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Нельзя выбрать протез вместо ноги, но оставить стопу мясной.")


// =================
// BISHOP CYBERNETICS
// =================
/singleton/cyber_choose/limb/right_leg/bishop
	augment_name = "Правая нога Bishop"
	aug_description = "Правая нога от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/right_leg/bishop_rook
	augment_name = "Правая нога Bishop Rook"
	aug_description = "Правая нога от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

// =================
// HEPHAESTUS INDUSTRIES
// =================
/singleton/cyber_choose/limb/right_leg/hephaestus
	augment_name = "Правая нога Hephaestus"
	aug_description = "Правая нога от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/right_leg/hephaestus_titan
	augment_name = "Правая нога Hephaestus Titan"
	aug_description = "Правая нога от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan

// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/right_leg/zenghu
	augment_name = "Правая нога Zeng-Hu"
	aug_description = "Правая нога от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/right_leg/zenghu_spirit
	augment_name = "Правая нога Zeng-Hu Spirit"
	aug_description = "Правая нога от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/right_leg/xion
	augment_name = "Правая нога Xion"
	aug_description = "Правая нога от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/right_leg/xion_econo
	augment_name = "Правая нога Xion Econo"
	aug_description = "Правая нога от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/right_leg/xion_alt
	augment_name = "Правая нога Xion Alt"
	aug_description = "Правая нога от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/right_leg/nanotrasen
	augment_name = "Правая нога NanoTrasen"
	aug_description = "Правая нога от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/right_leg/wardtakahashi
	augment_name = "Правая нога Ward-Takahashi"
	aug_description = "Правая нога от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/right_leg/wardtakahashi_alt
	augment_name = "Правая нога Ward-Takahashi Alt"
	aug_description = "Правая нога от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/right_leg/morpheus
	augment_name = "Правая нога Morpheus"
	aug_description = "Правая нога от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/right_leg/morpheus_alt
	augment_name = "Правая нога Morpheus Alt"
	aug_description = "Правая нога от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/right_leg/morpheus_alt_blitz
	augment_name = "Правая нога Morpheus Blitz"
	aug_description = "Правая нога от корпорации Morpheus, модель - Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/right_leg/morpheus_alt_airborne
	augment_name = "Правая нога Morpheus Airborne"
	aug_description = "Правая нога от корпорации Morpheus, модель - Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/right_leg/morpheus_alt_prime
	augment_name = "Правая нога Morpheus Prime"
	aug_description = "Правая нога от корпорации Morpheus, модель - Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/right_leg/mantis
	augment_name = "Правая нога Mantis"
	aug_description = "Правая нога от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/right_leg/veymed
	augment_name = "Правая нога Vey-Med"
	aug_description = "Правая нога от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/right_leg/shellguard
	augment_name = "Правая нога Shellguard"
	aug_description = "Правая нога от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/right_leg/shellguard_alt
	augment_name = "Правая нога Shellguard Alt"
	aug_description = "Правая нога от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

// =================
// VOX
// =================
/singleton/cyber_choose/limb/right_leg/vox
	augment_name = "Правая нога Vox"
	aug_description = "Правая нога от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/right_leg/vox_crap
	augment_name = "Правая нога Vox Crap"
	aug_description = "Правая нога от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/right_leg/resomi
	augment_name = "Правая нога Resomi"
	aug_description = "Правая нога от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
