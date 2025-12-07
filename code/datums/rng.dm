#define WRAP_MOD(A, N) (((A) % (N)) + ((A) < 0 ? (ceil(((A) % (N)) / (N)) * (N)) : 0))

/// Compartmentalized PRNG. Allows for coordinated randomness through multiple PRNG datums with the same seed
/datum/prng
	var/seed = 0

/datum/prng/New(rng_seed = null)
	seed(rng_seed)

/// Re-seed the PRNG. Seeds with a value from the builtin rng if no seed is given to ensure different seeds
/datum/prng/proc/seed(new_seed = null)
	if (!new_seed)
		seed = rand(1, SHORT_REAL_LIMIT - 1)
	else
		seed = abs(new_seed)

/// Get a random value between low and high, inclusive.
/// Default PRNG is just a wrapper. Not thread-safe across multiple PRNG datums because state is shared
/datum/prng/proc/random(low = 0, high = null)
	rand_seed(seed)
	seed = rand(low, high)
	return seed

/// Roll for success with the given chance. Returns TRUE if the roll succeeded
/datum/prng/proc/chance(chance)
	if (random(1, 100) <= chance)
		return TRUE
	return FALSE

/// Get a random direction
/datum/prng/proc/random_dir(cardinal_only = FALSE)
	var/dir = SHIFTL(1, random(0,3))
	if (cardinal_only)
		return dir
	else if (chance(50)) // 1/4 * 1/2 = 1/8 chance to get any intercardinal
		// each intercardinal can be made from 2 cardinals so this roll doesn't affect the distribution
		// for example, SOUTHWEST can be rolled via either SOUTH | WEST or WEST | SOUTH
		if(chance(50))
			dir |= turn(dir, 45)
		else
			dir |= turn(dir, -45)
	return dir

/// Block cipher based PRNG
/datum/prng/block
	var/key = 0x1a // 0b011010
	var/key_mask = SHIFTL(1, 6) - 1

/datum/prng/block/random(low = 0, high = null)
	// treat the seed as 4x6 bit blocks, like ABCD
	// XOR each block with the key, then swap them around like BADC
	var/x = 0
	x |= SHIFTL(((seed ^ key) & key_mask), 6) // D
	x |= ((SHIFTR(seed, 6) ^ key) & key_mask) // C
	x |= SHIFTL(((SHIFTR(seed, 12) ^ key) & key_mask), 18) // B
	x |= SHIFTL(((SHIFTR(seed, 18) ^ key) & key_mask), 12) // A

	seed = (seed + 1) % SHORT_REAL_LIMIT
	if (low == 0 && isnull(high))
		// floating point imprecision makes this a pretty poor 0-1 distribution
		// but we can't hack the underlying bits so it's very hard to fix
		return (x / SHORT_REAL_LIMIT)
	return (WRAP_MOD(x - low, high) + low)
