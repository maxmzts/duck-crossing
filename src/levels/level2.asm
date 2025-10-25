include "constants.inc"

SECTION "Level 2 roads", ROM0

roads_level_2:
;;     LY,   TY,  Vel,  Last SCX
DB     55,    7,    0,     0
DB     63,    8,    1,     0
DB     79,   10,    1,     0
DB     87,   11,    3,     0
DB    111,   14,    3,     0
DB    119,   15,    3,     0
.end:

level_2_init::
	;; Si quieres resetear la posición del jugador
	;; descomenta la siguiente línea:
	call init_player
	
	;; cargar tilemap
	ld hl, level2
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_2
	ld b, roads_level_2.end - roads_level_2
	call level_man_init
	
	;; Actualizar inmediatamente el puntero de colisión
	;; con la posición actual del jugador para evitar usar
	;; el puntero del nivel anterior
	ld hl, player_copy
	call get_address_of_tile_being_touched

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_2_check_victory::
	ld a, [w_victory_flag]
	cp 1
	ret nz
	
	;; Reiniciar el flag de victoria ANTES del cambio
	xor a
	ld [w_victory_flag], a
	
	;; Para más adelante si queremos ir a un nivel 3, cambiamos esto:
	;; ld a, SCENE_LEVEL_3
	;; Si quieres volver al título:
	ld a, SCENE_TITLE
	call scene_manager_change_scene 
	
	ret