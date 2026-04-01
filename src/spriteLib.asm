// ---------- SPRITE LIBRARY ----------


SPRITE:
{
  updateSpritePositions:
  {
    jsr updatePlayerState
    jsr updateBulletState
    jsr updateAsteroidState
    jsr checkAllCollisions
  }

  updatePlayerState:
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
    rts
  }

  updateBulletState:
  {

    // decrement fire timer if it's above 0
    lda fireTimer
    beq fireButtonReady
    dec fireTimer

  fireButtonReady:
    // if gun not fired, skip bullet creation and just update positions of
    // any active bullets
    lda playerFired
    beq noBulletFired

    // create a bullet at the player's position in the first available bullet slot.
    // We determine if a bullet slot is available by checking the bullet enabled flags

    ldx #0
  checkBulletSlot:
    lda bullet_enabled_flags
    and sprite_enabled_bitmap,x
    beq bulletSlotAvailable
    inx
    cpx #2
    beq noBulletFired  // no slots available, so we skip creating a new bullet
    jmp checkBulletSlot  

  bulletSlotAvailable:
    lda playerX
    sta bulletX,x
    lda playerY
    sta bulletY,x
    // enable bullet by setting the corresponding bit in the enabled bitmap
    lda bullet_enabled_flags
    ora sprite_enabled_bitmap,x
    sta bullet_enabled_flags

  doneCreatingBullet:
    // handled the shot
    lda #0
    sta playerFired

  noBulletFired:

    // update bullet positions by looping through the bullet slots and
    // checking if they are active by looking at the enabled bitmap.
    // If a bullet is active, we update its position by subtracting
    // the bullet speed from its Y position to move it up the screen.
    // If the bullet's Y position goes below 0, we disable the bullet
    // by clearing the corresponding bit in the enabled bitmap
    
    ldx #0
  moveBulletLoop:
    lda bullet_enabled_flags
    and sprite_enabled_bitmap,x
    beq noBullet
    lda bulletY,x
    sec
    sbc #BULLET_SPEED
    bcc bulletOffScreen  // if negative, bullet is off screen, so we disable it and skip updating its position
    sta bulletY,x
    jmp doneMovingBullet
  bulletOffScreen:
    // disable bullet by clearing the corresponding bit in the enabled bitmap
    lda sprite_enabled_bitmap,x
    eor #$FF
    and bullet_enabled_flags
    sta bullet_enabled_flags
  noBullet:
  doneMovingBullet:
    inx
    cpx #2
    bne moveBulletLoop
    rts
  }

  updateAsteroidState:
  {
    // has timer expired to create new asteroid? create if so
    lda asteroid_spawn_timer
    beq createAsteroid
    dec asteroid_spawn_timer
    jmp doneAsteroidSpawn

    // ---------- asteroid spawning and movement ----------

  createAsteroid:
    // find the first available asteroid slot by checking the enabled bitmap, and create an asteroid in that slot. We set the asteroid's initial Y position to 0 (top of the screen)
    // and we set its X position to a random value between 0 and 255 by reading from the noise generator's random value register, which we set up in the main game setup routine. We also give the asteroid a random speed by reading another random value from the noise generator and masking it to a smaller range (e.g., 1-3) to use as the asteroid's speed.

    ldx #0
  checkAsteroidSlot:
    lda asteroid_enabled_flags
    and sprite_enabled_bitmap,x
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

    // set asteroid speed to random value between 1 and 4
    GetRandom() // read random value for asteroid speed
    and #%00000011 // mask to get a value between 0 and 3
    ora #1 // add 1 to get a value between 1 and 4
    sta asteroid_speed,x
    // enable asteroid by setting the corresponding bit in the enabled bitmap
    lda asteroid_enabled_flags
    ora sprite_enabled_bitmap,x
    sta asteroid_enabled_flags

    // generate new asteroid spawn timer
    GetRandom()           // get a random value
    and #%00011111        // mask to 0-31
    clc
    adc #30               // add minimum spawn time of 30 frames (range: 30-61)
    sta asteroid_spawn_timer 
  doneAsteroidSpawn:

    // move asteroids
    ldx #0
  moveAsteroidLoop:
    lda asteroid_enabled_flags
    and sprite_enabled_bitmap,x
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
    lda sprite_enabled_bitmap,x
    eor #$FF
    and asteroid_enabled_flags
    sta asteroid_enabled_flags
    jmp notAsteroid
  notOffScreen:
  notAsteroid:
    inx
    cpx #5
    bne moveAsteroidLoop
    rts
  }

  checkAllCollisions:
  { 
    lda SPRITE_COLLISION
    beq noCollision     // If 0, no collision at all
    sta collisionBits   // save collision bits to variable for processing
    jsr checkPlayerAsteroidCollision
    jsr checkBulletAsteroidCollision
  noCollision:          // nothing collided at all!
    rts
  }

  checkPlayerAsteroidCollision:
  {
    // first check collision between player and asteroids.
    lda collisionBits 
    and #%00000001    
    beq noCollision

    // check player collided with an asteroid.  
    lda collisionBits
    and #%11111000
    beq noCollision

    // collided with an asteroid (bits 3-7)
    lsr
    lsr
    lsr
    sta temp
    ldx #0
  checkAsteroidCollisionLoop:
    lda temp
    and sprite_enabled_bitmap,x
    beq noAsteroidCollisionCheck
    // for now, just reset the player position.
    lda #DEFAULT_PLAYER_X
    sta playerX
    lda #DEFAULT_PLAYER_Y
    sta playerY
    // TODO: Add explosion logic here (e.g., set variables to create an explosion sprite at the asteroid's position)
    jmp doneAsteroidCollisionCheck
  noAsteroidCollisionCheck:
    inx
    cpx #5
    bne checkAsteroidCollisionLoop
  
  doneAsteroidCollisionCheck:    
  noCollision:  // no collision at all
    rts
  }

  checkBulletAsteroidCollision:
  { 
    
    // now check for collisions between bullets and asteroids.
    lda collisionBits
    and #%00000110
    beq noBulletCollision
    lda collisionBits
    and #%11111000
    beq noBulletCollision

    lda collisionBits
    and #%00000110
    lsr
    sta temp
    lda collisionBits
    and #%11111000
    lsr
    lsr
    lsr
    sta temp2
    // temp has bullet indices, temp2 has asteroid indices that are colliding.
    
    ldx #0
  checkBulletCollisionLoop:
    lda temp
    and sprite_enabled_bitmap,x
    beq noBulletCollisionCheck

    // bullet x is involved in the collision, disable the bullet
    lda sprite_enabled_bitmap,x
    eor #$FF
    and bullet_enabled_flags
    sta bullet_enabled_flags

    ldy #0
  checkAsteroidCollisionLoop2:
    lda temp2
    and sprite_enabled_bitmap,y
    beq noAsteroidCollisionCheck2
    // asteroid Y is involved in the collision, disable the asteroid
    lda sprite_enabled_bitmap,y
    eor #$FF
    and asteroid_enabled_flags
    sta asteroid_enabled_flags
    // TODO: asteroid explosion
    jmp doneAsteroidCollisionCheck2
  noAsteroidCollisionCheck2:
    iny
    cpy #5
    bne checkAsteroidCollisionLoop2
  doneAsteroidCollisionCheck2:
  noBulletCollisionCheck:
    inx
    cpx #2
    bne checkBulletCollisionLoop

  noBulletCollision:  // no bullet collision
    rts
  }

  updateSpriteRegisters:
  {
    // ----- update sprite registers based on game state -----

    // player is always enabled

    // copy playerX and playerY to the first sprite's position registers
    lda playerX
    sta SPRITE_X
    lda playerY
    sta SPRITE_Y 

    // update SPRITE_ENABLE register based on which bullets are active by checking the bullet enabled bitmap and setting the corresponding bits in the sprite enable register for the bullet sprites (bits 1 and 2)
    lda SPRITE_ENABLE
    and #%11111001
    sta tempInterrupt
    lda bullet_enabled_flags
    asl 
    ora tempInterrupt
    sta SPRITE_ENABLE

    ldx #0
  updateBulletLoop:
    lda bullet_enabled_flags
    and sprite_enabled_bitmap,x
    beq noBullet
    // bullet is enabled, so we update its position registers
    txa // transfer X register to A to use it as an index for the bullet arrays
    asl // *2 to convert from bullet index to sprite register index (since each bullet has
    tay // transfer back to Y register to use as index for sprite registers
    lda bulletX,x
    sta SPRITE_X+2,y
    lda bulletY,x
    sta SPRITE_Y+2,y
  noBullet:
    inx
    cpx #2
    bne updateBulletLoop

  doneBulletUpdates:

    // update asteroids that are enabled
    lda SPRITE_ENABLE
    and #%00000111
    sta tempInterrupt
    lda asteroid_enabled_flags
    asl // shift left 3 to move the enabled bits into the sprite enable bit positions for the asteroid sprites (bits 3-7)
    asl
    asl
    ora tempInterrupt
    sta SPRITE_ENABLE

    // update asteroid sprite position registers based on which asteroids are active. We check the enabled bitmap to determine which asteroids are active, and for each active asteroid, we copy its X and Y position to the corresponding sprite registers. Since we have 4 asteroid sprites that can be active at once, we loop through the first 4 bits of the enabled bitmap to check which asteroids are active and update their positions accordingly.
    ldx #0
  updateAsteroidLoop:
    lda asteroid_enabled_flags
    and sprite_enabled_bitmap,x
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

