;; Main control registers
DEF rJOYP		equ $FF00
DEF rLCDC 		equ $FF40
DEF rLCD_STAT 	equ $FF41
DEF rSCY 		equ $FF42
DEF rSCX 		equ $FF43
DEF rLY			equ $FF44 ; for VBlank
DEF rLYC 		equ $FF45
DEF rDMA		equ $FF46
DEF rBGP		equ $FF47
DEF rOBJP0		equ $FF48

;; Memory map
DEF VRAM_START	equ $8000 ; starts on the tile region
DEF VRAM_SCREEN	equ $9800 ; region for the screen
DEF VRAM_END	equ $9FFF ; 8KB

DEF WRAM_START 	equ $C000
DEF WRAM_END 	equ $CFFF ; 4KB

DEF OAM_START	equ $FE00
DEF OAM_END		equ $FE9F ; 160 bytes

;; rLCDC control bits
DEF rLCDC_obj_enable 		equ 1 ; set to enable sprites
DEF rLCDC_16x8_obj_enable 	equ 2 ; set to enable 16x8 sprites
DEF rLCDC_screen_power	 	equ 7 ; set to turn on screen, res to turn off

;; rJOYP control bits
DEF SELECT_BUTTONS 	equ $10  ;; it selects the button panel (select, start, B, A)
DEF SELECT_PAD 		equ $20      ;; it selects pad panel (up, down, left, right)
DEF RIGHT_PRESSED	equ 0
DEF LEFT_PRESSED	equ 1
DEF UP_PRESSED		equ 2
DEF DOWN_PRESSED	equ 3

;; Interrupt enable
DEF rIE 		equ $FFFF
def B_IE_JOYPAD equ 4 ; 1 = joypad interrupt is enabled [r/w]
def B_IE_SERIAL equ 3 ; 1 = serial interrupt is enabled [r/w]
def B_IE_TIMER  equ 2 ; 1 = timer  interrupt is enabled [r/w]
def B_IE_STAT   equ 1 ; 1 = STAT   interrupt is enabled [r/w]
def B_IE_VBLANK equ 0 ; 1 = VBlank interrupt is enabled [r/w]

;; Interrupt flag
DEF rIF 		equ $FF0F
DEF B_IF_VBLANK equ 0

;; PALLETES
DEF DEFAULT_PALETTE	equ %11100100
DEF FADE_1_PALLETE	equ %11100101
DEF FADE_2_PALLETE	equ %11101001
DEF FADE_3_PALLETE	equ %11101010
DEF FADE_4_PALLETE	equ %11111010
DEF FADE_5_PALLETE	equ %11111110
DEF FADE_6_PALLETE	equ %11111111

;; Tiles
DEF TILE_SIZE equ $10

;; Vblank
DEF VBLANK_LAYER equ 144

;; Scene IDs
DEF SCENE_TITLE     equ 0
DEF SCENE_LEVEL_1   equ 1
DEF SCENE_GAME_OVER equ 2

;; Button bits (para detectar A presionado)
DEF A_PRESSED       equ 0
DEF B_PRESSED       equ 1
DEF SELECT_PRESSED  equ 2
DEF START_PRESSED   equ 3


