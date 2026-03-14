// ===========================
//   CARP RACE DEFINES
// ===========================

// Race states
#define RACE_STATE_IDLE      0  // Waiting/preparing
#define RACE_STATE_BETTING   1  // Bets accepted
#define RACE_STATE_COUNTDOWN 2  // Countdown to start
#define RACE_STATE_RACING    3  // Race in progress
#define RACE_STATE_FINISHED  4  // Done, showing results

// Timing (BYOND: 1 SECOND = 10 ticks of 0.1s each)
#define RACE_BETTING_DURATION    (15 MINUTES)   // How long bets are open
#define RACE_COUNTDOWN_DURATION  (5 MINUTES)   // Countdown before start
#define RACE_RESET_DELAY         (5 MINUTES)   // Results display time after finish
#define RACE_MAX_DURATION        (5 MINUTES)    // Safety timeout for stuck races

// Race parameters
#define RACE_CARP_COUNT  6
#define RACE_MIN_BET     10
#define RACE_MAX_BET     5000
#define RACE_HOUSE_CUT   0.1   // 10% house edge on payouts

// Landmark name tags (place these in the map editor)
#define RACE_FINISH_TAG    "carp_race_finish"
#define RACE_START_TAG_1   "carp_race_start_1"
#define RACE_START_TAG_2   "carp_race_start_2"
#define RACE_START_TAG_3   "carp_race_start_3"
#define RACE_START_TAG_4   "carp_race_start_4"
#define RACE_START_TAG_5   "carp_race_start_5"
#define RACE_START_TAG_6   "carp_race_start_6"

// Carp color display names (matching icon_sets in space_carp.dm)
#define RACE_COLOR_NAME_1   "Pinkie Flash"
#define RACE_COLOR_NAME_2   "Big Boss"
#define RACE_COLOR_NAME_3   "Kolobok"
#define RACE_COLOR_NAME_4   "Star Fire"
#define RACE_COLOR_NAME_5   "Big Mac"
#define RACE_COLOR_NAME_6   "Squid Ward"

// HTML hex colors for betting terminal UI
#define RACE_HTML_COLOR_1   COLOR_VIOLET
#define RACE_HTML_COLOR_2   COLOR_BLUE
#define RACE_HTML_COLOR_3   COLOR_YELLOW
#define RACE_HTML_COLOR_4   COLOR_PURPLE
#define RACE_HTML_COLOR_5   COLOR_ORANGE
#define RACE_HTML_COLOR_6   COLOR_CYAN

/// Get display name for carp by slot number (1-6)
/proc/get_carp_color_name(num)
	switch(num)
		if(1) return RACE_COLOR_NAME_1
		if(2) return RACE_COLOR_NAME_2
		if(3) return RACE_COLOR_NAME_3
		if(4) return RACE_COLOR_NAME_4
		if(5) return RACE_COLOR_NAME_5
		if(6) return RACE_COLOR_NAME_6
	return "Неизвестный"

/// Get HTML hex color for carp by slot number (1-6)
/proc/get_carp_html_color(num)
	switch(num)
		if(1) return RACE_HTML_COLOR_1
		if(2) return RACE_HTML_COLOR_2
		if(3) return RACE_HTML_COLOR_3
		if(4) return RACE_HTML_COLOR_4
		if(5) return RACE_HTML_COLOR_5
		if(6) return RACE_HTML_COLOR_6
	return COLOR_WHITE
