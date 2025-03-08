/* *
DM version compatibility macros & procs
Retain even if empty - the future exists
*/

#if DM_VERSION < 516

/proc/sign(num)
	if (!num || !isnum(num))
		return 0
	if (num > 0)
		return 1
	return -1

/proc/lerp(low, high, factor)
	if (isnum(low) && isnum(high))
		return low + (high - low) * factor
	crash_with("non-num lerp() is unsupported below byond 516.1648")

#endif

#if DM_VERSION > 515
#define RENDERER_SCREEN_LOC "1,1"
#else
#define RENDERER_SCREEN_LOC "CENTER"
#endif
