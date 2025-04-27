/singleton/species/skrell/skills_from_age(age)
	switch(age)
		if(0 to 22) 	. = 0
		if(23 to 30) 	. = 3
		if(31 to 45)	. = 6
		if(46 to 55)	. = 8
		if(56 to 65)	. = 10
		if(66 to 80)	. = 11
		if(81 to 101)	. = 12
		else			. = 13
