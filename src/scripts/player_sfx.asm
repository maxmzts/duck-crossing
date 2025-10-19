INCLUDE "constants.inc"

SECTION "SFX RAM", WRAM0
sfx_req:        ds 1

SECTION "SFX Player", ROM0

;;SCHEMA
;;call sfx_init     -> una vez en init
;;A = SFX_          -> id de sonido
;;call sfx_play     -> pedir sonido
;;call sfx_update   -> dispara si hay petición
;;call sfx_on_move  -> lee pressed_input del jugador y pide SFX

;;Init
sfx_init::
    ld a, SFX_NONE
    ld [sfx_req], a

    ret

;;Play
sfx_play::
    ld [sfx_req], a
    ret

;;Update
sfx_update::
    ld a, [sfx_req]
    cp SFX_NONE
    ret z

    ld b, a
    ld a, SFX_NONE
    ld [sfx_req], a
    ld a, b

    .dispatch:
        cp SFX_MOVE_R
        jr z, .do_r

        cp SFX_MOVE_L
        jr z, .do_r

        cp SFX_MOVE_U
        jr z, .do_r

        cp SFX_MOVE_D
        jr z, .do_r

        ret

    .do_r:
        call sfx_move_r
        ret