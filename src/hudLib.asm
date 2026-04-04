HUD: {
  drawScoreText:
  {
    // This function draws the "SCORE: " text on the screen at the top left corner.
    // It uses the scoreText variable defined in variables.asm, which is encoded in the screencode_upper encoding.

    ldx #0
  drawScoreLoop:
    lda scoreText,x
    beq doneDrawingScoreText // The text is null-terminated, so we stop when we hit a 0 byte.
    sta SCREEN_RAM+10,x // Write the character to the screen
    inx
    jmp drawScoreLoop
  doneDrawingScoreText:
    rts
  }

  drawScore:
  {
    // This function draws the current score on the screen, starting at the position immediately after the "SCORE: " text.
    // It reads the score from the score variable defined in variables.asm, which is a 7-byte array representing each digit of the score.
    ldy #0
    ldx #6 // Start with the highest place value (millions place)
  drawScoreLoop:
    lda score,y
    clc
    adc #$30 // Convert the score digit to its ASCII character code (e.g., 0 -> '0', 1 -> '1', etc.)
    sta SCREEN_RAM+17,x // Write the character to the screen (17 = 10 for "SCORE: " + 7 for the score digits)
    iny
    dex
    bpl drawScoreLoop // Loop until we have drawn all 7 digits (when X goes below 0, we are done)
    rts
  }
  
  addToScore: 
  {
    // Registers:
    // A = value to add to the score (0-9)
    // X = place in the score to add to (0-6, where 0 is the ones place, 1 is the tens place, etc.)

    // The place is where in the score the number should be added.
    // This is how the place values are set up:
    //
    // SCORE: 0 0 0 0 0 0 0
    //
    // Place  6 5 4 3 2 1 0
    //
    // Example: AddToScore(1,2) = This will add 1 to the 2nd place.
    // In this case we are adding 100 to the score.
    clc
    adc score,x
    sta score,x
  checkScoreLoop:
    lda score,x
    cmp #10           // If the sum exceeds 9, we need to carry to the next place.
    bcs nextPlace
    jmp doneAddingScore
  nextPlace:
    sec               // subtract 10 to get the correct digit for the current place
    sbc #10
    sta score,x
    inx               // move to the next higher place
    cpx #7            // too big, we only have 7 places (0-6)
    bcs doneAddingScore
    lda score,x       // add the carry to the next place
    clc
    adc #1            // max is 9+9=18, so we only need to carry 1
    sta score,x
    jmp checkScoreLoop

  doneAddingScore:
    rts
  }
}

