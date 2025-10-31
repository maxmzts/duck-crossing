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
    ret  ; ✅ CORREGIDO: Cambiado de 'reti' a 'ret'

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

    cp SCENE_LEVEL_3
    jr z, .init_level_3

    cp SCENE_LEVEL_4
    jr z, .init_level_4

    cp SCENE_LEVEL_5
    jr z, .init_level_5
    
    cp SCENE_LEVEL_6
    jr z, .init_level_6

    ;;cp SCENE_LEVEL_7
    ;;jr z, .init_level_7

    ;;cp SCENE_LEVEL_8
    ;;jr z, .init_level_8
    
    ;; Si no coincide con ninguna, ir a título por defecto
    jr .init_title
    
.init_title:
    call clear_oam  ; Limpiar sprites en título
    call title_screen_init
    jr .finish_change
    
.init_level_1:
    call level_1_init
    call render_player  
    jr .finish_change

.init_level_2:
    call level_2_init
    call render_player  
    jr .finish_change

.init_level_3:
    call level_3_init
    call render_player  
    jr .finish_change

.init_level_4:
    call level_4_init
    call render_player  
    jr .finish_change

.init_level_5:
    call level_5_init
    call render_player  
    jr .finish_change

.init_level_6:
    call level_6_init
    call render_player  ; Renderizar jugador después de cargar nivel
    jr .finish_change

;;.init_level_7:
    ;;call level_7_init
    ;;call render_player  ; Renderizar jugador después de cargar nivel
    ;;jr .finish_change

;;.init_level_8:
    ;;call level_8_init
    ;;call render_player  ; Renderizar jugador después de cargar nivel
    ;;jr .finish_change
    
.finish_change:
    ;; Marcar que ya no hay cambio pendiente
    xor a
    ld [w_scene_change_pending], a
    ldh [rIF], a
    ld [w_victory_flag], a
    
    ;; Encender pantalla
    call lcd_on
    ret

;; Actualiza la lógica de la escena actual
scene_manager_update_logic::
    ;; ✅ No actualizar lógica si hay cambio pendiente
    ld a, [w_scene_change_pending]
    cp 0
    ret nz  ; Si hay cambio pendiente, no hacer nada
    
    ld a, [w_current_scene]
    
    cp SCENE_TITLE
    jr z, .update_title
    
    cp SCENE_LEVEL_1
    jr z, .update_level_1

    cp SCENE_LEVEL_2
    jr z, .update_level_2

    cp SCENE_LEVEL_3
    jr z, .update_level_3

    cp SCENE_LEVEL_4
    jr z, .update_level_4

    cp SCENE_LEVEL_5
    jr z, .update_level_5

    cp SCENE_LEVEL_6
    jr z, .update_level_6

    ;;cp SCENE_LEVEL_7
    ;;jr z, .update_level_7

    ;;cp SCENE_LEVEL_8
    ;;jr z, .update_level_8
    
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

.update_level_3:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_3_check_victory
    ret

.update_level_4:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_4_check_victory
    ret

.update_level_5:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_5_check_victory
    ret

.update_level_6:
    call update_player
    call restart_roads_scroll_loop
    call update_physics
    call level_6_check_victory
    ret

;;.update_level_7:
    ;;call update_player
    ;;call restart_roads_scroll_loop
    ;;call update_physics
    ;;call level_7_check_victory
    ;;ret

;;.update_level_8:
    ;;call update_player
    ;;call restart_roads_scroll_loop
    ;;call update_physics
    ;;call level_8_check_victory
    ;;ret

;; Renderiza la escena actual
scene_manager_render::
    ;; No renderizar si hay cambio pendiente
    ld a, [w_scene_change_pending]
    cp 0
    ret nz  ; Si hay cambio pendiente, no renderizar
    
    ld a, [w_current_scene]
    
    cp SCENE_LEVEL_1
    jr z, .render_level_1

    cp SCENE_LEVEL_2
    jr z, .render_level_2

    cp SCENE_LEVEL_3
    jr z, .render_level_3

    cp SCENE_LEVEL_4
    jr z, .render_level_4

    cp SCENE_LEVEL_5
    jr z, .render_level_5

    cp SCENE_LEVEL_6
    jr z, .render_level_6

    ;;cp SCENE_LEVEL_7
    ;;jr z, .render_level_7

    ;;cp SCENE_LEVEL_8
    ;;jr z, .render_level_8
    
    ret  ; Escena no reconocida
    
.render_title:
    ;; La pantalla de título es estática, no renderiza nada
    ret
    
.render_level_1:
    call render_player
    ;call physics
    ;call level_man_update_smoke
    ret

.render_level_2:
    call render_player
    ;call physics
    ;call level_man_update_smoke
    ret

.render_level_3:
    call render_player
    ;call physics
    ret

.render_level_4:
    call render_player
    ;call physics
    ret

.render_level_5:
    call render_player
    ;call physics
    ret

.render_level_6:
    call render_player
    call physics
    ret

;;.render_level_7:
    ;;call render_player
    ;;call physics
    ;;ret

;;.render_level_8:
    ;;call render_player
    ;;call physics
    ;;ret

;; Obtiene la escena actual
;; OUTPUT: A = escena actual
scene_manager_get_current_scene::
    ld a, [w_current_scene]
    ret