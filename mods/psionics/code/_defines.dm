// Это вот это всё, чтобы не наебашить старые сейвы персонажей

GLOBAL_LIST_AS(psi_faculty_ids, list(PSI_KINESIS, PSI_PATIA, PSI_PRAXIA))
GLOBAL_LIST_AS(psi_faculty_names, list("Кинезис", "Патия", "Праксия")) // за что бог меня покарал за чувствительность к регистру

GLOBAL_LIST_AS(psi_legacy_faculty_ids, list(
	PSI_COERCION      = PSI_PATIA,
	PSI_CONSCIOUSNESS = PSI_PATIA,
	PSI_SHAYMANISM    = PSI_PATIA,
	PSI_PSYCHOKINESIS = PSI_KINESIS,
	PSI_MANIFESTATION = PSI_KINESIS,
	PSI_METAKINESIS   = PSI_KINESIS,
	PSI_ENERGISTICS   = PSI_KINESIS,
	PSI_REDACTION     = PSI_KINESIS
))

GLOBAL_LIST_AS(psi_legacy_faculty_names, list(
	"Coercion"      = "Patia",
	"Consciousness" = "Patia",
	"Shaymanism"    = "Patia",
	"Psychokinesis" = "Kinesis",
	"Manifestation" = "Kinesis",
	"Metakinesis"   = "Kinesis",
	"Energistics"   = "Kinesis",
	"Redaction"     = "Kinesis"
))

/proc/psi_normalize_faculty(faculty)
	return GLOB.psi_legacy_faculty_ids[faculty] || faculty
