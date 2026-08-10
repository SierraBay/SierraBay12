// Machinery

/obj/item/stock_parts/circuitboard/diseaseanalyser
	name = "circuit board (disease analyser)"
	build_path = /obj/machinery/disease2/diseaseanalyser
	board_type = "machine"

/obj/item/stock_parts/circuitboard/antibodyanalyser
	name = "circuit board (antibody analyser)"
	build_path = /obj/machinery/disease2/antibodyanalyser
	board_type = "machine"

/obj/item/stock_parts/circuitboard/incubator
	name = "circuit board (pathogenic incubator)"
	build_path = /obj/machinery/disease2/incubator
	board_type = "machine"

/obj/item/stock_parts/circuitboard/isolator
	name = "circuit board (pathogenic isolator)"
	build_path = /obj/machinery/disease2/isolator
	board_type = "machine"

/datum/design/circuit/diseaseanalyser
	name = "disease analyser"
	id = "diseaseanalyser"
	req_tech = list(TECH_BIO = 2, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/diseaseanalyser
	sort_string = "FACAN"

/datum/design/circuit/antibodyanalyser
	name = "antibody analyser"
	id = "antibodyanalyser"
	req_tech = list(TECH_BIO = 2, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/antibodyanalyser
	sort_string = "FACAM"

/datum/design/circuit/incubator
	name = "pathogenic incubator"
	id = "incubator"
	req_tech = list(TECH_BIO = 2, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/incubator
	sort_string = "FACAK"

/datum/design/circuit/isolator
	name = "pathogenic isolator"
	id = "isolator"
	req_tech = list(TECH_BIO = 2, TECH_ENGINEERING = 3)
	build_path = /obj/item/stock_parts/circuitboard/isolator
	sort_string = "FACAK"

// Computers

/obj/item/stock_parts/circuitboard/curefab
	name = "circuit board (cure fabricator)"
	build_path = /obj/machinery/computer/curer
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 5)

/obj/item/stock_parts/circuitboard/splicer
	name = "circuit board (disease splicer)"
	build_path = /obj/machinery/computer/diseasesplicer
	origin_tech = list(TECH_DATA = 5, TECH_BIO = 5)

/obj/item/stock_parts/circuitboard/centrifuge
	name = "circuit board (isolation centrifuge)"
	build_path = /obj/machinery/computer/centrifuge
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 3)

/datum/design/circuit/curefab
	name = "cure fabricator"
	id = "curefab"
	req_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 5)
	build_path = /obj/item/stock_parts/circuitboard/curefab
	sort_string = "FACAI"

/datum/design/circuit/centrifuge
	name = "isolation centrifuge console"
	id = "iso_centrifuge"
	req_tech = list(TECH_DATA = 2, TECH_BIO = 3)
	build_path = /obj/item/stock_parts/circuitboard/centrifuge
	sort_string = "FACAG"

/datum/design/circuit/splicer
	name = "disease splicer"
	id = "isplicer"
	req_tech = list(TECH_DATA = 5, TECH_BIO = 5)
	build_path = /obj/item/stock_parts/circuitboard/splicer
	sort_string = "FACAH"
