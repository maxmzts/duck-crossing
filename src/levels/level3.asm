include "constants.inc"

SECTION "Level 3 roads", ROM0

roads_level_3:
;;     LY,   TY,  Vel,  Last SCX
DB     39,    5,    1,     0
DB     47,    6,    3,     0
DB     79,   10,    2,     0
DB     87,   11,    3,     0
DB    103,   13,    4,     0
DB    119,   15,    1,     0
.end:

level_3_init::
	call init_player
	
	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level3
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_3
	ld de, level3
	ld b, roads_level_3.end - roads_level_3
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_3_check_victory::
	;; ✅ NUEVO: Si ya hay cambio de escena pendiente, no hacer nada
	ld a, [w_scene_change_pending]
	cp 1
	ret z
	
	ld a, [w_victory_flag]
	cp 1
	ret nz
	
	;; ✅ IMPORTANTE: Reiniciar el flag de victoria INMEDIATAMENTE
	;; antes de cualquier otra cosa para evitar doble detección
	xor a
	ld [w_victory_flag], a
	
	;; ✅ NUEVO: Reiniciar el puntero de colisión a un valor seguro
	;; para evitar que se detecte de nuevo en el mismo frame
	ld a, $98
	ld [tile_colliding_pointer], a
	xor a
	ld [tile_colliding_pointer+1], a
	ld [tile_ID_colliding], a
	
	call level_man_clear
	;; cambiar a nivel 4
	ld a, SCENE_LEVEL_4
	call scene_manager_change_scene 
	
	ret