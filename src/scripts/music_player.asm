INCLUDE "constants.inc"
INCLUDE "music_data.inc"

SECTION "Musica RAM", WRAM0
mus_ptr_lo:         ds 1
mus_ptr_hi:         ds 1
mus_ptr0_lo:        ds 1
mus_ptr0_hi:        ds 1
mus_dur:            ds 1
mus_playing:        ds 1
mus_trig_needed:    ds 1
mus_note_changed:   ds 1
song_req:           ds 1

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
    ld [mus_dur], a
    ld [mus_playing], a
    ld [mus_trig_needed], a

    ld a, $FF
    ld [song_req], a
    ret

;;Play, inicia desde HL
music_play::
    ld a, l
    ld [mus_ptr_lo], a
    ld [mus_ptr0_lo], a
    
    ld a, h
    ld [mus_ptr_hi], a
    ld [mus_ptr0_hi], a

    ld a, 1
    ld [mus_playing], a
    ld [mus_trig_needed], a

    xor a
    ld [mus_dur], a

    ret

;;Por ID de la tabla de music_data, cambia de canción
music_play_id::
    ld h, HIGH(SONG_TABLE)
    ld l, LOW(SONG_TABLE)
    add a
    ld e, a
    ld d, 0
    add hl, de

    ld a, [hl+]
    ld [mus_ptr_lo], a
    ld [mus_ptr0_lo], a

    ld a, [hl]
    ld [mus_ptr_hi], a
    ld [mus_ptr0_hi], a

    xor a
    ld [mus_note_changed], a
    ld [mus_dur], a
    ld a, 1
    ld [mus_playing], a
    ld [mus_trig_needed], a
    ret

;;Stop, para la música
music_stop::
    xor a
    ld [mus_playing], a

    ret

;;Update, llamada en cada frame
music_update::
    ld a, [mus_playing]
    or a
    ret z

    ;;Ver si la canción continua
    ld a, [mus_dur]
    or a
    jr z, .next_event
    dec a
    ld [mus_dur], a
    ret

    .next_event:
        ;;Siguiente evento
        ld a, [mus_ptr_lo]
        ld l, a
        ld a, [mus_ptr_hi]
        ld h, a

        ld a, [hl]
        inc hl

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

        ld a, [hl]
        inc hl
        ld [mus_dur], a

        jr .store_ptr

    .note_event:
        ld e, a
        ld a, [hl]
        inc hl
        ld [mus_dur], a
        ld a, [hl]
        inc hl
        ld d, a

        ld a, e
        ld [NR13], a
        ld a, d
        and %00000111
        ld b, a

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

    .store_ptr:
        ld a, l
        ld [mus_ptr_lo], a
        ld a, h
        ld [mus_ptr_hi], a
        ret