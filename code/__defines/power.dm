/// Power channel alias for equipment-powered local consumers.
#define PW_CHANNEL_EQUIPMENT EQUIP
/// Power channel alias for lighting-powered local consumers.
#define PW_CHANNEL_LIGHTING LIGHT
/// Power channel alias for environment-powered local consumers.
#define PW_CHANNEL_ENVIRONMENT ENVIRON

/// Local powernet will never provide power, regardless of APC state.
#define PW_ALWAYS_UNPOWERED FLAG_01
/// Local powernet is always considered powered, regardless of APC state.
#define PW_ALWAYS_POWERED FLAG_02

/// Roughly 1/2000 chance of a machine flickering on a given process tick.
#define MACHINE_FLICKER_CHANCE 0.05
