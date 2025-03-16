GLOBAL_LIST_INIT(days_per_month)
	days_per_month = list(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	if (isLeap(text2num(time2text(world.realtime, "YYYY"))))
		days_per_month[2] = 29