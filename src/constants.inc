;; Main control registers
DEF rJOYP		equ $FF00
DEF rLCDC 		equ $FF40
DEF rLY			equ $FF44 ; for VBlank
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


;; Constants Sound
;; Channel 2
DEF NR21    equ $FF16   ;;Duracion, forma de onda
DEF NR22    equ $FF17   ;;Volumen y envolvente
DEF NR23    equ $FF18   ;;Frecuencia los 8 ultimos bits
DEF NR24    equ $FF19   ;;Frecuencia primeros 3 bits y trigger para activar canal

;; Channel 4
DEF NR41    equ $FF20   ;;Timer
DEF NR42    equ $FF21   ;;Volumen y envolvente
DEF NR43    equ $FF22   ;;Frecuencia y random
DEF NR44    equ $FF23   ;;Control para activar

;; Channel 5/Mezcal
DEF NR50    equ $FF24   ;;Volumen Master
DEF NR51    equ $FF25   ;;Paneo del sonido por los lados
DEF NR52    equ $FF26   ;;Para encender el audio y los canales

;; Datos del sonido
DEF FREQ_R          equ $06D7
;;DEF FREQ_L          equ $0733
;;DEF FREQ_U          equ $05C0
;;DEF FREQ_D          equ $04A8

;; SFX Player
DEF SFX_NONE        equ $FF
DEF SFX_MOVE_R     equ 0
DEF SFX_MOVE_L      equ 1
DEF SFX_MOVE_U      equ 2
DEF SFX_MOVE_D      equ 3

