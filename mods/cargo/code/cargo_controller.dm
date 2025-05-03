/datum/controller/subsystem/supply/add_points_from_source(amount, source)
	department_accounts["Снабжения"].money += amount * 15
	point_sources[source] += amount
	point_sources["total"] += amount
