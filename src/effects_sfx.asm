INCLUDE "constants.inc"

SECTION "SFX Effects", ROM0

;;Canal 2. Onda cuadrada.
sfx_sq2_blip:
   ld a, %10000000      ;;$80
   ld [NR21], a  ;;Ciclo de trabajo 10 -> 50%(forma de la onda)

   or %00000011         ;;$03 se hace OR con a y el resultado es 10000011 -> $83
   ld [NR22], a  ;;Volumen maximo(1000), envolvente dec(0) y velocidad/periodo 3(011)

   ;;de = 06D7
   ld a, e
   ld [NR23], a  ;;Se pone D7 aqui, los 8 bist bajos
   ld a, d
   and %00000111        ;;$07, se usa solo para dejar los otro 3 bits altos utiles de d
   or %10000000         ;;$80, pone el trigger a 1 para que suene el canal
   ld [NR24], a  ;;Se pone los otros 3 bits y se activa el canal con 1
   ret

sfx_noise_click::
   xor a                ;;Pone todo a 0
   ld [NR41], a  ;;Todo a 0

   ld a, %10000010      ;;$82 1000 -> Max vol y 0 -> env dec 010 -> periodo 2
   ld [NR42], a  ;;Max vol, dec y per 2

   ld a, %00100010      ;;$22 0010 -> Frec 0 -> LFSR 010 -> reloj
   ld [NR43], a

   ld a, %10000000      ;;$80 Trigger a 1 para activar canal
   ld [NR44], a
   ret

 sfx_noise_car::
 	xor a
 	ld [NR41], a
 	ld a, %11010011
 	ld [NR42], a
 	ld a, %10110010
 	ld [NR43], a
 	ld a, %10000000
 	ld [NR44], a
 	ret

 sfx_noise_die::
   xor a
   ld [NR41], a
   ld a, %11100010
   ld [NR42], a
   ld a, %01110011
   ld [NR43], a
   ld a, %10000000
   ld [NR44], a
   ret