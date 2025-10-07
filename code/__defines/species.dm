// Species flags
#define SPECIES_FLAG_NO_MINOR_CUT          FLAG_01  // Can step on broken glass with no ill-effects. Either thick skin (diona/vox), cut resistant (slimes) or incorporeal (shadows)
#define SPECIES_FLAG_IS_PLANT              FLAG_02  // Is a treeperson.
#define SPECIES_FLAG_NO_SCAN               FLAG_03  // Cannot be scanned in a DNA machine/genome-stolen.
#define SPECIES_FLAG_NO_PAIN               FLAG_04  // Cannot suffer halloss/recieves deceptive health indicator.
#define SPECIES_FLAG_NO_SLIP               FLAG_05  // Cannot fall over.
#define SPECIES_FLAG_NO_POISON             FLAG_06  // Cannot not suffer toxloss.
#define SPECIES_FLAG_NO_EMBED              FLAG_07  // Can step on broken glass with no ill-effects and cannot have shrapnel embedded in it.
#define SPECIES_FLAG_NO_TANGLE             FLAG_08  // This species wont get tangled up in weeds
#define SPECIES_FLAG_NO_BLOCK              FLAG_09  // Unable to block or defend itself from attackers.
#define SPECIES_FLAG_NEED_DIRECT_ABSORB    FLAG_10  // This species can only have their DNA taken by direct absorption.
#define SPECIES_FLAG_LOW_GRAV_ADAPTED      FLAG_11 // This species is used to lower than standard gravity, affecting stamina in high-grav


// Species spawn flags
#define SPECIES_IS_WHITELISTED                FLAG_01  // Must be whitelisted to play.
#define SPECIES_IS_RESTRICTED                 FLAG_02  // Is not a core/normally playable species. (castes, mutantraces)
#define SPECIES_CAN_JOIN                      FLAG_03  // Species is selectable in chargen.
#define SPECIES_NO_FBP_CONSTRUCTION           FLAG_04  // FBP of this species can't be made in-game.
#define SPECIES_NO_FBP_CHARGEN                FLAG_05  // FBP of this species can't be selected at chargen.
#define SPECIES_NO_ROBOTIC_INTERNAL_ORGANS    FLAG_06  // Species cannot start with robotic organs or have them attached.


// Species appearance flags
#define SPECIES_APPEARANCE_HAS_SKIN_TONE_NORMAL     FLAG_01  // Skin tone selectable in chargen for baseline humans (0-220)
#define SPECIES_APPEARANCE_HAS_SKIN_COLOR           FLAG_02  // Skin colour selectable in chargen. (RGB)
#define SPECIES_APPEARANCE_HAS_LIPS                 FLAG_03  // Lips are drawn onto the mob icon. (lipstick)
#define SPECIES_APPEARANCE_HAS_UNDERWEAR            FLAG_04  // Underwear is drawn onto the mob icon.
#define SPECIES_APPEARANCE_HAS_EYE_COLOR            FLAG_05  // Eye colour selectable in chargen. (RGB)
#define SPECIES_APPEARANCE_HAS_HAIR_COLOR           FLAG_06  // Hair colour selectable in chargen. (RGB)
#define SPECIES_APPEARANCE_RADIATION_GLOWS          FLAG_07  // Radiation causes this character to glow.
#define SPECIES_APPEARANCE_HAS_SKIN_TONE_GRAV       FLAG_08  // Skin tone selectable in chargen for grav-adapted humans (0-100)
#define SPECIES_APPEARANCE_HAS_SKIN_TONE_SPCR       FLAG_09  // Skin tone selectable in chargen for spacer humans (0-165)
#define SPECIES_APPEARANCE_HAS_SKIN_TONE_TRITON     FLAG_10  // Skin tone selectable in chargen for tritonian humans
#define SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS    FLAG_11 // Has multiple base skin sprites to go off of
#define SPECIES_APPEARANCE_HAS_STATIC_HAIR          FLAG_12 // Once selected in chargen, hair won't change through most means (such as being affected by chemicals)
#define SPECIES_APPEARANCE_HAS_A_SKIN_TONE (SPECIES_APPEARANCE_HAS_SKIN_TONE_NORMAL | SPECIES_APPEARANCE_HAS_SKIN_TONE_GRAV | SPECIES_APPEARANCE_HAS_SKIN_TONE_SPCR | SPECIES_APPEARANCE_HAS_SKIN_TONE_TRITON) // Species has a numeric skintone


// Skin Defines
#define SKIN_NORMAL FLAGS_OFF
#define SKIN_THREAT FLAG_01


// Darkvision Levels. White is brightest, darker tints affect vision negatively
#define DARKTINT_GOOD     "#ffffff"
#define DARKTINT_MODERATE "#f9f9f5"
#define DARKTINT_NONE     "#ebebe6"
