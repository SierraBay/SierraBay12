// Calibers renamed after real-world rounds. Define names stay core so core code keeps working.
#undef CALIBER_PISTOL
#define CALIBER_PISTOL ".45 Auto"
#undef CALIBER_PISTOL_SMALL
#define CALIBER_PISTOL_SMALL "9x19mm"
#undef CALIBER_PISTOL_MAGNUM
#define CALIBER_PISTOL_MAGNUM ".44 Magnum"
#undef CALIBER_PISTOL_FAST
#define CALIBER_PISTOL_FAST "5.7x28mm"
#undef CALIBER_RIFLE
#define CALIBER_RIFLE "5.56x45mm"
#undef CALIBER_RIFLE_MILITARY
#define CALIBER_RIFLE_MILITARY "7.62x39mm"
#undef CALIBER_ANTIMATERIAL
#define CALIBER_ANTIMATERIAL "14.5x114mm"
#undef CALIBER_GYROJET
#define CALIBER_GYROJET "13mm Gyrojet"

// Aliases named after the round, for mod code
#define CALIBER_45_AUTO CALIBER_PISTOL
#define CALIBER_9X19 CALIBER_PISTOL_SMALL
#define CALIBER_44_MAGNUM CALIBER_PISTOL_MAGNUM
#define CALIBER_57X28 CALIBER_PISTOL_FAST
#define CALIBER_556 CALIBER_RIFLE
#define CALIBER_762 CALIBER_RIFLE_MILITARY
#define CALIBER_145X114 CALIBER_ANTIMATERIAL
#define CALIBER_13MM_GYROJET CALIBER_GYROJET

// Ammo sprites (mods/combat_extended/code/ammo_sprites.dm). Also used by the guns modpack, which loads after the mod.
#define CE_AMMO_ICON 'mods/combat_extended/icons/ce_ammo.dmi'
#define CE_AMMO_BOXES_ICON 'mods/combat_extended/icons/ce_ammo_boxes.dmi'

// Round type colours: they tint the tip of a type without its own sprite, 12g hulls and box shells, and magazine marks.
// FMJ, AP and HP are the colours Honk drew. The rest are placeholders until colours are chosen.
#define CE_AMMO_COLOR_FMJ "#565275"
#define CE_AMMO_COLOR_AP "#53a260"
#define CE_AMMO_COLOR_HP "#aa6e5b"
#define CE_AMMO_COLOR_RUBBER "#202020"
#define CE_AMMO_COLOR_PRACTICE "#ffffff"
#define CE_AMMO_COLOR_EMP "#40c0c0"
/// A type whose colour is not chosen yet: loud on purpose.
#define CE_AMMO_COLOR_UNCHOSEN "#ff00ff"
