var/global/const/access_employment_records = "ACCESS_EMPLOYMENT_RECORDS"
/datum/access/employment_records
	id = access_employment_records
	desc = "Employment Records"
	region = ACCESS_REGION_COMMAND

var/global/const/access_medical_records = "ACCESS_MEDICAL_RECORDS"
/datum/access/medical_records
	id = access_medical_records
	desc = "Medical Records"
	region = ACCESS_REGION_MEDBAY

var/global/const/access_security_records = "ACCESS_SECURITY_RECORDS"
/datum/access/security_records
	id = access_security_records
	desc = "Security Records"
	region = ACCESS_REGION_SECURITY

#define GETTER_SETTER(PATH, KEY) /datum/computer_file/report/crew_record/proc/get_##KEY(){var/datum/report_field/F = locate(/datum/report_field/##PATH/##KEY) in fields; if(F) return F.get_value()} \
/datum/computer_file/report/crew_record/proc/set_##KEY(given_value){var/datum/report_field/F = locate(/datum/report_field/##PATH/##KEY) in fields; if(F) F.set_value(given_value)}
#define SETUP_FIELD(NAME, KEY, PATH, ACCESS, ACCESS_EDIT) GETTER_SETTER(PATH, KEY); /datum/report_field/##PATH/##KEY;\
/datum/computer_file/report/crew_record/generate_fields(){..(); var/datum/report_field/##KEY = add_field(/datum/report_field/##PATH/##KEY, ##NAME);\
KEY.set_access(ACCESS, ACCESS_EDIT || ACCESS || access_bridge)}

// Fear not the preprocessor, for it is a friend. To add a field, use one of these, depending on value type and if you need special access to see it.
// It will also create getter/setter procs for record datum, named like /get_[key here]() /set_[key_here](value) e.g. get_name() set_name(value)
// Use getter setters to avoid errors caused by typoing the string key.
#define FIELD_SHORT(NAME, KEY, ACCESS, ACCESS_EDIT) SETUP_FIELD(NAME, KEY, simple_text/crew_record, ACCESS, ACCESS_EDIT)
#define FIELD_LONG(NAME, KEY, ACCESS, ACCESS_EDIT) SETUP_FIELD(NAME, KEY, pencode_text/crew_record, ACCESS, ACCESS_EDIT)
#define FIELD_NUM(NAME, KEY, ACCESS, ACCESS_EDIT) SETUP_FIELD(NAME, KEY, number/crew_record, ACCESS, ACCESS_EDIT)
#define FIELD_LIST(NAME, KEY, OPTIONS, ACCESS, ACCESS_EDIT) FIELD_LIST_EDIT(NAME, KEY, OPTIONS, ACCESS, ACCESS_EDIT)
#define FIELD_LIST_EDIT(NAME, KEY, OPTIONS, ACCESS, ACCESS_EDIT) SETUP_FIELD(NAME, KEY, options/crew_record, ACCESS, ACCESS_EDIT);\
/datum/report_field/options/crew_record/##KEY/get_options(){return OPTIONS}

// GENERIC RECORDS
FIELD_SHORT("Name", name, null, access_change_ids)
FIELD_SHORT("Formal Name", formal_name, null, access_change_ids)
FIELD_SHORT("Job", job, null, access_change_ids)
FIELD_LIST("Pronouns", sex, record_pronouns(), null, access_change_ids)
FIELD_NUM("Age", age, null, access_change_ids)
FIELD_LIST_EDIT("Status", status, GLOB.physical_statuses, null, access_medical_records)

FIELD_SHORT("Species",species, null, access_change_ids)
FIELD_LIST("Branch", branch, record_branches(), null, access_change_ids)
FIELD_LIST("Rank", rank, record_ranks(), null, access_change_ids)
FIELD_SHORT("Religion", religion, access_chapel_office, access_change_ids)

FIELD_LONG("General Notes (Public)", public_record, null, access_employment_records)

// MEDICAL RECORDS
FIELD_LIST("Blood Type", bloodtype, GLOB.blood_types, access_medical_records, access_medical_records)
FIELD_LONG("Medical Record", medRecord, access_medical_records, access_medical_records)
FIELD_LONG("Known Implants", implants, access_medical_records, access_medical_records)
FIELD_LONG("Allergies", allergies, access_medical_records, access_medical_records)

// SECURITY RECORDS
FIELD_LIST("Criminal Status", criminalStatus, GLOB.security_statuses, access_security_records, access_brig)
FIELD_LONG("Security Record", secRecord, access_security_records, access_brig)
FIELD_SHORT("DNA", dna, access_security_records, access_brig)
FIELD_SHORT("Fingerprint", fingerprint, access_security_records, access_brig)

// EMPLOYMENT RECORDS
FIELD_LONG("Employment Record", emplRecord, access_employment_records, access_employment_records)
FIELD_SHORT("Home System", homeSystem, access_employment_records, access_change_ids)
FIELD_LONG("Qualifications", skillset, access_employment_records, access_employment_records)

// ANTAG RECORDS
FIELD_SHORT("Faction", faction, access_syndicate, access_syndicate)
FIELD_LONG("Exploitable Information", antagRecord, access_syndicate, access_syndicate)

#undef GETTER_SETTER
#undef SETUP_FIELD
#undef FIELD_SHORT
#undef FIELD_LONG
#undef FIELD_NUM
#undef FIELD_LIST
#undef FIELD_LIST_EDIT
