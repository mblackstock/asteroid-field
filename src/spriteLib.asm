// ---------- SPRITE LIBRARY ----------


SPRITE:
{
  updateSpritePositions:
  {
    // read player direction and update playerX and playerY accordingly
    lda playerDirection
    beq noMovement

    // move up
    and #DIRECTION_UP
    beq notUp
    lda playerY
    clc
    adc #-PLAYER_SPEED
    sta playerY
  notUp:
    // move down
    lda playerDirection
    and #DIRECTION_DOWN
    beq notDown
    lda playerY
    clc
    adc #PLAYER_SPEED
    sta playerY
  notDown:
    lda playerDirection
    and #DIRECTION_LEFT
    beq notLeft
    lda playerX
    clc
    adc #-PLAYER_SPEED
    sta playerX
  notLeft:
    // move right
    lda playerDirection
    and #DIRECTION_RIGHT
    beq notRight
    lda playerX
    clc
    adc #PLAYER_SPEED
    sta playerX
  notRight:
  noMovement:
    // after processing input, reset playerDirection to none
    lda #DIRECTION_NONE
    sta playerDirection

    // decrement fire timer if it's above 0
    lda fireTimer
    beq fireButtonReady
    dec fireTimer

  fireButtonReady:
    // if gun not fired, skip bullet creation and just update positions of
    // any active bullets
    lda playerFired
    beq noBulletFire

    // create a bullet at the player's position in the first
    // available bullet slot (we have 2 bullet slots, so we check
    // if bulletX is 0 to determine if the first bullet slot is
    // available, and if not, we check if bulletX+1 is 0 to determine
    // if the second bullet slot is available. If both are full,
    // we skip creating a new bullet and just reset playerFired to
    // 0 so that the next time the player fires, we will check again.
    lda bulletX
    beq createBulletInSlot1
    lda bulletX+1
    beq createBulletInSlot2
    jmp doneCreatingBullet  // if both bullet slots are full, we skip creating a new bullet and just reset playerFired to 0 so that the next time the player fires, we will check again for an open bullet slot and create a new bullet if one is available

  createBulletInSlot1:
    .print "Creating bullet in slot 1"
    // set bullet 1 position to player position
    lda playerX
    sta bulletX
    lda playerY
    sta bulletY
    jmp doneCreatingBullet

  createBulletInSlot2:
    .print "Creating bullet in slot 2"
    lda playerX
    sta bulletX+1
    lda playerY
    sta bulletY+1

  doneCreatingBullet:
    // handled the shot, start the fire timer
    lda #0
    sta playerFired

  noBulletFire:

    // now update bullet positions (subtract bullet speed from Y position)
    lda bulletX
    beq checkBullet2
    sec
    lda bulletY
    sbc #BULLET_SPEED
    bcc bullet1OffScreen  // if negative, bullet is off screen, so we disable it and skip updating its position
    sta bulletY
    jmp checkBullet2
  bullet1OffScreen:
    lda #0
    sta bulletX   // disables bullet by setting its X position to 0, which we check for at the start of this routine to determine if the bullet is active or not

  checkBullet2:
    lda bulletX+1
    beq doneBullets
    sec
    lda bulletY+1
    sbc #BULLET_SPEED
    bcc bullet2OffScreen  // if negative, bullet is off screen, so we disable it and skip updating its position
    sta bulletY+1
    jmp doneBullets
  bullet2OffScreen:
    lda #0
    sta bulletX+1   // disables bullet by setting its X position to 0, which we check for at the start of this routine to determine if the bullet is active or not

  doneBullets:
    
    // has timer expired to create new asteroid? create if so
    lda asteroid_spawn_timer
    beq createAsteroid
    dec asteroid_spawn_timer
    jmp doneAsteroidSpawn

    createAsteroid:
      // find the first available asteroid slot by checking the enabled bitmap, and create an asteroid in that slot. We set the asteroid's initial Y position to 0 (top of the screen)
      // and we set its X position to a random value between 0 and 255 by reading from the noise generator's random value register, which we set up in the main game setup routine. We also give the asteroid a random speed by reading another random value from the noise generator and masking it to a smaller range (e.g., 1-3) to use as the asteroid's speed.

      ldx #0
    checkAsteroidSlot:
      lda SPRITE_ENABLE
      and asteroid_enabled_bitmap,x
      beq asteroidSlotAvailable
      inx
      cpx #5
      beq doneAsteroidSpawn 
      jmp checkAsteroidSlot

    asteroidSlotAvailable:
      // set asteroid X position to random value between 0 and 255
      GetRandom() // read random value for asteroid X position
      sta asteroidX,x
      // set asteroid Y position to 0 (top of the screen)
      lda #0
      sta asteroidY,x

      // set asteroid speed to random value between 1 and 3
      GetRandom() // read random value for asteroid speed
      and #%00000011 // mask to get a value between 0 and 3
      ora #1 // add 1 to get a value between 1 and 4
      sta asteroid_speed,x
      // enable asteroid by setting the corresponding bit in the enabled bitmap
      lda SPRITE_ENABLE
      ora asteroid_enabled_bitmap,x
      sta SPRITE_ENABLE

      // generate new asteroid spawn timer
      // GetRandom() 
      lda #30 // minimum spawn time of 30 frames (0.5 seconds at 60fps)
      sta asteroid_spawn_timer 
    doneAsteroidSpawn:

    // move asteroids
    ldx #0
  moveAsteroidLoop:
    lda SPRITE_ENABLE
    and asteroid_enabled_bitmap,x
    beq notAsteroid
    // asteroid is enabled, so we update its position by adding its speed to
    // its Y position
    lda asteroidY,x
    clc
    adc asteroid_speed,x
    sta asteroidY,x
    // if the asteroid's Y position is greater than the screen height, we disable it by
    // clearing the corresponding bit in the enabled bitmap and skip updating its position
    clc
    cmp #SCREEN_HEIGHT
    bcc notOffScreen
    lda #0
    sta asteroidY,x
    // asteroid is off screen, so we disable it
    lda asteroid_enabled_bitmap,x
    eor #$FF
    and SPRITE_ENABLE
    sta SPRITE_ENABLE
    jmp notAsteroid
  notOffScreen:
  notAsteroid:
    inx
    cpx #5
    bne moveAsteroidLoop
    
    // check for collisions between player and asteroids, and bullets and asteroids

    rts
  }

  updateSpriteRegisters:
  {
    // copy playerX and playerY to the first sprite's position registers
    lda playerX
    sta SPRITE_X
    lda playerY
    sta SPRITE_Y

    // if playerX is 0, it means the player sprite is inactive, so we skip enabling it and updating its position registers
  
    // reset bullet sprite enable bits (we will set them again if the bullets are active after we update their positions)
    lda SPRITE_ENABLE
    and #%11111001
    sta SPRITE_ENABLE
  checkBullet1:
    lda bulletX
    beq checkBullet2
    lda SPRITE_ENABLE
    ora #%00000010
    sta SPRITE_ENABLE

    // update bullet sprite position registers
    lda bulletX
    sta SPRITE_X+2
    lda bulletY
    sta SPRITE_Y+2
  checkBullet2:
    lda bulletX+1
    beq doneBulletUpdates
    lda SPRITE_ENABLE
    ora #%00000100
    sta SPRITE_ENABLE
    lda bulletX+1
    sta SPRITE_X+4
    lda bulletY+1
    sta SPRITE_Y+4
  doneBulletUpdates:

    // update asteroid sprite position registers based on which asteroids are active. We check the enabled bitmap to determine which asteroids are active, and for each active asteroid, we copy its X and Y position to the corresponding sprite registers. Since we have 4 asteroid sprites that can be active at once, we loop through the first 4 bits of the enabled bitmap to check which asteroids are active and update their positions accordingly.

    ldx #0
  updateAsteroidLoop:
    lda SPRITE_ENABLE
    and asteroid_enabled_bitmap,x
    beq notAsteroid
    // asteroid is enabled, so we update its position registers
    txa // transfer X register to A to use it as an index for the asteroid arrays
    asl // *2 to convert from asteroid index to sprite register index (since each asteroid has 2 sprite registers for X and Y)
    tay // transfer back to Y register to use as index for sprite registers
    lda asteroidX,x
    sta SPRITE_X+6,y
    lda asteroidY,x
    sta SPRITE_Y+6,y
  notAsteroid:
    inx
    cpx #5
    bne updateAsteroidLoop

    rts
  }
}

