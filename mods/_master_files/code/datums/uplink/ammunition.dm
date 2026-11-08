// COMBAT_EXTENDED: caliber names, see code/__defines/~mods/combat_extended.dm
/datum/uplink_item/item/ammo/holdout
	desc = "A 9x19mm magazine for holdout pistols like the P3 Whisper. Contains 8 rounds."

/datum/uplink_item/item/ammo/holdout_speedloader
	desc = "A 9x19mm speedloader for holdout revolvers like the A&M Partner. Contains 6 rounds."

/datum/uplink_item/item/ammo/speedloader
	desc = "A 10mm Auto speedloader for standard revolvers like the Lumoco Solid. Contains 6 rounds."

// Core defines /rifle twice, and the light bullpup magazine replaced the STS-35 magazine.
// The mod stops the light magazine, so /rifle sells the STS-35 magazine again.
/datum/uplink_item/item/ammo/rifle
	name = "Rifle Magazine"
	desc = "A 5.56 magazine for assault rifles like the STS-35. Contains 20 rounds."
	path = /obj/item/ammo_magazine/rifle

/datum/uplink_item/item/ammo/bullpup
	name = "Bullpup Rifle Magazine"
	desc = "A 7.62 magazine for bullpup assault rifles like the Z8 Bulldog and the Z9 Pitbull. Contains 18 rounds."

/datum/uplink_item/item/ammo/machine_pistol
	desc = "A 10mm Auto magazine for standard machine pistols like the MP6 Vesper. Contains 16 rounds."

/datum/uplink_item/item/ammo/smg
	desc = "A 10mm Auto magazine for standard SMGs like the C-20r. Contains 20 rounds."

/datum/uplink_item/item/ammo/pistol
	desc = "A 10mm Auto magazine for large, heavy military pistols. Contains 15 rounds."

/datum/uplink_item/item/ammo/pistol_single
	desc = "A 10mm Auto magazine for small, light military pistols. Contains 8 rounds."

/datum/uplink_item/item/ammo/magnum
	desc = "A .44 Magnum magazine for magnum pistols. Contains 7 rounds."

/datum/uplink_item/item/ammo/speedloader_magnum
	desc = "A .44 Magnum speedloader for magnum revolvers. Contains 6 rounds."

/datum/uplink_item/item/ammo/pistol_emp
	desc = "A box of 10mm Auto EMP ammo for standard pistols. Contains 15 rounds."

/datum/uplink_item/item/ammo/holdout_emp
	desc = "A box of 9x19mm EMP ammo for holdout pistols and revolvers. Contains 8 rounds."

/datum/uplink_item/item/ammo/stripperclip
	desc = "A 5.56 stripper clip used to load bolt action rifles. Contains just 5 rounds."
