//#define ZASDBG
#define MULTIZAS

#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED 3

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

// Options for `/atom/movable/var/atmos_canpass`.
/// Air can always pass through this atom.
#define CANPASS_ALWAYS 1
/// Air can only pass through this atom if `density` is `FALSE`.
#define CANPASS_DENSITY 2
/// Air passability is checked through this atom's `c_airblock()` override.
#define CANPASS_PROC 3
/// Air can never pass through this atom.
#define CANPASS_NEVER 4

#define NORTHUP (NORTH|UP)
#define EASTUP (EAST|UP)
#define SOUTHUP (SOUTH|UP)
#define WESTUP (WEST|UP)
#define NORTHDOWN (NORTH|DOWN)
#define EASTDOWN (EAST|DOWN)
#define SOUTHDOWN (SOUTH|DOWN)
#define WESTDOWN (WEST|DOWN)

#define TURF_HAS_VALID_ZONE(T) (istype(T, /turf/simulated) && T:zone && !T:zone:invalid)
#define SHOULD_PARTICIPATE_IN_ZONES(T) (isturf(T) && T:zone_membership_candidate && (!T:external_atmosphere_participation || !T:is_outside()))

#ifdef MULTIZAS

GLOBAL_LIST_AS(gzn_check, list(
	NORTH,
	SOUTH,
	EAST,
	WEST,
	UP,
	DOWN
))

GLOBAL_LIST_AS(csrfz_check, list(
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST,
	NORTHUP,
	EASTUP,
	WESTUP,
	SOUTHUP,
	NORTHDOWN,
	EASTDOWN,
	WESTDOWN,
	SOUTHDOWN
))

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (B.z != A.z) { \
		if (B.z < A.z) { \
			ret = (A.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
		} \
		else { \
			ret = (B.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
		} \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = (A.z == B.z) ? ZONE_BLOCKED : AIR_BLOCKED; \
	} \
	else if (length(A.contents)) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			switch (AM.atmos_canpass) { \
				if (CANPASS_ALWAYS) { \
					continue; \
				} \
				if (CANPASS_DENSITY) { \
					if (AM.density) { \
						ret |= AIR_BLOCKED; \
					} \
				} \
				if (CANPASS_PROC) { \
					ret |= AM.c_airblock(B); \
				} \
				if (CANPASS_NEVER) { \
					ret = BLOCKED; \
				} \
			} \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}
#else

GLOBAL_LIST_AS(csrfz_check, list(
	NORTHEAST,
	NORTHWEST,
	SOUTHEAST,
	SOUTHWEST
))

GLOBAL_LIST_AS(gzn_check, list(
	NORTH,
	SOUTH,
	EAST,
	WEST
))

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = ZONE_BLOCKED; \
	} \
	else if (length(A.contents)) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			switch (AM.atmos_canpass) { \
				if (CANPASS_ALWAYS) { \
					continue; \
				} \
				if (CANPASS_DENSITY) { \
					if (AM.density) { \
						ret |= AIR_BLOCKED; \
					} \
				} \
				if (CANPASS_PROC) { \
					ret |= AM.c_airblock(B); \
				} \
				if (CANPASS_NEVER) { \
					ret = BLOCKED; \
				} \
			} \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}

#endif

#define GAS_STANDARD_AIRMIX "STANDARD_AIRMIX"
