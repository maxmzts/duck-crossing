INCLUDE "constants.inc"

SECTION "SFX Effects", ROM0

sfx_sq2_play::
    ld a, $10000000
    ld [NR21], a       ;;Ciclo de trabajo 10 -> 50%(forma de la onda)

    or %10000011
    ld [NR22], a        ;;Volumen maximo(1000), envolvente dec(0) y velocidad/periodo 3(011)

    ;;de = 06D7
    ld a, e
    ld [NR23], a        ;;Se pone D7 aqui, los 8 bits bajos
    ld a, d
    and %00000111       ;;Para dejar los 3 bits útiles de d
    or %10000000        ;;pone el trigger a 1 para que suene el canal
    ld [NR24], a        ;,Se pone los otros 3 bits y se activa el canal con 1
    
    ret

sfx_noise_click::
    xor a
    ld [NR41], a        ;;Todo a 0

    ld a, %10000010
    ld [NR42], a        ;;Max vol, dec y per 2

    ld a, %00100010
    ld [NR43], a        ;;0010 -> Frec, 0 -> LSFR, 010 -> reloj

    ld a, %10000000
    ld [NR44], a        ;;Trigger a 1 para activar canal

    ret

sfx_move_r::
    ld de, FREQ_R
    jp sfx_sq2_play