/// Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
/// Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
/// Maximum keys per keybind
#define MAX_KEYS_PER_KEYBIND 3
/// Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15

// NOTE: INTENT_HOTKEY_* defines are not actual intents!
// They are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

#define KEYBINDING_CATEGORY_CLIENT "CLIENT"
#define KEYBINDING_CATEGORY_EMOTE "EMOTE"
#define KEYBINDING_CATEGORY_ADMIN "ADMIN"
#define KEYBINDING_CATEGORY_CARBON "CARBON"
#define KEYBINDING_CATEGORY_HUMAN "HUMAN"
#define KEYBINDING_CATEGORY_ROBOT "ROBOT"
#define KEYBINDING_CATEGORY_MISC "MISC"
#define KEYBINDING_CATEGORY_MOVEMENT "MOVEMENT"
#define KEYBINDING_CATEGORY_COMMUNICATION "COMMUNICATION"

/// Returned by a keybinding signal handler when it handles the key.
#define COMSIG_KB_ACTIVATED FLAG_01
