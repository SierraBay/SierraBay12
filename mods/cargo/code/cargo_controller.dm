#define CARGO_POINT_TO_THALLER 15
/datum/controller/subsystem/supply/fire()
	return


/datum/controller/subsystem/supply/add_points_from_source(amount, source)
	var/thallers = amount * CARGO_POINT_TO_THALLER
	department_accounts["Снабжения"].deposit(thallers, "Sales Transaction of [source]", "Cargo Point Sale")
	point_sources[source] += thallers
	point_sources["total"] += thallers
	// Odyssey cargo export quota (direct call — callHook allocates a new datum each time).
	if (odyssey_science_enabled && source != "time" && source != "total")
		odyssey_dept_on_cargo_points(thallers, source)

#undef CARGO_POINT_TO_THALLER
