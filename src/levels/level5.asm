include "constants.inc"

SECTION "Level 5 roads", ROM0

roads_level_5:
;;     LY,   TY,  Vel,  Last SCX
DB     31,    4,    1,     0
DB     55,    7,    4,     0
DB     71,    9,    2,     0
DB     87,   11,    3,     0
DB    111,   14,    1,     0
DB    119,   15,    4,     0
.end:

level_5_init::
	call init_player
	
	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level5
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_5
	ld b, roads_level_5.end - roads_level_5
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_5_check_victory::
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
	;; cambiar a nivel 6
	ld a, SCENE_TITLE
	call scene_manager_change_scene 
	
	ret