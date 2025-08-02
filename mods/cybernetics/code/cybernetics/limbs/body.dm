/singleton/cyber_choose/limb/body
	augment_name = "Грудь без бренда"
	aug_description = "Это торс."
	avaible_hardpoints = list(BP_CHEST)

/singleton/cyber_choose/limb/body/check_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return FALSE
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return FALSE
	return TRUE

/singleton/cyber_choose/limb/body/get_reason_for_avaibility(datum/preferences/input_pref)
	if(!whitelist_lookup(SPECIES_FBP, input_pref.client) && !whitelist_lookup(SPECIES_IPC, input_pref.client))
		return SPAN_BAD("Вас нет в вайтлисте ППТ или ИПС. Обратитесь в #sierra-chat к @xeno-moderator")
	for(var/hardpoint in list(BP_HEAD, BP_CHEST, BP_GROIN, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND, BP_R_LEG, BP_L_LEG, BP_R_FOOT, BP_L_FOOT))
		if(input_pref.limb_list[hardpoint] == "Пусто")
			return SPAN_BAD("Для установки протеза тела, все остальные части тела должны быть протезом.")

// =================
// BISHOP CYBERNETICS
// =================
/singleton/cyber_choose/limb/body/bishop
	augment_name = "Грудь Bishop"
	aug_description = "Это торс от корпорации Bishop"
	robolimb_data = /datum/robolimb/bishop

/singleton/cyber_choose/limb/body/bishop_rook
	augment_name = "Грудь Bishop Rook"
	aug_description = "Это торс от корпорации Bishop, модель - Rook"
	robolimb_data = /datum/robolimb/bishop/rook

// =================
// HEPHAESTUS INDUSTRIES
// =================
/singleton/cyber_choose/limb/body/hephaestus
	augment_name = "Грудь Hephaestus"
	aug_description = "Это торс от корпорации Hephaestus Industries"
	robolimb_data = /datum/robolimb/hephaestus

/singleton/cyber_choose/limb/body/hephaestus_titan
	augment_name = "Грудь Hephaestus Titan"
	aug_description = "Это торс от корпорации Hephaestus Industries, модель - Titan"
	robolimb_data = /datum/robolimb/hephaestus/titan

// =================
// ZENGHU
// =================
/singleton/cyber_choose/limb/body/zenghu
	augment_name = "Грудь Zeng-Hu"
	aug_description = "Это торс от корпорации Zeng-Hu"
	robolimb_data = /datum/robolimb/zenghu

/singleton/cyber_choose/limb/body/zenghu_spirit
	augment_name = "Грудь Zeng-Hu Spirit"
	aug_description = "Это торс от корпорации Zeng-Hu, модель - Spirit"
	robolimb_data = /datum/robolimb/zenghu/spirit

// =================
// XION
// =================
/singleton/cyber_choose/limb/body/xion
	augment_name = "Грудь Xion"
	aug_description = "Это торс от корпорации Xion"
	robolimb_data = /datum/robolimb/xion

/singleton/cyber_choose/limb/body/xion_econo
	augment_name = "Грудь Xion Econo"
	aug_description = "Это торс от корпорации Xion, модель - Econo"
	robolimb_data = /datum/robolimb/xion/econo

/singleton/cyber_choose/limb/body/xion_alt
	augment_name = "Грудь Xion Alt"
	aug_description = "Это торс от корпорации Xion, модель - Alternative"
	robolimb_data = /datum/robolimb/xion/alt

// =================
// NANOTRASEN
// =================
/singleton/cyber_choose/limb/body/nanotrasen
	augment_name = "Грудь NanoTrasen"
	aug_description = "Это торс от корпорации NanoTrasen"
	robolimb_data = /datum/robolimb/nanotrasen

// =================
// WARD-TAKAHASHI
// =================
/singleton/cyber_choose/limb/body/wardtakahashi
	augment_name = "Грудь Ward-Takahashi"
	aug_description = "Это торс от корпорации Ward-Takahashi"
	robolimb_data = /datum/robolimb/wardtakahashi

/singleton/cyber_choose/limb/body/wardtakahashi_alt
	augment_name = "Грудь Ward-Takahashi Alt"
	aug_description = "Это торс от корпорации Ward-Takahashi, модель - Alternative"
	robolimb_data = /datum/robolimb/wardtakahashi/alt

// =================
// MORPHEUS
// =================
/singleton/cyber_choose/limb/body/morpheus
	augment_name = "Грудь Morpheus"
	aug_description = "Это торс от корпорации Morpheus"
	robolimb_data = /datum/robolimb/morpheus

/singleton/cyber_choose/limb/body/morpheus_alt
	augment_name = "Грудь Morpheus Alt"
	aug_description = "Это торс от корпорации Morpheus, модель - Alternative"
	robolimb_data = /datum/robolimb/morpheus/alt

/singleton/cyber_choose/limb/body/morpheus_alt_blitz
	augment_name = "Грудь Morpheus Blitz"
	aug_description = "Это торс от корпорации Morpheus, модель - Blitz"
	robolimb_data = /datum/robolimb/morpheus/alt/blitz

/singleton/cyber_choose/limb/body/morpheus_alt_airborne
	augment_name = "Грудь Morpheus Airborne"
	aug_description = "Это торс от корпорации Morpheus, модель - Airborne"
	robolimb_data = /datum/robolimb/morpheus/alt/airborne

/singleton/cyber_choose/limb/body/morpheus_alt_prime
	augment_name = "Грудь Morpheus Prime"
	aug_description = "Это торс от корпорации Morpheus, модель - Prime"
	robolimb_data = /datum/robolimb/morpheus/alt/prime

// =================
// MANTIS
// =================
/singleton/cyber_choose/limb/body/mantis
	augment_name = "Грудь Mantis"
	aug_description = "Это торс от корпорации Mantis"
	robolimb_data = /datum/robolimb/mantis

// =================
// VEYMED
// =================
/singleton/cyber_choose/limb/body/veymed
	augment_name = "Грудь Vey-Med"
	aug_description = "Это торс от корпорации Vey-Med"
	robolimb_data = /datum/robolimb/veymed

// =================
// SHELLGUARD
// =================
/singleton/cyber_choose/limb/body/shellguard
	augment_name = "Грудь Shellguard"
	aug_description = "Это торс от корпорации Shellguard"
	robolimb_data = /datum/robolimb/shellguard

/singleton/cyber_choose/limb/body/shellguard_alt
	augment_name = "Грудь Shellguard Alt"
	aug_description = "Это торс от корпорации Shellguard, модель - Alternative"
	robolimb_data = /datum/robolimb/shellguard/alt

// =================
// VOX
// =================
/singleton/cyber_choose/limb/body/vox
	augment_name = "Грудь Vox"
	aug_description = "Это торс от корпорации Vox"
	robolimb_data = /datum/robolimb/vox

/singleton/cyber_choose/limb/body/vox_crap
	augment_name = "Грудь Vox Crap"
	aug_description = "Это торс от корпорации Vox, модель - Crap"
	robolimb_data = /datum/robolimb/vox/crap

// =================
// RESOMI
// =================
/singleton/cyber_choose/limb/body/resomi
	augment_name = "Грудь Resomi"
	aug_description = "Это торс от корпорации Resomi"
	robolimb_data = /datum/robolimb/resomi
