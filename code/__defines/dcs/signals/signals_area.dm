// Main area signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of /area/proc/power_change(): (area/apc_area)
#define COMSIG_AREA_POWER_CHANGE "area_apc_power_change"
///from base of /area/proc/set_apc(): (area/apc_area)
#define COMSIG_AREA_APC_ADDED "area_apc_added"
///from base of /area/proc/remove_apc(): (area/apc_area)
#define COMSIG_AREA_APC_REMOVED "area_apc_removed"
