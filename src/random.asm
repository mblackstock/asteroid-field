.macro SetUpRandom() {

  lda #$FF  // maximum frequency value
  sta $D40E // voice 3 frequency low byte
  sta $D40F // voice 3 frequency high byte
  lda #$80  // noise waveform, gate bit off
  sta $D412 // voice 3 control register
}

.macro GetRandom() {
  lda $D41B // read random value from noise generator
}
