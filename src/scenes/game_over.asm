include "constants.inc"

SECTION "Game Over WRAM", WRAM0
w_game_over_input_cooldown:: DS 1  ; Cooldown para evitar inputs dobles

SECTION "Game Over ROM", ROM0

;; Inicializa la pantalla de Game Over
game_over_init::
    ;; Mover sprite del jugador fuera de la pantalla
    ;; Ocultamos todos los sprites poniendo Y = 0
    ld hl, player
    xor a  ; a = 0
    ld [hl+], a  ; Y del primer sprite = 0
    ld [hl+], a  ; X = 0
    ld [hl+], a  ; Tile = 0
    ld [hl+], a  ; Atributos = 0
    ld [hl+], a  ; Y del segundo sprite = 0
    ld [hl+], a  ; X = 0
    ld [hl+], a  ; Tile = 0
    ld [hl], a   ; Atributos = 0
    
    ;; Cargar tilemap de Game Over
    ld hl, game_over_tilemap
    call load_32x32_tilemap
    
    ;; Deshabilitar interrupciones de LYC (solo para niveles)
    call disable_lyc_interrupt
    
    ;; Resetear scroll
    xor a
    ld [rSCX], a
    ld [rSCY], a
    
    ;; Inicializar cooldown (más largo que el título para dar tiempo al jugador)
    ld a, 30
    ld [w_game_over_input_cooldown], a
    
    ;; Resetear el estado del jugador para cuando reinicie
    xor a
    ld [state], a  ; state = 0 (alive)
    
    ret

;; Actualiza la lógica de la pantalla de Game Over
game_over_update::
    ;; Decrementar cooldown si está activo
    ld a, [w_game_over_input_cooldown]
    cp 0
    jr z, .check_input
    dec a
    ld [w_game_over_input_cooldown], a
    ret
    
.check_input:
    ;; Verificar input del botón A específicamente
    ld a, SELECT_BUTTONS
    ld [rJOYP], a
    ld a, [rJOYP]
    ld a, [rJOYP]  ; Lectura doble para estabilidad
    
    ;; Invertir bits (0 = presionado en Game Boy)
    cpl
    and $0F  ; Solo nos interesan los primeros 4 bits
    
    ;; Verificar si el botón A está presionado (bit 0)
    bit A_PRESSED, a
    jr z, .check_other_buttons  ; Si A no está presionado, verificar otros
    
    ;; A está presionado, reiniciar el juego
    jr .restart_game
    
.check_other_buttons:
    ;; Opcionalmente, podemos permitir START también
    bit START_PRESSED, a
    jr z, .no_input  ; Si START no está presionado, no hacer nada
    
.restart_game:
    ;; Reproducir sonido de menú
    ld a, SFX_MENU
    call sfx_play
    
    ;; Cambiar la música de vuelta a la del juego principal
    ld a, SONG_MAIN
    call music_play_id
    
    ;; Reinicializar variables del jugador
    call init_player
    
    ;; Cambiar a nivel 1
    ld a, SCENE_LEVEL_1
    call scene_manager_change_scene
    ret
    
.no_input:
    ret