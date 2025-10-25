include "constants.inc"
include "macros.inc"

SECTION "Game Over Screen WRAM", WRAM0
w_game_over_input_cooldown:: DS 1

SECTION "Game Over Screen ROM", ROM0

game_over_screen_init::
    ;; Ocultar jugador
    ld hl, player
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    
    ;; Cargar tiles de Game Over
    MEMCPY game_over_tiles, $8000, game_over_tiles.end - game_over_tiles
    
    ;; Cargar tilemap de Game Over
    ld hl, game_over_tilemap
    call load_32x32_tilemap
    
    ;; Deshabilitar interrupciones de nivel
    call disable_lyc_interrupt
    
    ;; Reset scroll
    xor a
    ld [rSCX], a
    ld [rSCY], a
    
    ;; Cooldown de 1 segundo
    ld a, 60
    ld [w_game_over_input_cooldown], a
    
    ret

game_over_screen_update::
    ;; Esperar cooldown
    ld a, [w_game_over_input_cooldown]
    cp 0
    jr z, .check_input
    dec a
    ld [w_game_over_input_cooldown], a
    ret
    
.check_input:
    ;; Leer botones
    ld a, SELECT_BUTTONS
    ld [rJOYP], a
    ld a, [rJOYP]
    ld a, [rJOYP]  ; Lectura doble para estabilidad
    
    ;; Invertir bits (0 = presionado)
    cpl
    and $0F
    
    ;; Si algún botón está presionado, reiniciar nivel
    cp 0
    jr nz, .start_game
    ret
    
.start_game:
    ;; Reiniciar nivel 1
    ld a, SCENE_LEVEL_1
    call scene_manager_change_scene
    ret