// A set of constants used to determine which type of mute an admin wishes to apply.
#define MUTE_IC        FLAG_01
#define MUTE_OOC       FLAG_02
#define MUTE_PRAY      FLAG_03
#define MUTE_ADMINHELP FLAG_04
#define MUTE_DEADCHAT  FLAG_05
#define MUTE_AOOC      FLAG_06
#define MUTE_ALL       FLAGS_ON

// Some constants for DB_Ban
#define BANTYPE_PERMA       1
#define BANTYPE_TEMP        2
#define BANTYPE_JOB_PERMA   3
#define BANTYPE_JOB_TEMP    4
#define BANTYPE_ANY_FULLBAN 5 // Used to locate stuff to unban.

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 // Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Admin permissions.
#define R_BUILDMODE      FLAG_01
#define R_ADMIN          FLAG_02
#define R_BAN            FLAG_03
#define R_FUN            FLAG_04
#define R_SERVER         FLAG_05
#define R_DEBUG          FLAG_06
#define R_POSSESS        FLAG_07
#define R_PERMISSIONS    FLAG_08
#define R_STEALTH        FLAG_09
#define R_REJUVINATE     FLAG_10
#define R_VAREDIT        FLAG_11
#define R_SOUNDS         FLAG_12
#define R_SPAWN          FLAG_13
#define R_MOD            FLAG_14
// [SIERRA-EDIT] - XENO WHITELIST
//#define R_HOST           FLAG(14) // SIERRA-EDIT - ORIGINAL
#define R_XENO           FLAG_15
#define R_HOST           FLAG_16
// [SIERRA-EDIT]
#define R_INVESTIGATE    (R_ADMIN | R_MOD)
#define R_MAXPERMISSION  R_HOST

#define ADDANTAG_PLAYER    FLAG_01  // Any player may call the add antagonist vote.
#define ADDANTAG_ADMIN     FLAG_02  // Any player with admin privilegies may call the add antagonist vote.
#define ADDANTAG_AUTO      FLAG_03  // The add antagonist vote is available as an alternative for transfer vote.

#define TICKET_CLOSED 0   // Ticket has been resolved or declined
#define TICKET_OPEN     1 // Ticket has been created, but not responded to
#define TICKET_ASSIGNED 2 // An admin has assigned themself to the ticket and will respond

#define LAST_CKEY(M) (M.ckey || M.last_ckey)
#define LAST_KEY(M)  (M.key || M.last_ckey)
