include "constants.inc"

SECTION "Level 6 roads", ROM0

roads_level_6:
;;     LY,   TY,  Vel,  Last SCX
DB     47,    6,    4,     0
DB     55,    7,    2,     0
DB     71,    9,    1,     0
DB     87,   11,    1,     0
DB    103,   13,    2,     0
DB    111,   14,    3,     0
.end:

level_6_init::
	call init_player
	
	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level6
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_6
	ld b, roads_level_6.end - roads_level_6
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_6_check_victory::
	;; Si ya hay cambio de escena pendiente, no hacer nada
	ld a, [w_scene_change_pending]
	cp 1
	ret z
	
	ld a, [w_victory_flag]
	cp 1
	ret nz
	
	;;Reiniciar el flag de victoria INMEDIATAMENTE
	;; antes de cualquier otra cosa para evitar doble detección
	xor a
	ld [w_victory_flag], a
	
	;;Reiniciar el puntero de colisión a un valor seguro
	;; para evitar que se detecte de nuevo en el mismo frame
	ld a, $98
	ld [tile_colliding_pointer], a
	xor a
	ld [tile_colliding_pointer+1], a
	ld [tile_ID_colliding], a
	
	call level_man_clear
	;; cambiar a nivel 2
	ld a, SCENE_TITLE
	call scene_manager_change_scene 
	
	ret