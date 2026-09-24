/singleton/hierarchy/mil_uniform/scgec
	name = "SCGEC"
	hierarchy_type = /singleton/hierarchy/mil_uniform/scgec
	branches = /datum/mil_branch/scgec

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary

/singleton/hierarchy/mil_uniform/scgec/sec
	name = "SCGEC security"
	departments = SEC

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/security
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov/expedition/security,
		/obj/item/clothing/gloves/thick/duty/solgov/sec
		)

/singleton/hierarchy/mil_uniform/scgec/sec/officer
	name = "SCGEC security officer"
	min_rank = 110

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/officer/security

/singleton/hierarchy/mil_uniform/scgec/med
	name = "SCGEC medical"
	departments = MED

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/medical
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov/expedition/medical,
		/obj/item/clothing/gloves/thick/duty/solgov/med
		)

/singleton/hierarchy/mil_uniform/scgec/med/officer
	name = "SCGEC medical officer"
	min_rank = 110

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/officer/medical

/singleton/hierarchy/mil_uniform/scgec/sci
	name = "SCGEC science"
	departments = SCI

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/research
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov/expedition,
		/obj/item/clothing/gloves/thick/duty/solgov/sci
		)

/singleton/hierarchy/mil_uniform/scgec/sci/officer
	name = "SCGEC science officer"
	min_rank = 110

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/officer/research

/singleton/hierarchy/mil_uniform/scgec/sup
	name = "SCGEC supply"
	departments = SUP

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/supply
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov/expedition/supply,
		/obj/item/clothing/gloves/thick/duty/solgov/sup
		)

/singleton/hierarchy/mil_uniform/scgec/sup/officer
	name = "SCGEC supply officer"
	min_rank = 110

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/officer/supply

/singleton/hierarchy/mil_uniform/scgec/exp
	name = "SCGEC exploration"
	departments = EXP

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/exploration
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov/expedition/exploration,
		/obj/item/clothing/gloves/thick/duty/solgov/exp
		)

/singleton/hierarchy/mil_uniform/scgec/exp/officer
	name = "SCGEC exploration officer"
	min_rank = 110

	utility_under = /obj/item/clothing/under/solgov/utility/expeditionary/officer/exploration
