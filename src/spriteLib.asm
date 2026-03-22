// ---------- SPRITE LIBRARY ----------


SPRITE:
{
  updateSpritePositions:
  {
    jsr updatePlayerState
    jsr updateBulletState
    jsr updateAsteroidState
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

    // check collision with asteroids here by looping through the active asteroids
    // and checking if the player's position overlaps with any of the asteroids'
    // positions. If there is a collision, we can handle it by, for example, ending
    // the game or resetting the player's position.

    clc
    lda playerX
    // add offset for collision detection based on the size of the player's sprite (e.g., 8 pixels)
    adc #PLAYER_SPRITE_OFFSET_X
    sta boxA_x1
    clc
    lda playerY
    // add offset for collision detection based on the size of the player's sprite (e.g., 8 pixels)
    adc #PLAYER_SPRITE_OFFSET_Y
    sta boxA_y1

    clc
    lda playerX
    adc #PLAYER_SPRITE_OFFSET_X+PLAYER_SPRITE_WIDTH
    sta boxA_x2
    clc
    lda playerY
    adc #PLAYER_SPRITE_OFFSET_Y+PLAYER_SPRITE_HEIGHT
    sta boxA_y2

    // now loop through active asteroids and check for collision with player using the collision detection routine. We can set the collision variables before calling the routine to specify which two objects we want to check for collision based on their X and Y positions.
    ldx #0
  checkAsteroidCollisionLoop:
    lda asteroid_enabled_flags
    and sprite_enabled_bitmap,x
    beq noAsteroidCollisionCheck
    // asteroid is active, so we set the collision variables for the asteroid's position and call
    // the collision detection routine to check for collision between the player and this asteroid
    clc
    lda asteroidX,x
    adc #ASTEROID_SPRITE_OFFSET_X
    sta boxB_x1
    clc
    lda asteroidY,x
    adc #ASTEROID_SPRITE_OFFSET_Y
    sta boxB_y1
    clc
    lda asteroidX,x
    adc #ASTEROID_SPRITE_OFFSET_X+ASTEROID_SPRITE_WIDTH
    sta boxB_x2
    clc
    lda asteroidY,x
    adc #ASTEROID_SPRITE_OFFSET_Y+ASTEROID_SPRITE_HEIGHT
    sta boxB_y2
    jsr checkCollision
    lda collisionFlag // side effect setz zero flag
    beq noAsteroidCollisionCheck
    // collisionFlag is set, so we have a collision between the player and this asteroid.
    
    // handle collision (e.g., end game, reset player position, etc.)
    // reset position, lose a life, etc. For now, we'll just reset the player's position to the default starting position.
    lda #DEFAULT_PLAYER_X
    sta playerX
    lda #DEFAULT_PLAYER_Y
    sta playerY
    lda #0  // reset the flag
    sta collisionFlag
    jmp doneCollisionCheck
    
  noAsteroidCollisionCheck:
    inx
    cpx #5
    bne checkAsteroidCollisionLoop

  doneCollisionCheck:
    rts
  }

  checkCollision:
  {
    /*
    if boxA_x1 < boxB_x2 and boxA_x2 > boxB_x1
      and boxA_y1 < boxB_y2 and boxA_y2 > boxB_y1 then
      collision = true
    else
      collision = false
    */
    lda boxA_x1
    cmp boxB_x2
    bcs noCollision
    lda boxA_x2
    cmp boxB_x1
    bcc noCollision
    lda boxA_y1
    cmp boxB_y2
    bcs noCollision
    lda boxA_y2
    cmp boxB_y1
    bcc noCollision
    // collision = true
    lda #1
    sta collisionFlag
    jmp doneCollisionCheck
  noCollision:
    // collision = false
    lda #0
    sta collisionFlag 
  doneCollisionCheck:
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
    // handled the shot, start the fire timer
    lda #0
    sta playerFired

  noBulletFired:

    // update bullet positions by looping through the bullet slots and checking if they are active by looking at the enabled bitmap. If a bullet is active, we update its position by subtracting the bullet speed from its Y position to move it up the screen. If the bullet's Y position goes below 0, we disable the bullet by clearing the corresponding bit in the enabled bitmap and setting its X position to 0 (which we check for at the start of this routine to determine if the bullet is active or not) to effectively remove it from the screen.
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

    // check for collision with asteroids here by looping through the active asteroids and checking if the bullet's position overlaps with any of the asteroids' positions. If there is a collision, we can handle it by, for example, disabling the bullet and the asteroid and maybe creating an explosion effect.
    clc
    lda bulletX,x
    adc #BULLET_SPRITE_OFFSET_X
    sta boxA_x1
    clc
    lda bulletY,x
    adc #BULLET_SPRITE_OFFSET_Y
    sta boxA_y1
    clc
    lda bulletX,x
    adc #BULLET_SPRITE_OFFSET_X+BULLET_SPRITE_WIDTH
    sta boxA_x2
    clc
    lda bulletY,x
    adc #BULLET_SPRITE_OFFSET_Y+BULLET_SPRITE_HEIGHT
    sta boxA_y2
    
    jsr checkAsteroidCollisions
    
    lda collisionFlag     // if collided
    beq doneMovingBullet  // skip disable if zero
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

  checkAsteroidCollisions:
  {
    // now loop through active asteroids (using y) and check for collision with bullet using the collision detection routine. We can set the collision variables before calling the routine to specify which two objects we want to check for collision based on their X and Y positions.
    ldy #0
  checkAsteroidCollisionLoop:
    lda asteroid_enabled_flags
    and sprite_enabled_bitmap,y
    beq noAsteroidCollisionCheck
    // asteroid is active, so we set the collision variables for the asteroid's position and call
    clc
    lda asteroidX,y
    adc #ASTEROID_SPRITE_OFFSET_X
    sta boxB_x1
    clc
    lda asteroidY,y
    adc #ASTEROID_SPRITE_OFFSET_Y
    sta boxB_y1
    clc
    lda asteroidX,y
    adc #ASTEROID_SPRITE_OFFSET_X+ASTEROID_SPRITE_WIDTH
    sta boxB_x2
    clc
    lda asteroidY,y
    adc #ASTEROID_SPRITE_OFFSET_Y+ASTEROID_SPRITE_HEIGHT
    sta boxB_y2
    jsr checkCollision
    lda collisionFlag
    beq noAsteroidCollisionCheck
    // disable asteroid by clearing the corresponding bit in the enabled bitmap
    lda sprite_enabled_bitmap,y
    eor #$FF
    and asteroid_enabled_flags
    sta asteroid_enabled_flags
    // for now, we won't create an explosion effect, but we could set some variables here to create an explosion sprite at the asteroid's position that would be rendered and animated in the main game loop or in the raster interrupt routine.    
    rts
  noAsteroidCollisionCheck:
    iny
    cpy #5
    bne checkAsteroidCollisionLoop
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

    // set asteroid speed to random value between 1 and 3
    GetRandom() // read random value for asteroid speed
    and #%00000011 // mask to get a value between 0 and 3
    ora #1 // add 1 to get a value between 1 and 4
    sta asteroid_speed,x
    // enable asteroid by setting the corresponding bit in the enabled bitmap
    lda asteroid_enabled_flags
    ora sprite_enabled_bitmap,x
    sta asteroid_enabled_flags

    // generate new asteroid spawn timer
    // GetRandom() 
    lda #30 // minimum spawn time of 30 frames (0.5 seconds at 60fps)
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
      
    // check for collisions between player and asteroids, and bullets and asteroids

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
    sta temp
    lda bullet_enabled_flags
    asl 
    ora temp
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
    sta temp
    lda asteroid_enabled_flags
    asl // shift left 3 to move the enabled bits into the sprite enable bit positions for the asteroid sprites (bits 3-7)
    asl
    asl
    ora temp
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

