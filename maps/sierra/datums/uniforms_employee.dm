/* ENGINEERING
 * ===========
 */

/singleton/hierarchy/mil_uniform/nt/eng
	name = "Employee Engineering"
	departments = ENG

	dress_hat = list(\
		/obj/item/clothing/head/soft/yellow, /obj/item/clothing/head/hardhat)
	dress_under = list(\
		/obj/item/clothing/under/rank/engineer, /obj/item/clothing/under/rank/atmospheric_technician, \
		/obj/item/clothing/under/hazard)
	dress_shoes = list(\
		/obj/item/clothing/shoes/workboots, /obj/item/clothing/shoes/workboots)

/singleton/hierarchy/mil_uniform/nt/eng/head
	name = "Employee Engineering Head"
	departments = ENG|COM

	dress_hat = list(\
		/obj/item/clothing/head/soft/yellow, /obj/item/clothing/head/hardhat/white, \
		/obj/item/clothing/head/beret/infinity/engineer_ce)
	dress_under = list(\
		/obj/item/clothing/under/rank/chief_engineer)

/* SUPPLY
 * ======
 */

/singleton/hierarchy/mil_uniform/nt/sup
	name = "Employee Supply"
	departments = SUP

	dress_hat = list(\
		/obj/item/clothing/head/soft/yellow, /obj/item/clothing/head/beret/infinity/cargo)
	dress_under = list(\
		/obj/item/clothing/under/rank/cargotech)
	dress_shoes = list(\
		/obj/item/clothing/shoes/brown, /obj/item/clothing/shoes/dutyboots)

/singleton/hierarchy/mil_uniform/nt/sup/head
	name = "Employee Supply Head"
	departments = SUP|COM

	dress_hat = list(
		/obj/item/clothing/head/soft/yellow, /obj/item/clothing/head/beret/infinity/cargo
		)
	dress_under = list(
		/obj/item/clothing/under/rank/cargo
		)

/* SECURITY
 * ========
 */

/singleton/hierarchy/mil_uniform/nt/sec
	name = "Employee Security"
	departments = SEC

	dress_hat = list(\
		/obj/item/clothing/head/beret/sec/corporate/officer/sierra1, /obj/item/clothing/head/beret/sec/navy/officer/sierra1, \
		/obj/item/clothing/head/beret/sec/sierra1, /obj/item/clothing/head/soft/sec/sierra1, \
		/obj/item/clothing/head/soft/sec/corp/sierra1, /obj/item/clothing/head/soft/sec/corp/guard/sierra1, \
		/obj/item/clothing/head/beret/guard/sierra1)
	dress_under = list(\
		/obj/item/clothing/under/rank/security/sierra1, /obj/item/clothing/under/rank/security/alt/sierra1, \
		/obj/item/clothing/under/rank/security/corp/sierra1, /obj/item/clothing/under/rank/security/corp/alt/sierra1, \
		/obj/item/clothing/under/rank/security/navyblue/sierra1, /obj/item/clothing/under/rank/security/navyblue/alt/sierra1, \
		/obj/item/clothing/under/rank/security2/sierra1)
	dress_shoes = list(\
		/obj/item/clothing/shoes/jackboots)

/singleton/hierarchy/mil_uniform/nt/sec/head
	name = "Employee Security Head"
	departments = SEC|COM

	dress_hat = list(
		/obj/item/clothing/head/beret/sec/corporate/hos/sierra1,
		/obj/item/clothing/head/HoS,
		/obj/item/clothing/head/beret/sec/navy/hos/sierra1
		)
	dress_under = list(\
		/obj/item/clothing/under/rank/head_of_security/sierra1, /obj/item/clothing/under/rank/head_of_security/jensen, \
		/obj/item/clothing/under/rank/head_of_security/navyblue/sierra1, /obj/item/clothing/under/rank/head_of_security/navyblue/alt/sierra1, \
		/obj/item/clothing/under/rank/head_of_security/corp/sierra1, /obj/item/clothing/under/rank/head_of_security/corp/alt/sierra1, \
		/obj/item/clothing/under/hosformalfem/sierra1, /obj/item/clothing/under/hosformalmale/sierra1)

/* MEDICAL
 * =======
 */

/singleton/hierarchy/mil_uniform/nt/med
	name = "Employee Medical"
	departments = MED

	dress_hat = list(\
		/obj/item/clothing/head/soft/mime, /obj/item/clothing/head/nursehat, \
		/obj/item/clothing/head/surgery, /obj/item/clothing/head/surgery/purple, \
		/obj/item/clothing/head/surgery/blue, /obj/item/clothing/head/surgery/green, \
		/obj/item/clothing/head/surgery/black, /obj/item/clothing/head/surgery/navyblue, \
		/obj/item/clothing/head/surgery/lilac, /obj/item/clothing/head/surgery/teal, \
		/obj/item/clothing/head/surgery/heliodor, /obj/item/clothing/head/hardhat/light/medic, \
		/obj/item/clothing/head/beret/infinity/medical)
	dress_under = list(\
		/obj/item/clothing/under/rank/chemist, /obj/item/clothing/under/rank/chemist_new, \
		/obj/item/clothing/under/rank/medical, /obj/item/clothing/under/rank/medical/paramedic, \
		/obj/item/clothing/under/rank/nurse, /obj/item/clothing/under/rank/nursesuit, \
		/obj/item/clothing/under/rank/orderly, /obj/item/clothing/under/rank/virologist, \
		/obj/item/clothing/under/rank/virologist_new, /obj/item/clothing/under/sterile, \
		/obj/item/clothing/under/rank/medical/scrubs, /obj/item/clothing/under/rank/medical/scrubs/blue, \
		/obj/item/clothing/under/rank/medical/scrubs/green, /obj/item/clothing/under/rank/medical/scrubs/purple, \
		/obj/item/clothing/under/rank/medical/scrubs/black, /obj/item/clothing/under/rank/medical/scrubs/navyblue, \
		/obj/item/clothing/under/rank/medical/scrubs/lilac, /obj/item/clothing/under/rank/medical/scrubs/teal, \
		/obj/item/clothing/under/rank/medical/scrubs/heliodor)
	dress_shoes = list(\
		/obj/item/clothing/shoes/white)

/singleton/hierarchy/mil_uniform/nt/med/head
	name = "Employee Medical Head"
	departments = MED|COM

	dress_hat = list(\
		/obj/item/clothing/head/surgery, /obj/item/clothing/head/surgery/purple, \
		/obj/item/clothing/head/surgery/blue, /obj/item/clothing/head/surgery/green, \
		/obj/item/clothing/head/surgery/black, /obj/item/clothing/head/surgery/navyblue, \
		/obj/item/clothing/head/surgery/lilac, /obj/item/clothing/head/surgery/teal, \
		/obj/item/clothing/head/surgery/heliodor, /obj/item/clothing/head/beret/infinity/medical, \
		/obj/item/clothing/head/beret/infinity/medical_cmo)
	dress_under = list(\
		/obj/item/clothing/under/rank/chief_medical_officer, /obj/item/clothing/under/sterile, \
		/obj/item/clothing/under/rank/medical/scrubs, /obj/item/clothing/under/rank/medical/scrubs/blue, \
		/obj/item/clothing/under/rank/medical/scrubs/green, /obj/item/clothing/under/rank/medical/scrubs/purple, \
		/obj/item/clothing/under/rank/medical/scrubs/black, /obj/item/clothing/under/rank/medical/scrubs/navyblue, \
		/obj/item/clothing/under/rank/medical/scrubs/lilac, /obj/item/clothing/under/rank/medical/scrubs/teal, \
		/obj/item/clothing/under/rank/medical/scrubs/heliodor)

/* RESEARCH
 * ========
 */

/singleton/hierarchy/mil_uniform/nt/res
	name = "Employee Research"
	departments = SCI

	dress_hat = list(\
		/obj/item/clothing/head/beret/infinity/science)
	dress_under = list(\
		/obj/item/clothing/under/sterile, /obj/item/clothing/under/rank/scientist, \
		/obj/item/clothing/under/rank/scientist_new)
	dress_shoes = list(\
		/obj/item/clothing/shoes/white)

/singleton/hierarchy/mil_uniform/nt/res/head
	name = "Employee Research Head"
	departments = SCI|COM

	dress_hat = list(
		/obj/item/clothing/head/beret/infinity/science
		)
	dress_under = list(
		/obj/item/clothing/under/rank/research_director,
		/obj/item/clothing/under/rank/research_director/dress_rd,
		/obj/item/clothing/under/rank/research_director/rdalt
		)

/* EXPLORATION
 * ========
 */
/singleton/hierarchy/mil_uniform/nt/exp
	name = "Employee Exploration"
	departments = EXP

	dress_hat = list(
		/obj/item/clothing/head/beret/infinity/exploration
		)

/* COMMAND
 * =======
 */

/singleton/hierarchy/mil_uniform/nt/com
	name = "Employee Command"
	departments = COM
