
// ---------- VARIABLES ----------

temp: .byte 0
// system vars
frameCounter: .byte 0

// player position
playerX: .byte 150
playerY: .byte 150
playerDirection: .byte DIRECTION_NONE
playerFired: .byte 0
fireTimer: .byte FIRE_TIMER_MAX // frames to wait before allowing the player to
// fire again (to prevent firing too rapidly)

// two bullet positions
bullet_enabled_flags: .byte 0 // each bit represents whether the corresponding bullet is active or not

bulletX:
  .byte 0
  .byte 0

bulletY:
  .byte 0
  .byte 0

// 5 asteroids
asteroid_spawn_timer: .byte 0 // frames to wait before spawning the next asteroid

asteroid_speed:
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0

asteroidX:
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0

asteroidY:
  .byte 0
  .byte 0
  .byte 0
  .byte 0
  .byte 0 

asteroid_enabled_flags: .byte 0 // each bit represents whether the corresponding asteroid is active or not

// bitmaps for checking if a bullet or asteroid is enabled based on the bit index
sprite_enabled_bitmap:
  .byte %00000001
  .byte %00000010
  .byte %00000100
  .byte %00001000
  .byte %00010000
  .byte %00100000
  .byte %01000000
  .byte %10000000
