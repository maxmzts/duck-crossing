include "constants.inc"

SECTION "Level 4 roads", ROM0

roads_level_4:
;;     LY,   TY,  Vel,  Last SCX
DB     39,    5,    4,     0
DB     55,    7,    4,     0
DB     71,    9,    4,     0
DB     87,   11,    4,     0
DB    103,   13,    4,     0
DB    119,   15,    4,     0
.end:

level_4_init::
	call init_player
	
	ld a, SONG_MAIN
    call music_play_id
	
	;; cargar tilemap
	ld hl, level4
	call load_32x32_tilemap

	;; Inicializar nivel en el level manager
	ld hl, roads_level_4
	ld b, roads_level_4.end - roads_level_4
	call level_man_init

	;; solo queremos el interrupt de
	;; LCD activo cuando la escena activa
	;; es un nivel
	call enable_lyc_interrupt

	ret

level_4_check_victory::
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
	;; cambiar a nivel 5
	ld a, SCENE_LEVEL_5
	call scene_manager_change_scene 
	
	ret