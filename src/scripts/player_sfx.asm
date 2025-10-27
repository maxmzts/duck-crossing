INCLUDE "constants.inc"

SECTION "SFX RAM", WRAM0
sfx_req:        ds 1    ;;Petición de SFX, si vale SFX_NONE no hay SFX ha reproducir, sino tiene el ID del sonido

SECTION "SFX Player", ROM0

;;SCHEMA
;;call sfx_init     -> una vez en init
;;A = SFX_          -> id de sonido
;;call sfx_play     -> pedir sonido
;;call sfx_update   -> dispara si hay petición
;;call sfx_on_move  -> lee pressed_input del jugador y pide SFX

;;Init: POne a sfx_req con el valor de SFX_NONE
sfx_init::
    ld a, SFX_NONE
    ld [sfx_req], a

    ret

;;Play: No dispara el sonido, solo guarda los ID's de los sonidos que se llamarán con el update
sfx_play::
    ld [sfx_req], a
    ret

;;Update: Se llama en cada frame, si sfx_req es distinto de SFX_NONE guarda el valor en b, lo limpia y entra al dispatcher, este compara el ID y llama al sfx correspondiente
sfx_update::
    ld a, [sfx_req]
    cp SFX_NONE
    ret z

    ;;Limpia sfx_req y devuelve a "a" para las comparaciones
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

        cp SFX_MENU
        jr z, .do_menu

        cp SFX_KILL
        jr z, .do_kill

        ret

    ;;Llama al sonido de movimiento
    .do_r:
        call sfx_move_r
        ret

    .do_menu:
        call sfx_menu
        ret

    ;;Llama al sonido de muerte.
    .do_kill:
        call sfx_kill
        ret