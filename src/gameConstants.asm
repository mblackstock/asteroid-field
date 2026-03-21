// ---------- GAME CONSTANTS ----------

// ship direction
.label DIRECTION_UP = %00000001
.label DIRECTION_DOWN = %00000010
.label DIRECTION_LEFT = %00000100
.label DIRECTION_RIGHT = %00001000
.label DIRECTION_NONE = %00000000


.label PLAYER_SPEED = 1
.label BULLET_SPEED = 2
.label FIRE_TIMER_MAX = 10 // frames to wait before allowing the player to fire again (to prevent firing too rapidly)