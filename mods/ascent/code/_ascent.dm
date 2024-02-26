#define COLOR_ASCENT_PURPLE           "#8f2bab"
#define MANTIDIFY(_thing, _name, _desc) \
##_thing/ascent/name = _name; \
##_thing/ascent/desc = "Some kind of strange alien " + _desc + " technology."; \
##_thing/ascent/color = COLOR_ASCENT_PURPLE;

// Ascent culture.
#define CULTURE_ASCENT           "The Ascent"
#define HOME_SYSTEM_KHARMAANI    "Core"
#define FACTION_ASCENT_GYNE      "Ascent Gyne"
#define FACTION_ASCENT_ALATE     "Ascent Alate"
#define FACTION_ASCENT_SERPENTID "Ascent Serpentid"
#define RELIGION_KHARMAANI       "Nest-Lineage Veneration"

//Languages
#define LANGUAGE_MANTID_NONVOCAL   "Ascent-Glow"
#define LANGUAGE_MANTID_VOCAL      "Ascent-Voc"
#define LANGUAGE_MANTID_BROADCAST  "Worldnet"

//Species
#define SPECIES_MONARCH_WORKER     "Monarch Serpentid Worker"
#define SPECIES_MONARCH_QUEEN      "Monarch Serpentid Queen"
#define SPECIES_MANTID_ALATE       "Kharmaan Alate"
#define SPECIES_MANTID_GYNE        "Kharmaan Gyne"
#define ALL_ASCENT_SPECIES list(SPECIES_MANTID_ALATE, SPECIES_MANTID_GYNE, SPECIES_NABBER, SPECIES_MONARCH_QUEEN, SPECIES_MONARCH_WORKER)
