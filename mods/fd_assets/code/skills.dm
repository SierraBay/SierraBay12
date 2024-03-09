#define SKILL_ARMAMENT      /singleton/hierarchy/skill/security/armament

/singleton/hierarchy/skill/security/armament
	ID = "armament"
	name = "Armament Calibration"
	desc = "Allows you to operate ship heavy armament."
	levels = list( "Unskilled"			= "You know where to load new ammo box, or why you shouldn't hit torpedo with the hammer, but nothing more. You will have a hell of a ride trying to calibrate big cannons.",
						"Basic"				= "You used to operating small calibers, mostly used on jets and gunboats, but not much more. Complex things, like BSA or energy-based armament is still far ahead for you.",
						"Trained"			= "You feeling comfortable operating ship heavy weaponry and don't need to bother with torpedo's course management.",
						"Experienced"		= "You probably spent YEARS, managing, fixing and firing big cannons. You mastered it to the point you doing most of the things on auto.",
						"Master"		= "You love your cannon. Your cannon nothing without you and you are nothing without your cannon. You can safely operate any existing weaponry and even some experimental ones, like ion prism. You need only a few seconds to calibrate them.")
	default_max = SKILL_MAX
