
INPUT:
{
  readJoystick2:
    lda JOYSTICK_2
    beq joy2Idle
    jmp checkJoy2Up

  joy2Idle:
    lda DIRECTION_NONE
    sta playerDirection
    lda #0
    sta playerFired
    rts
    
  checkJoy2Up:
    lda JOYSTICK_2
    and #JOY_UP
    beq joy2Up
    jmp checkJoy2Down
  joy2Up:
    lda playerDirection
    ora #DIRECTION_UP
    sta playerDirection
    
  checkJoy2Down:
    lda JOYSTICK_2
    and #JOY_DOWN
    beq joy2Down
    jmp checkJoy2Left
  joy2Down:
    lda playerDirection
    ora #DIRECTION_DOWN
    sta playerDirection

  checkJoy2Left:
    lda JOYSTICK_2
    and #JOY_LEFT
    beq joy2Left
    jmp checkJoy2Right
  joy2Left:
    lda playerDirection
    ora #DIRECTION_LEFT
    sta playerDirection

  checkJoy2Right:
    lda JOYSTICK_2
    and #JOY_RIGHT
    beq joy2Right
    jmp checkJoy2Fire
  joy2Right:
    lda playerDirection
    ora #DIRECTION_RIGHT
    sta playerDirection

  checkJoy2Fire:
    lda JOYSTICK_2
    and #JOY_FIRE
    beq joy2Fire
    jmp doneReadJoystick
  joy2Fire:
  // if fireTimer is above 0, it means the gun is still in cooldown,
  // so we skip firing a bullet
    lda fireTimer
    beq fireButtonReady
    jmp doneReadJoystick
  fireButtonReady:
    // inc SCREEN_BORDER_COLOR
    // fire a bullet and restart the fire timer.
    lda #1
    sta playerFired
    lda #FIRE_TIMER_MAX
    sta fireTimer

  doneReadJoystick:
     rts
}