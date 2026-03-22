
// ---------- GAME CODE ----------

main:
	ldx #$ff // Initialize stack pointer
	txs

	jsr INTERRUPT.setupRasterInterrupt

gameSetup:

  // set up noise generaator for random numbers
  SetUpRandom()

  // set the border color
  lda #DEFAULT_BORDER_COLOR
  sta SCREEN_BORDER_COLOR

  // set the background color
  lda #DEFAULT_BACKGROUND_COLOR
  sta SCREEN_BACKGROUND_COLOR

  // set the screen color
  lda #DEFAULT_SCREEN_COLOR
  sta SCREEN_COLOR_RAM

  // clear the screen
  jsr SCREEN_CLEAR

  //set up our sprites

  SetUpSprite(0, 150, 150, COLOR_GREEN, shipSprite)
  SetUpSprite(1, 100, 100, COLOR_WHITE, bulletSprite)
  SetUpSprite(2, 100, 100, COLOR_WHITE, bulletSprite)
  SetUpSprite(3, 24, 50, COLOR_WHITE, asteroidSprite)
  SetUpSprite(4, 200, 200, COLOR_WHITE, asteroidSprite)
  SetUpSprite(5, 200, 200, COLOR_WHITE, asteroidSprite)
  SetUpSprite(6, 200, 200, COLOR_WHITE, asteroidSprite)
  SetUpSprite(7, 200, 200, COLOR_WHITE, asteroidSprite)

  DisableAllSprites()
  EnableSprite(0)
  // EnableSprite(1)
  //EnableSprite(3)

  GetRandom() // read random value for asteroid spawn timer
  sta asteroid_spawn_timer

gameLoop:
  WaitFrame:
    lda CURRENT_RASTER_LINE   // Load current raster line
    cmp #$f8                // Compare to a specific line (e.g., $F8)
    bne WaitFrame           // Loop until raster reaches that line
    
    jsr INPUT.readJoystick2
  jsr SPRITE.updateSpritePositions

  // sprites update their positions in the interrupt routine,
  // which runs every frame, so they will be updated based on the
  // new player position on the next frame. This way we can ensure
  // that sprite updates are synced with the screen refresh and
  // avoid any potential flickering or tearing issues that could
  // arise from updating sprite positions in the main game loop.
    
  jmp gameLoop
