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
	;; ✅ OPCIONAL: Si quieres resetear la posición del jugador
	;; descomenta la siguiente línea:
	; call init_player
	
	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level2
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_2
	ld b, roads_level_2.end - roads_level_2
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_2_check_victory::
	;; ✅ NUEVO: Si ya hay cambio de escena pendiente, no hacer nada
	ld a, [w_scene_change_pending]
	cp 1
	ret z
	
	ld a, [w_victory_flag]
	cp 1
	ret nz
	
	;; ✅ IMPORTANTE: Reiniciar el flag de victoria INMEDIATAMENTE
	xor a
	ld [w_victory_flag], a
	
	;; ✅ NUEVO: Reiniciar el puntero de colisión a un valor seguro
	ld a, $98
	ld [tile_colliding_pointer], a
	xor a
	ld [tile_colliding_pointer+1], a
	ld [tile_ID_colliding], a
	

	call level_man_clear

	;; ✅ CORREGIDO: Si quieres ir a un nivel 3, cambia esto:
	;; ld a, SCENE_LEVEL_3
	;; Si quieres volver al título:
	ld a, SCENE_TITLE
	call scene_manager_change_scene 
	
	ret