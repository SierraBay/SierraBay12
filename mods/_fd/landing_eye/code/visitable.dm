/obj/overmap/visitable
	var/free_landing = FALSE

/obj/overmap/visitable/sector
	free_landing = TRUE

/obj/overmap/visitable/ship
	free_landing = TRUE

/obj/overmap/visitable/ship/landable
	free_landing = FALSE
