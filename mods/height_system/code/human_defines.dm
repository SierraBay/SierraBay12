
/mob/living/carbon/human
	var/height = HUMANHEIGHT_MEDIUM // Player's height (default)
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER

// Heights list for height_system mod
GLOBAL_LIST_AS(heights_list, list(HUMANHEIGHT_SHORTEST, HUMANHEIGHT_SHORT, HUMANHEIGHT_MEDIUM, HUMANHEIGHT_TALL, HUMANHEIGHT_TALLEST))
