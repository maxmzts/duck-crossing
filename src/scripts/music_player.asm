INCLUDE "constants.inc"
INCLUDE "music_data.inc"

SECTION "Musica RAM", WRAM0
mus_ptr_lo:         ds 1        ;;Puntero partitura actual, LOW
mus_ptr_hi:         ds 1        ;;Puntero partitura actual, HIGH
mus_ptr0_lo:        ds 1        ;;Puntero al inicio de la canción
mus_ptr0_hi:        ds 1        ;;Puntero al inicio de la canción
mus_dur:            ds 1        ;;Frames restantes nota actual
mus_playing:        ds 1        ;;Indica si el player esta activo
mus_trig_needed:    ds 1        ;;Marca si hay que hacer trigger en la primera nota al iniciar o cambiar la canción

SECTION "Music Player", ROM0

;;Init: Configura el Canal 1 y limpia el estado de reproducción
music_init::
    xor a
    ld [NR10], a

    ld a, %10000000     ;50% y 0
    ld [NR11], a

    ld a, %00010000     ;vol=1
    ld [NR12], a

    ;;Estado del player
    xor a
    ld [mus_dur], a             ;;Sin evento activo
    ld [mus_playing], a         ;;Parado
    ld [mus_trig_needed], a     ;;Sin trigger pendiente

    ret

;;Por ID de la tabla de music_data, cambia de canción
music_play_id::
    ld h, HIGH(SONG_TABLE)
    ld l, LOW(SONG_TABLE)
    add a                       ;;Cada entrada 2 bytes
    ld e, a
    ld d, 0
    add hl, de                  ;;HL = SONG_TABLE + 2*A

    ld a, [hl+]                 ;;LOW
    ld [mus_ptr_lo], a
    ld [mus_ptr0_lo], a

    ld a, [hl]                  ;;HIGH
    ld [mus_ptr_hi], a
    ld [mus_ptr0_hi], a

    xor a
    ld [mus_dur], a
    ld a, 1
    ld [mus_playing], a
    ld [mus_trig_needed], a     ;;TRigger en la primera nota
    ret

;;Stop, para la música
music_stop::
    xor a
    ld [mus_playing], a

    ret

;;Update, llamada en cada frame
music_update::
    ;;Sin mus_playing se sale
    ld a, [mus_playing]
    or a
    ret z

    ;;Ver si la canción continua, en caso de que mus_dur sea mayor de 0, decrementa y continua, sino pasa a la siguiente nora
    ld a, [mus_dur]
    or a
    jr z, .next_event
    dec a
    ld [mus_dur], a
    ret

    ;;SI mus_dur = 0
    .next_event:
        ;;Siguiente evento, carga el puntero en HL
        ld a, [mus_ptr_lo]
        ld l, a
        ld a, [mus_ptr_hi]
        ld h, a

        ld a, [hl]
        inc hl

        ;;Si el siguiente byte es MUS_END resetea el puntero y loopea, sino salta a comprobar si es MUS_REST
        cp MUS_END
        jr nz, .chk_rest

        ld a, [mus_ptr0_lo]
        ld [mus_ptr_lo], a
        ld l, a

        ld a, [mus_ptr0_hi]
        ld [mus_ptr_hi], a
        ld h, a

        ld a, [hl]
        inc hl
        jr .chk_rest
    
    .chk_rest:
        cp MUS_REST
        jr nz, .note_event

        ;;Lee la duración y actualzia el puntero, sino salta a leer la nota
        ld a, [hl]
        inc hl
        ld [mus_dur], a

        jr .store_ptr

    .note_event:
        ;;Se lee el LOW
        ld e, a
        ld a, [hl]
        inc hl
        ;;Se lee la duración
        ld [mus_dur], a
        ld a, [hl]
        inc hl
        ;;Se lee el HIGH
        ld d, a

        ;;Se configura el canal 1 con los datos leídos
        ld a, e
        ld [NR13], a
        ld a, d
        and %00000111
        ld b, a

        ;;Se comprubea si tiene trigger o no
        ld a, [mus_trig_needed]
        or a
        jr z, .no_trigger
            ld a, b
            or %10000000
            ld [NR14], a
            xor a
            ld [mus_trig_needed], a
            jr .store_ptr

        .no_trigger:
            ld a, b
            ld [NR14], a

    ;;GUarda el puntero actualizado
    .store_ptr:
        ld a, l
        ld [mus_ptr_lo], a
        ld a, h
        ld [mus_ptr_hi], a
        ret