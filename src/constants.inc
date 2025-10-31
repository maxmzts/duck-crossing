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
DEF SCENE_LEVEL_2   equ 3
DEF SCENE_LEVEL_3   equ 4
DEF SCENE_LEVEL_4   equ 5
DEF SCENE_LEVEL_5   equ 6
DEF SCENE_LEVEL_6   equ 7
DEF SCENE_LEVEL_7   equ 8
DEF SCENE_LEVEL_8   equ 9


;; Button bits (para detectar A presionado)
DEF A_PRESSED       equ 0
DEF B_PRESSED       equ 1
DEF SELECT_PRESSED  equ 2
DEF START_PRESSED   equ 3


;;--------------------
;; Constants Sound
;;--------------------
;; Channel 2
DEF NR10    equ $FF10   ;;Duracion, forma de onda

DEF NR11    equ $FF11   ;;Duracion, forma de onda
DEF NR12    equ $FF12   ;;Volumen y envolvente
DEF NR13    equ $FF13   ;;Frecuencia los 8 ultimos bits
DEF NR14    equ $FF14  ;;Frecuencia primeros 3 bits y trigger para activar canal

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

;; Datos del sonido SFX
DEF FREQ_R          equ $06D7   ;; Sonido del movimiento
DEF FREQ_L          equ $0734   ;; Sonido de tecla en menú
DEF FREQ_U          equ $05C0   ;; Sonido de tecla en menú

;; SFX Player IDs
DEF SFX_NONE        equ $FF
DEF SFX_MOVE_R      equ 0
DEF SFX_MOVE_L      equ 1
DEF SFX_MOVE_U      equ 2
DEF SFX_MOVE_D      equ 3
DEF SFX_MENU        equ 4
DEF SFX_KILL        equ 5

;; Datos del sonido música
DEF FREQ_A4         equ $06D6
DEF FREQ_F4         equ $0733
DEF FREQ_C5         equ $0706
DEF FREQ_E5         equ $0739
DEF FREQ_G4         equ $06B2
DEF FREQ_B4         equ $06F7
DEF FREQ_D5         equ $0721
DEF FREQ_F5         equ $0744
DEF FREQ_G5         equ $0759
DEF FREQ_A5         equ $076B
DEF FREQ_C4         equ $060B
DEF FREQ_E4         equ $0672
DEF FREQ_D4         equ $0642
DEF FREQ_Gs4        equ $06C4

;; Música
;; Música ID's
DEF SONG_MAIN       equ 0
DEF SONG_MENU       equ 1
DEF SONG_DEATH      equ 2
DEF SONG_VICTORY    equ 3
DEF MUS_END         equ $FF     ;; Fin de la canción, loop
DEF MUS_REST        equ $FE     ;; Silencio
DEF MUS_NOISE       equ $FD     ;; GOlpe de ruido

