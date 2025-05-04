#define CARGO_POINT_TO_THALLER 15
/datum/controller/subsystem/supply/fire()
	return


/datum/controller/subsystem/supply/add_points_from_source(amount, source)
	department_accounts["Снабжения"].money += amount * CARGO_POINT_TO_THALLER
	point_sources[source] += amount
	point_sources["total"] += amount

#undef CARGO_POINT_TO_THALLER
