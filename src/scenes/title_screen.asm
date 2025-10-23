include "constants.inc"

SECTION "Title Screen WRAM", WRAM0
w_title_input_cooldown:: DS 1  ; Cooldown para evitar inputs dobles

SECTION "Title Screen ROM", ROM0

;; Inicializa la pantalla de título
title_screen_init::
    ;; Mover sprite del jugador fuera de la pantalla
    ;; Simplemente ponemos Y = 0 (fuera de pantalla)
    ld hl, player
    ld a, 0
    ld [hl+], a  ; Y del primer sprite = 0
    ld [hl+], a  ; X = 0
    ld [hl+], a  ; Tile = 0
    ld [hl+], a  ; Atributos = 0
    ld [hl+], a  ; Y del segundo sprite = 0
    ld [hl+], a  ; X = 0
    ld [hl+], a  ; Tile = 0
    ld [hl], a   ; Atributos = 0
    
    ;; Cargar tilemap de título
    ld hl, title_tilemap
    call load_32x32_tilemap
    
    ;; Deshabilitar interrupciones de LYC (solo para niveles)
    call disable_lyc_interrupt
    
    ;; Resetear scroll
    xor a
    ld [rSCX], a
    ld [rSCY], a
    
    ;; Inicializar cooldown
    ld a, 10
    ld [w_title_input_cooldown], a
    
    ret
    
    ;; Deshabilitar interrupciones de LYC (solo para niveles)
    call disable_lyc_interrupt
    
    ;; Resetear scroll
    xor a
    ld [rSCX], a
    ld [rSCY], a
    
    ;; Inicializar cooldown
    ld a, 10
    ld [w_title_input_cooldown], a
    
    ret

;; Actualiza la lógica de la pantalla de título
title_screen_update::
    ;; Decrementar cooldown si está activo
    ld a, [w_title_input_cooldown]
    cp 0
    jr z, .check_input
    dec a
    ld [w_title_input_cooldown], a
    ret
    
.check_input:
    ;; Verificar input de botones (A, B, Start, Select)
    ld a, SELECT_BUTTONS
    ld [rJOYP], a
    ld a, [rJOYP]
    ld a, [rJOYP]  ; Lectura doble para estabilidad
    
    ;; Invertir bits (0 = presionado)
    cpl
    and $0F
    
    ;; Si algún botón está presionado, iniciar nivel
    cp 0
    jr nz, .start_game
    
    
    ret
    
.start_game:
    ;; Cambiar a nivel 1
    ld a, SCENE_LEVEL_1
    call scene_manager_change_scene
    ret