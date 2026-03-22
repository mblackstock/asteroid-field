// ---------- SPRITE MACROS ----------

.macro SetUpSprite(spriteNumber, spriteX, spriteY, spriteColor, spriteDataPointer) {
  lda #spriteX
  sta SPRITE_X + (spriteNumber * 2)  // set sprite initial X position
  lda #spriteY
  sta SPRITE_Y + (spriteNumber * 2)  // set sprite Y position

  lda #spriteColor
  sta SPRITE_COLOR+spriteNumber     // set sprite color

  lda #(spriteDataPointer/64)  
  sta SPRITE_POINTER + spriteNumber
}
.macro DisableAllSprites() {
  lda #0
  sta SPRITE_ENABLE  // disable all sprites
}
.macro EnableSprite(spriteNumber) {
  lda SPRITE_ENABLE
  ora #1 << spriteNumber  // enable the specified sprite
  sta SPRITE_ENABLE
}
.macro DisableSprite(spriteNumber) {
  lda SPRITE_ENABLE
  and #~(1 << spriteNumber)  // disable the specified sprite
  sta SPRITE_ENABLE
}
