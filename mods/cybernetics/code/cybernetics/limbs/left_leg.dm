/singleton/cyber_choose/limb/left_leg
	augment_name = "Левая нога без бренда"
	aug_description = "Это левая нога."
	avaible_hardpoints = list(BP_L_LEG)

/singleton/cyber_choose/limb/left_leg/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_L_FOOT] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/limb/left_leg/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Нельзя выбрать протез вместо ноги, но оставить стопу мясной.")

// =================
// BISHOP CYBERNETICS
// =================
/singleton/cyber_choose/limb/left_leg/bishop
	augment_name = "Левая нога Bishop"
	aug_description = "Левая нога от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/left_leg/bishop_rook
	augment_name = "Левая нога Bishop Rook"
	aug_description = "Левая нога от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

// =================
// HEPHAESTUS INDUSTRIES
// =================
/singleton/cyber_choose/limb/left_leg/hephaestus
	augment_name = "Левая нога Hephaestus"
	aug_description = "Левая нога от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/left_leg/hephaestus_titan
	augment_name = "Левая нога Hephaestus Titan"
	aug_description = "Левая нога от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan

// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/left_leg/zenghu
	augment_name = "Левая нога Zeng-Hu"
	aug_description = "Левая нога от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/left_leg/zenghu_spirit
	augment_name = "Левая нога Zeng-Hu Spirit"
	aug_description = "Левая нога от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/left_leg/xion
	augment_name = "Левая нога Xion"
	aug_description = "Левая нога от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/left_leg/xion_econo
	augment_name = "Левая нога Xion Econo"
	aug_description = "Левая нога от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/left_leg/xion_alt
	augment_name = "Левая нога Xion Alt"
	aug_description = "Левая нога от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/left_leg/nanotrasen
	augment_name = "Левая нога NanoTrasen"
	aug_description = "Левая нога от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/left_leg/wardtakahashi
	augment_name = "Левая нога Ward-Takahashi"
	aug_description = "Левая нога от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/left_leg/wardtakahashi_alt
	augment_name = "Левая нога Ward-Takahashi Alt"
	aug_description = "Левая нога от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/left_leg/morpheus
	augment_name = "Левая нога Morpheus"
	aug_description = "Левая нога от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/left_leg/morpheus_alt
	augment_name = "Левая нога Morpheus Alt"
	aug_description = "Левая нога от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/left_leg/morpheus_alt_blitz
	augment_name = "Левая нога Morpheus Blitz"
	aug_description = "Левая нога от корпорации Morpheus, модель - Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/left_leg/morpheus_alt_airborne
	augment_name = "Левая нога Morpheus Airborne"
	aug_description = "Левая нога от корпорации Morpheus, модель - Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/left_leg/morpheus_alt_prime
	augment_name = "Левая нога Morpheus Prime"
	aug_description = "Левая нога от корпорации Morpheus, модель - Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/left_leg/mantis
	augment_name = "Левая нога Mantis"
	aug_description = "Левая нога от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/left_leg/veymed
	augment_name = "Левая нога Vey-Med"
	aug_description = "Левая нога от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/left_leg/shellguard
	augment_name = "Левая нога Shellguard"
	aug_description = "Левая нога от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/left_leg/shellguard_alt
	augment_name = "Левая нога Shellguard Alt"
	aug_description = "Левая нога от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

// =================
// VOX
// =================
/singleton/cyber_choose/limb/left_leg/vox
	augment_name = "Левая нога Vox"
	aug_description = "Левая нога от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/left_leg/vox_crap
	augment_name = "Левая нога Vox Crap"
	aug_description = "Левая нога от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/left_leg/resomi
	augment_name = "Левая нога Resomi"
	aug_description = "Левая нога от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
