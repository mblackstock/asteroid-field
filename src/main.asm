
// ---------- ASTEROID FIELD ----------

BasicUpstart2(main)

#import "memoryMap.asm"
#import "screenConstants.asm"
#import "inputConstants.asm"
#import "spriteConstants.asm"
#import "interruptConstants.asm"
#import "gameConstants.asm"
#import "spriteMacros.asm"
#import "random.asm"

*= GAME_CODE_ADDRESS "Game Code"
#import "gameCode.asm"

*=VARIABLES_ADDRESS "Variables"
#import "variables.asm"

*=LIBRARIES_ADDRESS "Libraries"
#import "inputLib.asm"
#import "spriteLib.asm"
#import "interruptLib.asm"
#import "hudLib.asm"

*=SPRITES_ADDRESS "Sprites"
#import "sprites/sprites.asm"
