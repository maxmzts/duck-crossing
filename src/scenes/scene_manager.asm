include "constants.inc"
include "macros.inc"

SECTION "Scene Manager WRAM", WRAM0
;; Escena actual
w_current_scene:: DS 1
;; Escena siguiente (para transiciones)
w_next_scene:: DS 1
;; Flag de cambio de escena pendiente
w_scene_change_pending:: DS 1

SECTION "Scene Manager ROM", ROM0

;; Inicializa el sistema de escenas
;; INPUT: A = escena inicial
scene_manager_init::
    ld [w_current_scene], a
    ld [w_next_scene], a
    xor a
    ld [w_scene_change_pending], a
    ret

;; Solicita un cambio de escena
;; INPUT: A = ID de la nueva escena
scene_manager_change_scene::
    ld [w_next_scene], a
    ld a, 1
    ld [w_scene_change_pending], a
    reti

;; Procesa el cambio de escena si hay uno pendiente
scene_manager_update::
    ld a, [w_scene_change_pending]
    cp 0
    ret z  ; No hay cambio pendiente
    
    ;; Hay cambio pendiente, procesarlo
    call lcd_off
    
    ;; Limpiar pantalla (pero NO el OAM todavía)
    call clear_background
    
    ;; Obtener la nueva escena
    ld a, [w_next_scene]
    ld [w_current_scene], a
    
    ;; Llamar al init de la escena correspondiente
    cp SCENE_TITLE
    jr z, .init_title
    
    cp SCENE_LEVEL_1
    jr z, .init_level_1

    cp SCENE_LEVEL_2
    jr z, .init_level_2
    
    ;; Si no coincide con ninguna, ir a título por defecto
    jr .init_title
    
.init_title:
    call clear_oam  ; Limpiar sprites en título
    call title_screen_init
    jr .finish_change
    
.init_level_1:
    call level_1_init
    call render_player  ; Renderizar jugador después de cargar nivel
    jr .finish_change

.init_level_2:
    call level_2_init
    call render_player  ; Renderizar jugador después de cargar nivel
    jr .finish_change
    
.finish_change:
    ;; Marcar que ya no hay cambio pendiente
    xor a
    ld [w_scene_change_pending], a
    ldh [rIF], a
    ld [w_victory_flag], a

    MEMCPY sprite, player, 8
    
    ;; Encender pantalla
    call lcd_on
    ret

;; Actualiza la lógica de la escena actual
scene_manager_update_logic::
    ld a, [w_current_scene]
    
    cp SCENE_TITLE
    jr z, .update_title
    
    cp SCENE_LEVEL_1
    jr z, .update_level_1

    cp SCENE_LEVEL_2
    jr z, .update_level_2
    
    ret  ; Escena no reconocida
    
.update_title:
    call title_screen_update
    ret
    
.update_level_1:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_1_check_victory
    ret

.update_level_2:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_2_check_victory
    ret

;; Renderiza la escena actual
scene_manager_render::
    ld a, [w_current_scene]
    
    cp SCENE_TITLE
    jr z, .render_title
    
    cp SCENE_LEVEL_1
    jr z, .render_level_1

    cp SCENE_LEVEL_2
    jr z, .render_level_2
    
    ret  ; Escena no reconocida
    
.render_title:
    ;; La pantalla de título es estática, no renderiza nada
    ;; Importante: NO llamar a render_player aquí
    ret
    
.render_level_1:
    call render_player
    call physics
    ret

.render_level_2:
    call render_player
    call physics
    ret

;; Obtiene la escena actual
;; OUTPUT: A = escena actual
scene_manager_get_current_scene::
    ld a, [w_current_scene]
    ret