// ---------- GAME CONSTANTS ----------

// ship direction
.label DIRECTION_UP = %00000001
.label DIRECTION_DOWN = %00000010
.label DIRECTION_LEFT = %00000100
.label DIRECTION_RIGHT = %00001000
.label DIRECTION_NONE = %00000000

.label DEFAULT_PLAYER_X = 160
.label DEFAULT_PLAYER_Y = 225

// collision box offsets and sizes (relative to sprite position top-left corner)
.label PLAYER_SPRITE_OFFSET_X = 8
.label PLAYER_SPRITE_OFFSET_Y = 8
.label PLAYER_SPRITE_WIDTH = 16
.label PLAYER_SPRITE_HEIGHT = 16

.label BULLET_SPRITE_OFFSET_X = 4
.label BULLET_SPRITE_OFFSET_Y = 4
.label BULLET_SPRITE_WIDTH = 8
.label BULLET_SPRITE_HEIGHT = 8

.label ASTEROID_SPRITE_OFFSET_X = 0
.label ASTEROID_SPRITE_OFFSET_Y = 0
.label ASTEROID_SPRITE_WIDTH = 20
.label ASTEROID_SPRITE_HEIGHT = 20

.label PLAYER_SPEED = 2
.label BULLET_SPEED = 4
.label FIRE_TIMER_MAX = 10 // frames to wait before allowing the player to fire again (to prevent firing too rapidly)