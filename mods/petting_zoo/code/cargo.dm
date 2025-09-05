/// Domestic vio... pets

// Cargo system

/singleton/hierarchy/supply_pack/livecargo/cat/maine_coon
	name = "Live - Maine Coon"
	contains = list()
	cost = 70
	containertype = /obj/structure/largecrate/animal/cat/maine_coon
	containername = "cat crate"

/singleton/hierarchy/supply_pack/livecargo/cat/floppa
	name = "Live - Caracal"
	contains = list()
	cost = 70
	containertype = /obj/structure/largecrate/animal/cat/floppa
	containername = "MP detention unit"

/singleton/hierarchy/supply_pack/livecargo/penguin
	name = "Live - Penguin"
	contains = list()
	cost = 80
	containertype = /obj/structure/largecrate/animal/penguin
	containername = "penguin crate"

/singleton/hierarchy/supply_pack/livecargo/turkey
	name = "Live - Turkey"
	contains = list()
	cost = 50
	containertype = /obj/structure/largecrate/animal/turkey
	containername = "turkey crate"

/singleton/hierarchy/supply_pack/livecargo/german
	name = "Live - German Shepherd"
	contains = list()
	cost = 100
	containertype = /obj/structure/largecrate/animal/german
	containername = "turkey crate"

// Actual crates

/obj/structure/largecrate/animal/cat/maine_coon
	name = "cat carrier"
	held_type = /mob/living/simple_animal/friendly/cat/maine_coon

/obj/structure/largecrate/animal/cat/floppa
	name = "MP detention unit"
	held_type = /mob/living/simple_animal/friendly/cat/floppa

/obj/structure/largecrate/animal/penguin
	name = "spec ops cargo unit"
	held_type = /mob/living/simple_animal/penguin

/obj/structure/largecrate/animal/turkey
	name = "turkey crate"
	held_type = /mob/living/simple_animal/passive/chicken/turkey

/obj/structure/largecrate/animal/german
	name = "dog carrier"
	held_type = /mob/living/simple_animal/hostile/commanded/dog/german

/// Big ass animals

// Cargo system

/singleton/hierarchy/supply_pack/livecargo/reindeer
	name = "Live - Reindeer"
	cost = 100
	containertype = /obj/structure/largecrate/animal/zoo/reindeer
	containername = "reindeer crate"
	access = access_hydroponics

// Actual crates

/obj/structure/largecrate/animal/zoo/reindeer
	name = "zoo animal carrier"
	held_type = /mob/living/simple_animal/hostile/retaliate/reindeer

/// Contraband, because, u know, they dangerous for a ship, not for a zoo

// Cargo system

/singleton/hierarchy/supply_pack/livecargo/bear
	name = "Live - Bear"
	cost = 100
	containertype = /obj/structure/largecrate/animal/zoo/bear
	containername = "zoo animal carrier"
	access = access_hydroponics
	hidden = 1

/singleton/hierarchy/supply_pack/livecargo/panter
	name = "Live - Panther"
	cost = 100
	containertype = /obj/structure/largecrate/animal/zoo/panter
	containername = "zoo animal carrier"
	access = access_hydroponics
	hidden = 1

/singleton/hierarchy/supply_pack/livecargo/lion
	name = "Live - Lion"
	cost = 100
	containertype = /obj/structure/largecrate/animal/zoo/lion
	containername = "zoo animal carrier"
	access = access_hydroponics
	hidden = 1

// Actual crates

/obj/structure/largecrate/animal/zoo/bear
	name = "zoo animal carrier"
	held_type = /mob/living/simple_animal/hostile/bear

/obj/structure/largecrate/animal/zoo/panter
	name = "zoo animal carrier"
	held_type = /mob/living/simple_animal/hostile/panther

/obj/structure/largecrate/animal/zoo/lion
	name = "zoo animal carrier"
	held_type = /mob/living/simple_animal/hostile/panther/lion
