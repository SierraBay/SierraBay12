#define CARGO_POINT_TO_THALLER 15
/datum/controller/subsystem/supply/fire()
	return


/datum/controller/subsystem/supply/add_points_from_source(amount, source)
	department_accounts["Снабжения"].deposit(amount * CARGO_POINT_TO_THALLER, "Sales Transaction of [source]", "Cargo Point Sale")
	point_sources[source] += amount * CARGO_POINT_TO_THALLER
	point_sources["total"] += amount * CARGO_POINT_TO_THALLER

#undef CARGO_POINT_TO_THALLER
