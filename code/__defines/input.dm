//- BYOND input params IDs

//- Mouse <https://www.byond.com/docs/ref/#/DM/mouse>

/// The mouse button that caused this event
#define MOUSE_BTN "button"

/// Legacy. Truthy when the left/first mouse button caused the event
#define MOUSE_1 "left"

/// Legacy. Truthy when the right/second mouse button caused the event
#define MOUSE_2 "right"

/// Legacy. Truthy when the middle/third mouse button caused the event
#define MOUSE_3 "middle"

/// Truthy when control was down during the event
#define MOUSE_CTRL "ctrl"

/// Truthy when shift was down during the event
#define MOUSE_SHIFT "shift"
/// Truthy when alt was down during the event
#define MOUSE_ALT "alt"

/**
* The event's X / horz pixel coordinate in the pre-transform icon coordinate space
* relative to the parent object. If the icon is not the parent object's main icon
* (eg. it is an overlay) this may be out of bounds.
*/
#define MOUSE_ICON_X "icon-x"

/**
* The event's Y / vert pixel coordinate in the pre-transform icon coordinate space
* relative to the parent object. If the icon is not the parent object's main icon
* (eg. it is an overlay) this may be out of bounds.
*/
#define MOUSE_ICON_Y "icon-y"

/**
* The event's X / horz pixel coordinate in the post-transform icon coordinate space
* relative to itself on the screen. If this would be the same as MOUSE_ICON_X, it is
* not present in parameters.
*/
#define MOUSE_VIS_X "vis-x"

/**
* The event's Y / hvert pixel coordinate in the post-transform icon coordinate space
* relative to itself on the screen. If this would be the same as MOUSE_ICON_Y, it is
* not present in parameters.
*/
#define MOUSE_VIS_Y "vis-y"

/// Coordinates in screen_loc format; "[tile_x]:[pixel_x],[tile_y]:[pixel_y]"
#define MOUSE_SCREEN_LOC "screen-loc"

/// When dragging on a grid control, the starting cell
#define MOUSE_DRAG_CELL "drag-cell"

/// When dragging on a grid control, the ending cell
#define MOUSE_DROP_CELL "drop-cell"


#define MOUSE_DRAG "drag"

/// If the mouse is over a link in maptext, or this event is related to clicking such a link
#define MOUSE_LINK "link"
