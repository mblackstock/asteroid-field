
// ---------- SCREEN CONSTANTS --------


// Visibility: Due to the screen borders, the default visible origin range is
// roughly X: 24-343 and Y: 50-250.
// A sprite is 24 pixels wide by 21 pixels high.

.label SCREEN_RAM = $0400
.label SCREEN_COLOR_RAM  = $d800

.label SCREEN_CONTROL_1 = $d011
.label SCREEN_CONTROL_2 = $d016
.label SCREEN_MEMORY_SETUP = $d018

.label SCREEN_BORDER_COLOR = $d020
.label SCREEN_BACKGROUND_COLOR = $d021

// colors
.label COLOR_BLACK = 0
.label COLOR_WHITE = 1
.label COLOR_RED = 2
.label COLOR_CYAN = 3
.label COLOR_PURPLE = 4
.label COLOR_GREEN = 5
.label COLOR_BLUE = 6
.label COLOR_YELLOW = 7
.label COLOR_ORANGE = 8
.label COLOR_BROWN = 9
.label COLOR_PINK = 10
.label COLOR_DARK_GREY = 11
.label COLOR_GREY = 12
.label COLOR_LIGHT_GREEN = 13
.label COLOR_LIGHT_BLUE = 14
.label COLOR_LIGHT_GREY = 15

.label DEFAULT_SCREEN_COLOR = COLOR_WHITE
.label DEFAULT_BORDER_COLOR = COLOR_GREY
.label DEFAULT_BACKGROUND_COLOR = COLOR_BLACK

.label SCREEN_HEIGHT = 240
.label SCREEN_WIDTH = 320

.label SCREEN_CLEAR = $e544 // routine to clear the screen
