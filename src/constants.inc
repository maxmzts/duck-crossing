;;Canal 1
def NR10 equ $FF10
def NR11 equ $FF11
def NR12 equ $FF12
def NR13 equ $FF13
def NR14 equ $FF14
;;Canal 2
def NR21 equ $FF16	;;Duración, forma de onda
def NR22 equ $FF17	;;Volumen y envolvente
def NR23 equ $FF18	;;Frecuencia los 8 ultimos bits
def NR24 equ $FF19	;;Frecuencia primeros 3 bits y trigger para activar canal
;;Canal 3
def NR30 equ $FF1A
def NR31 equ $FF1B
def NR32 equ $FF1C
def NR33 equ $FF1D
def NR34 equ $FF1E
;;Canal 4
def NR41 equ $FF20	;;Timer
def NR42 equ $FF21	;;Volumen y envolvente
def NR43 equ $FF22	;;Frecuencia y random
def NR44 equ $FF23	;;Control para activar
;;Canal 5/Mezcal
def NR50 equ $FF24	;;Volumen Master
def NR51 equ $FF25	;;Paneo del sonido por los lados
def NR52 equ $FF26	;;Para encender el audio y los canales
;;Joypad
def rJOYP   equ $FF00
def rLY		equ $FF44
def RELATIVE_VALUE	equ $FF00
def SELECT_BUTTONS   equ %00010000

;;Datos del sonido
def FRECUENCY	equ $06D7


;;SFX Player
def SFX_NONE	equ $FF
def SFX_BIP		equ 0 	;;Canal 2(cuadrada)
def SFX_NOISE	equ 1 	;;Canal 4(ruido)
def SFX_CAR		equ 2
def SFX_DIE		equ 3
def SFX_STEP	equ 4