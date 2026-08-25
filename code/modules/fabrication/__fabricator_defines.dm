#define FABRICATOR_CLASS_GENERAL "general"
#define FABRICATOR_CLASS_MICRO   "microlathe"
#define FABRICATOR_CLASS_FOOD    "food"

// Called after an item is created by a fabricator.
/atom/proc/PostFabrication()
	SHOULD_CALL_PARENT(TRUE)
	return
