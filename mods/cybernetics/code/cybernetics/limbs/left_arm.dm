/singleton/cyber_choose/limb/left_arm
	augment_name = "Левая рука без бренда"
	aug_description = "Это левая рука."
	avaible_hardpoints = list(BP_L_ARM)

/singleton/cyber_choose/limb/left_arm/check_avaibility(datum/preferences/input_pref)
	if(input_pref.limb_list[BP_L_HAND] == "Пусто")
		return FALSE
	return TRUE

/singleton/cyber_choose/limb/left_arm/get_reason_for_avaibility(datum/preferences/input_pref)
	return SPAN_BAD("Нельзя выбрать протез вместо руки, но оставить кисть мясной.")

// =================
// BISHOP CYBERNETICS
// =================
/singleton/cyber_choose/limb/left_arm/bishop
	augment_name = "Левая рука Bishop"
	aug_description = "Левая рука от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/left_arm/bishop_rook
	augment_name = "Левая рука Bishop Rook"
	aug_description = "Левая рука от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

// =================
// HEPHAESTUS INDUSTRIES
// =================
/singleton/cyber_choose/limb/left_arm/hephaestus
	augment_name = "Левая рука Hephaestus"
	aug_description = "Левая рука от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/left_arm/hephaestus_titan
	augment_name = "Левая рука Hephaestus Titan"
	aug_description = "Левая рука от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan

// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/left_arm/zenghu
	augment_name = "Левая рука Zeng-Hu"
	aug_description = "Левая рука от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/left_arm/zenghu_spirit
	augment_name = "Левая рука Zeng-Hu Spirit"
	aug_description = "Левая рука от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/left_arm/xion
	augment_name = "Левая рука Xion"
	aug_description = "Левая рука от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/left_arm/xion_econo
	augment_name = "Левая рука Xion Econo"
	aug_description = "Левая рука от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/left_arm/xion_alt
	augment_name = "Левая рука Xion Alt"
	aug_description = "Левая рука от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/left_arm/nanotrasen
	augment_name = "Левая рука NanoTrasen"
	aug_description = "Левая рука от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/left_arm/wardtakahashi
	augment_name = "Левая рука Ward-Takahashi"
	aug_description = "Левая рука от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/left_arm/wardtakahashi_alt
	augment_name = "Левая рука Ward-Takahashi Alt"
	aug_description = "Левая рука от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/left_arm/morpheus
	augment_name = "Левая рука Morpheus"
	aug_description = "Левая рука от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/left_arm/morpheus_alt
	augment_name = "Левая рука Morpheus Alt"
	aug_description = "Левая рука от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/left_arm/morpheus_alt_blitz
	augment_name = "Левая рука Morpheus Blitz"
	aug_description = "Левая рука от корпорации Morpheus, модель - Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/left_arm/morpheus_alt_airborne
	augment_name = "Левая рука Morpheus Airborne"
	aug_description = "Левая рука от корпорации Morpheus, модель - Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/left_arm/morpheus_alt_prime
	augment_name = "Левая рука Morpheus Prime"
	aug_description = "Левая рука от корпорации Morpheus, модель - Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/left_arm/mantis
	augment_name = "Левая рука Mantis"
	aug_description = "Левая рука от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/left_arm/veymed
	augment_name = "Левая рука Vey-Med"
	aug_description = "Левая рука от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/left_arm/shellguard
	augment_name = "Левая рука Shellguard"
	aug_description = "Левая рука от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/left_arm/shellguard_alt
	augment_name = "Левая рука Shellguard Alt"
	aug_description = "Левая рука от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

// =================
// VOX
// =================
/singleton/cyber_choose/limb/left_arm/vox
	augment_name = "Левая рука Vox"
	aug_description = "Левая рука от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/left_arm/vox_crap
	augment_name = "Левая рука Vox Crap"
	aug_description = "Левая рука от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/left_arm/resomi
	augment_name = "Левая рука Resomi"
	aug_description = "Левая рука от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
