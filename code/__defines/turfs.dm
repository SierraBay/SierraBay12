#define TURF_REMOVE_CROWBAR FLAG_01
#define TURF_REMOVE_SCREWDRIVER FLAG_02
#define TURF_REMOVE_SHOVEL FLAG_03
#define TURF_REMOVE_WRENCH FLAG_04
#define TURF_CAN_BREAK FLAG_05
#define TURF_CAN_BURN FLAG_06
#define TURF_HAS_EDGES FLAG_07
#define TURF_HAS_CORNERS FLAG_08
#define TURF_HAS_INNER_CORNERS FLAG_09
#define TURF_IS_FRAGILE FLAG_10
#define TURF_ACID_IMMUNE FLAG_11
#define TURF_IS_WET FLAG_12
#define TURF_HAS_RANDOM_BORDER FLAG_13
#define TURF_DISALLOW_BLOB FLAG_14
#define TURF_AMBIENT_LIGHT_UPDATE_QUEUED FLAG_15

//Used for floor/wall smoothing
#define SMOOTH_NONE 0	//Smooth only with itself
#define SMOOTH_ALL 1	//Smooth with all of type
#define SMOOTH_WHITELIST 2	//Smooth with a whitelist of subtypes
#define SMOOTH_BLACKLIST 3 //Smooth with all but a blacklist of subtypes

#define RANGE_TURFS(CENTER, RADIUS) block(locate(max(CENTER.x-(RADIUS), 1), max(CENTER.y-(RADIUS),1), CENTER.z), locate(min(CENTER.x+(RADIUS), world.maxx), min(CENTER.y+(RADIUS), world.maxy), CENTER.z))
