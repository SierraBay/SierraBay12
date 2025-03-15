// Bitflags for mutations.
#define STRUCDNASIZE 27
#define   UNIDNASIZE 13

// Generic mutations:
#define MUTATION_COLD_RESISTANCE 1
#define MUTATION_XRAY            2
#define MUTATION_FERAL           3 // Smash objects instead of using them, and harder to grab.
#define MUTATION_CLUMSY          4
#define MUTATION_FAT             5
#define MUTATION_HUSK            6
#define MUTATION_LASER           7 // Harm intent - click anywhere to shoot lasers from eyes.
#define MUTATION_HEAL            8 // Healing people with hands.
#define MUTATION_SPACERES        9 // Can't be harmed via pressure damage.
#define MUTATION_SKELETON        10

// Other Mutations:
#define mNobreath      100 // No need to breathe.
#define mRemote        101 // Remote viewing.
#define mRegen         102 // Health regeneration.
#define mRun           103 // No slowdown.
#define mRemotetalk    104 // Remote talking.
#define mMorph         105 // Hanging appearance.
#define mBlend         106 // Nothing. (seriously nothing)
#define mHallucination 107 // Hallucinations.
#define mFingerprints  108 // No fingerprints.
#define mShock         109 // Insulated hands.
#define mSmallsize     110 // Table climbing.

// disabilities
#define NEARSIGHTED    FLAG(0)
#define EPILEPSY       FLAG(1)
#define COUGHING       FLAG(2)
#define NERVOUS        FLAG(3)

// sdisabilities
#define BLINDED     FLAG(0)
#define MUTED       FLAG(1)
#define DEAFENED    FLAG(2)

// The way blocks are handled badly needs a rewrite, this is horrible.
// Too much of a project to handle at the moment, TODO for later.
GLOBAL_VAR_AS(BLINDBLOCK,0)
GLOBAL_VAR_AS(DEAFBLOCK,0)
GLOBAL_VAR_AS(TELEBLOCK,0)
GLOBAL_VAR_AS(FIREBLOCK,0)
GLOBAL_VAR_AS(XRAYBLOCK,0)
GLOBAL_VAR_AS(CLUMSYBLOCK,0)
GLOBAL_VAR_AS(FERALBLOCK, 0)
GLOBAL_VAR_AS(FAKEBLOCK,0)
GLOBAL_VAR_AS(COUGHBLOCK,0)
GLOBAL_VAR_AS(GLASSESBLOCK,0)
GLOBAL_VAR_AS(EPILEPSYBLOCK,0)
GLOBAL_VAR_AS(TWITCHBLOCK,0)
GLOBAL_VAR_AS(NERVOUSBLOCK,0)
GLOBAL_VAR_AS(MONKEYBLOCK, STRUCDNASIZE)

GLOBAL_VAR_AS(BLOCKADD,0)
GLOBAL_VAR_AS(DIFFMUT,0)

GLOBAL_VAR_AS(HEADACHEBLOCK,0)
GLOBAL_VAR_AS(NOBREATHBLOCK,0)
GLOBAL_VAR_AS(REMOTEVIEWBLOCK,0)
GLOBAL_VAR_AS(REGENERATEBLOCK,0)
GLOBAL_VAR_AS(INCREASERUNBLOCK,0)
GLOBAL_VAR_AS(REMOTETALKBLOCK,0)
GLOBAL_VAR_AS(MORPHBLOCK,0)
GLOBAL_VAR_AS(BLENDBLOCK,0)
GLOBAL_VAR_AS(HALLUCINATIONBLOCK,0)
GLOBAL_VAR_AS(NOPRINTSBLOCK,0)
GLOBAL_VAR_AS(SHOCKIMMUNITYBLOCK,0)
GLOBAL_VAR_AS(SMALLSIZEBLOCK,0)
