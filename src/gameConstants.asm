// ---------- GAME CONSTANTS ----------

// ship direction
.label DIRECTION_UP = %00000001
.label DIRECTION_DOWN = %00000010
.label DIRECTION_LEFT = %00000100
.label DIRECTION_RIGHT = %00001000
.label DIRECTION_NONE = %00000000

.label DEFAULT_PLAYER_X = 160
.label DEFAULT_PLAYER_Y = 225

.label BULLET_Y_OFFSET = 14 // how many pixels above the player sprite the bullet should start (to make it look like it's coming from the ship)

.label PLAYER_SPEED = 2
.label BULLET_SPEED = 4
.label FIRE_TIMER_MAX = 10 // frames to wait before allowing the player to fire again (to prevent firing too rapidly)