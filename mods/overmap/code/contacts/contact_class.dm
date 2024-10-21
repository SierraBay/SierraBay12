/decl/ship_contact_class
	var/class_short = "Ship"
	var/class_long = "Unknown Ship Class"
	var/min_ship_mass = 0
	var/max_ship_mass = INFINITY

/decl/ship_contact_class/ship
	class_short = "SH"
	class_long = "Ship"
	max_ship_mass = 10000

/decl/ship_contact_class/shuttle
	class_short = "SHUTTLE"
	class_long = "Shuttle"
	max_ship_mass = 10000

/decl/ship_contact_class/destroyer_escort
	class_short = "DE"
	class_long = "Destroyer Escort"
	min_ship_mass = 10000
	max_ship_mass = 50000

/decl/ship_contact_class/destroyer
	class_short = "DD"
	class_long = "Destroyer"
	min_ship_mass = 50000
	max_ship_mass = 100000

/decl/ship_contact_class/cruiser
	class_short = "CA"
	class_long = "Cruiser"
	min_ship_mass = 100000
	max_ship_mass = 250000

/decl/ship_contact_class/capital_ship
	class_short = "CAP"
	class_long = "Capital Ship"
	min_ship_mass = 250000
